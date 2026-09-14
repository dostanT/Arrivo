//
//  MapViewModel.swift
//  Arrivo
//

import Combine
import Foundation

@MainActor
final class MapViewModel: ObservableObject {
    @Published var isAuthorized: Bool = false

    @Published var selectedCoordinate: GeoCoordinate?
    @Published var showAlert = false
    @Published var alertMessage = ""

    @Published var shownStops: [Stop] = []

    @Published var startedMonitoringsIDs: [String] = [] {
        didSet {
            monitoringPersistence.saveStartedMonitoringIds(startedMonitoringsIDs)
        }
    }

    @Published var oldMonitoringsCoordinate: [CoordinateModel] = [] {
        didSet {
            monitoringPersistence.saveOldMonitorings(oldMonitoringsCoordinate)
        }
    }

    @Published var activeSheet: ActiveSheet?

    @Published var searchText: String = ""
    @Published var isSearching: Bool = false
    @Published var radius: Double = 400

    @Published private(set) var visibleStops: [Stop] = []
    @Published private(set) var currentCity: CityStopsSource = .astana
    @Published private(set) var mapRegion: MapRegion = .defaultAstana
    @Published private(set) var lastKnownUserLocation: GeoCoordinate?

    @Published var markerScale = 1.0
    @Published var markerOpacity = 0.0
    
    @Published var melodyURL: URL? = nil

    private let locationCoordination: LocationCoordinationUseCase
    private let loadStopsUseCase: LoadStopsUseCase
    private let filterStopsUseCase: FilterVisibleStopsUseCase
    private let detectCityUseCase: DetectCityUseCase
    private let searchStopsUseCase: SearchStopsUseCase
    private let buildStopGridUseCase: BuildStopGridUseCase
    private let playHapticUseCase: PlayHapticFeedbackUseCase
    private let monitoringPersistence: MonitoringPersistenceUseCase
    private let findNearestStopUseCase: FindNearestStopUseCase
    private let loadMelodyURLUseCase: LoadMelodyURLUseCase
    private let saveMelodyURLUseCase: SaveMelodyURLUseCase
    

    private var allStops: [Stop] = []
    private var stopGrid: [GridKey: [Stop]] = [:]
    private var updateWorkItem: DispatchWorkItem?
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    private var locationTasks: [Task<Void, Never>] = []

    deinit {
        searchTask?.cancel()
        locationTasks.forEach { $0.cancel() }
    }

    private enum Constants {
        static let updateDebounceInterval: TimeInterval = 0.1
    }

    init(
        locationCoordination: LocationCoordinationUseCase,
        loadStopsUseCase: LoadStopsUseCase,
        filterStopsUseCase: FilterVisibleStopsUseCase,
        detectCityUseCase: DetectCityUseCase,
        searchStopsUseCase: SearchStopsUseCase,
        buildStopGridUseCase: BuildStopGridUseCase,
        playHapticUseCase: PlayHapticFeedbackUseCase,
        monitoringPersistence: MonitoringPersistenceUseCase,
        findNearestStopUseCase: FindNearestStopUseCase,
        loadMelodyURLUseCase: LoadMelodyURLUseCase,
        saveMelodyURLUseCase: SaveMelodyURLUseCase
    ) {
        self.locationCoordination = locationCoordination
        self.loadStopsUseCase = loadStopsUseCase
        self.filterStopsUseCase = filterStopsUseCase
        self.detectCityUseCase = detectCityUseCase
        self.searchStopsUseCase = searchStopsUseCase
        self.buildStopGridUseCase = buildStopGridUseCase
        self.playHapticUseCase = playHapticUseCase
        self.monitoringPersistence = monitoringPersistence
        self.findNearestStopUseCase = findNearestStopUseCase
        self.loadMelodyURLUseCase = loadMelodyURLUseCase
        self.saveMelodyURLUseCase = saveMelodyURLUseCase

        startedMonitoringsIDs = monitoringPersistence.loadStartedMonitoringIds()
        oldMonitoringsCoordinate = monitoringPersistence.loadOldMonitorings()

        subscribeToLocationStreams()
        setupBindings()
        loadInitialStops()
        locationCoordination.requestWhenInUseAuthorization()
        loadMelodyURL()
    }
    
    func assignActiveSheet(sheet: ActiveSheet?) {
        activeSheet = sheet
    }
    
    func saveMelodyURL(url: URL?) {
        saveMelodyURLUseCase.execute(url: url)
    }
    
    func loadMelodyURL() {
        melodyURL = loadMelodyURLUseCase.execute()
    }

    private func subscribeToLocationStreams() {
        let authTask = Task { [weak self] in
            guard let self else { return }
            for await authorized in self.locationCoordination.authorizationUpdates() {
                await MainActor.run {
                    self.isAuthorized = authorized
                    if !authorized {
                        self.alertMessage = String(localized: "Location access required")
                        self.showAlert = true
                    }
                }
            }
        }
        locationTasks.append(authTask)

        let locTask = Task { [weak self] in
            guard let self else { return }
            for await coord in self.locationCoordination.locationUpdates() {
                await MainActor.run {
                    self.lastKnownUserLocation = coord
                }
            }
        }
        locationTasks.append(locTask)
    }

    func loadstartedMonitoringsIDs() {
        startedMonitoringsIDs = monitoringPersistence.loadStartedMonitoringIds()
    }

    func getNearestStopInformation(id: String) async -> Stop? {
        guard let center = await locationCoordination.monitoringCenter(forRegionId: id) else {
            return nil
        }
        return findNearestStopUseCase.execute(stops: shownStops, center: center)
    }

    func search() {
        searchTask?.cancel()

        guard !searchText.isEmpty else {
            shownStops = allStops
            isSearching = false
            return
        }

        isSearching = true

        searchTask = Task(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            let results = await self.searchStopsUseCase.search(query: self.searchText)
            try? Task.checkCancellation()
            await MainActor.run {
                self.shownStops = results
                self.isSearching = false
            }
        }
    }

    private func setupBindings() {
        $searchText
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.search()
            }
            .store(in: &cancellables)
    }

    private func loadInitialStops() {
        Task {
            await loadStops(for: .astana)
        }
    }

    private func loadStops(for city: CityStopsSource) async {
        allStops = await loadStopsUseCase.execute(for: city)
        stopGrid = buildStopGridUseCase.execute(stops: allStops)
        shownStops = allStops
        await searchStopsUseCase.updateStops(allStops)
        await updateVisibleStops()
    }

    private func updateVisibleStops() async {
        guard !allStops.isEmpty else {
            visibleStops = []
            return
        }

        let filtered = await filterStopsUseCase.execute(
            stops: allStops,
            grid: stopGrid,
            mapRegion: mapRegion,
            currentCity: currentCity
        )
        visibleStops = filtered
    }

    private func scheduleVisibleStopsUpdate() {
        updateWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            Task {
                await self.updateVisibleStops()
            }
        }
        updateWorkItem = workItem
        DispatchQueue.main.asyncAfter(
            deadline: .now() + Constants.updateDebounceInterval,
            execute: workItem
        )
    }

    func selectCoordinate(_ coordinate: GeoCoordinate) {
        selectedCoordinate = coordinate
        animateMarkerAppearance()
        Task {
            await playHapticUseCase.execute(.lightImpact)
        }
    }

    private func animateMarkerAppearance() {
        markerScale = 1.0
        markerOpacity = 0.0
        markerOpacity = 1.0
    }

    func toCenter(by location: GeoCoordinate) {
        mapRegion = MapRegion(
            center: location,
            latitudeDelta: MapSpanConstants.userLocationLatitudeDelta,
            longitudeDelta: MapSpanConstants.userLocationLongitudeDelta
        )
        Task {
            await updateVisibleStops()
        }
    }

//    func centerToUserLocation() {
//        guard let geo = lastKnownUserLocation else {
//            alertMessage = String(localized: "Failed to determine location")
//            showAlert = true
//            Task {
//                await playHapticUseCase.execute(.error)
//            }
//            return
//        }
//        mapRegion = MapRegion(
//            center: geo,
//            latitudeDelta: MapSpanConstants.userLocationLatitudeDelta,
//            longitudeDelta: MapSpanConstants.userLocationLongitudeDelta
//        )
//        Task {
//            await updateVisibleStops()
//            await playHapticUseCase.execute(.success)
//        }
//    }
    func centerToUserLocation() {
        // 1. Если уже есть — используем мгновенно
        if let geo = lastKnownUserLocation {
            moveToUserLocation(geo)
            return
        }

        // 2. Иначе запрашиваем одну локацию
        locationCoordination.requestCurrentLocation()

        // 3. Ждём первый результат
        Task { [weak self] in
            guard let self else { return }

            let timeoutTask = Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await MainActor.run {
                    if self.lastKnownUserLocation == nil {
                        self.alertMessage = "Failed to determine location"
                        self.showAlert = true
                    }
                }
            }

            for await coord in self.locationCoordination.locationUpdates() {
                guard let coord else { continue }

                timeoutTask.cancel()

                await MainActor.run {
                    self.lastKnownUserLocation = coord
                    self.moveToUserLocation(coord)
                }
                break
            }
        }
    }
    
    private func moveToUserLocation(_ geo: GeoCoordinate) {
        mapRegion = MapRegion(
            center: geo,
            latitudeDelta: MapSpanConstants.userLocationLatitudeDelta,
            longitudeDelta: MapSpanConstants.userLocationLongitudeDelta
        )

        Task {
            await updateVisibleStops()
            await playHapticUseCase.execute(.success)
        }
    }

    func onMapRegionChanged(_ newRegion: MapRegion) {
        guard mapRegion.hasSignificantChanges(comparedTo: newRegion) else {
            return
        }
        mapRegion = newRegion

        if let newCity = detectCityUseCase.execute(for: newRegion.center),
           newCity != currentCity
        {
            currentCity = newCity
            Task {
                await loadStops(for: newCity)
            }
        }
        scheduleVisibleStopsUpdate()
    }

    func updateStartedMonitoringsIDsAndOldMonitoringsCoordinate(id: String? = nil) async {
        let idsToProcess: [String]
        if let id {
            idsToProcess = [id]
            startedMonitoringsIDs.removeAll(where: { $0 == id })
        } else {
            idsToProcess = startedMonitoringsIDs
            startedMonitoringsIDs.removeAll()
        }

        for monitoringID in idsToProcess {
            guard let coordinate = locationCoordination.coordinate(forMonitoringId: monitoringID) else {
                continue
            }
            var model = CoordinateModel(geoCoordinate: coordinate)
            if let nearestStop = await getNearestStopInformation(id: monitoringID) {
                model.text = nearestStop.name
            }
            oldMonitoringsCoordinate.append(model)
        }
    }

    func stopMonitoring(id: String) {
        Task {
            await updateStartedMonitoringsIDsAndOldMonitoringsCoordinate(id: id)
            await locationCoordination.stopMonitoring(regionId: id)
            await playHapticUseCase.execute(.lightImpact)
        }
    }

    func stopMonitoring() {
        Task {
            await updateStartedMonitoringsIDsAndOldMonitoringsCoordinate()
            await locationCoordination.stopAllMonitoring()
            await playHapticUseCase.execute(.lightImpact)
        }
    }

    func startMonitoring() {
        guard let coordinate = selectedCoordinate else {
            alertMessage = String(localized: "Select a point first")
            showAlert = true
            Task {
                await playHapticUseCase.execute(.error)
            }
            return
        }
        let id = UUID().uuidString
        startedMonitoringsIDs.append(id)
        monitoringPersistence.saveLastSelectedCoordinate(coordinate)
        Task {
            await locationCoordination.startMonitoring(
                regionId: id,
                coordinate: coordinate,
                radiusMeters: radius
            )
            alertMessage = String(localized: "Monitoring started")
            showAlert = true
            await playHapticUseCase.execute(.success)
        }
    }

    func onRadiusSliderChanged() {
        Task {
            await playHapticUseCase.execute(.softImpact)
        }
    }

    func presentStartedMonitoringsSheet() {
        activeSheet = .startedMonitorings
        Task {
            await playHapticUseCase.execute(.lightImpact)
        }
    }

    func notifyToolbarSearchTapped() async {
        await playHapticUseCase.execute(.lightImpact)
    }

    func notifySearchSheetDismissTapped() async {
        await playHapticUseCase.execute(.lightImpact)
    }

    func loadLastSelectedCoordinate() -> GeoCoordinate? {
        monitoringPersistence.loadLastSelectedCoordinate()
    }

    func clearSelection() {
        selectedCoordinate = nil
        markerScale = 1.0
        markerOpacity = 0.0
    }

    func updateRegion(center: GeoCoordinate, latitudeDelta: Double? = nil, longitudeDelta: Double? = nil) {
        mapRegion = MapRegion(
            center: center,
            latitudeDelta: latitudeDelta ?? MapSpanConstants.defaultLatitudeDelta,
            longitudeDelta: longitudeDelta ?? MapSpanConstants.defaultLongitudeDelta
        )
        Task {
            await updateVisibleStops()
        }
    }
}
