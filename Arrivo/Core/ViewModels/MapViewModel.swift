import Combine
import CoreLocation
import MapKit
import SwiftUI

// MARK: - Presentation/ViewModel

@MainActor
final class MapViewModel: ObservableObject {
    @Published var isAuthorized: Bool = false

    // MARK: - Published Properties

    @Published var selectedCoordinate: CLLocationCoordinate2D?
    @Published var cameraPosition: MapCameraPosition
    @Published var showAlert = false
    @Published var alertMessage = ""

    @Published var shownStops: [Stop] = []

    @Published var startedMonitoringsIDs: [String] = [] {
        didSet {
            UserDefaults.standard.set(startedMonitoringsIDs, forKey: "startedMonitoringsIDs")
        }
    }

    @Published var searchText: String = ""
    @Published var isSearching: Bool = false
    @Published var radius: CLLocationDistance = 400

    private var searchTask: Task<Void, Never>?
    private var searchEngine: SearchEngine?

    @Published private(set) var visibleStops: [Stop] = []
    @Published private(set) var currentCity: CityStopsSource = .astana
    @Published private(set) var mapState = MapState(
        center: Constants.defaultCoordinate,
        span: Constants.defaultSpan
    )

    // MARK: - Animation Properties

    @Published var markerScale = 1.0
    @Published var markerOpacity = 0.0

    // MARK: - Dependencies

    private let locationService: LocationViewModel
    private let loadStopsUseCase: LoadStopsUseCase
    private let filterStopsUseCase: FilterVisibleStopsUseCase
    private let detectCityUseCase: DetectCityUseCase

    // MARK: - Private State

    private var allStops: [Stop] = []
    private var stopGrid: [GridKey: [Stop]] = [:]
    private var updateWorkItem: DispatchWorkItem?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Constants

    enum Constants {
        static let defaultCoordinate = CLLocationCoordinate2D(latitude: 51.1694, longitude: 71.4491)
        static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        static let userLocationSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        static let updateDebounceInterval: TimeInterval = 0.1
        static let significantChangeThreshold: Double = 0.001
    }

    // MARK: - Initialization

    init(
        locationService: LocationViewModel,
        loadStopsUseCase: LoadStopsUseCase,
        filterStopsUseCase: FilterVisibleStopsUseCase,
        detectCityUseCase: DetectCityUseCase
    ) {
        self.locationService = locationService
        self.loadStopsUseCase = loadStopsUseCase
        self.filterStopsUseCase = filterStopsUseCase
        self.detectCityUseCase = detectCityUseCase

        let region = MKCoordinateRegion(
            center: Constants.defaultCoordinate,
            span: Constants.defaultSpan
        )
        cameraPosition = .region(region)

        setupBindings()
        loadInitialStops()
        loadstartedMonitoringsIDs()
    }

    func loadstartedMonitoringsIDs() {
        startedMonitoringsIDs = UserDefaults.standard.stringArray(forKey: "startedMonitoringsIDs") ?? []
    }

    func getNearestStopInformation(id: String) async -> Stop? {
        guard
            let region = await locationService.getMonitoringRegion(id: id),
            let circularRegion = region as? CLCircularRegion
        else {
            return nil
        }

        let regionLocation = CLLocation(
            latitude: circularRegion.center.latitude,
            longitude: circularRegion.center.longitude
        )

        return shownStops.min(by: { stop1, stop2 in
            let loc1 = CLLocation(
                latitude: stop1.coordinate.latitude,
                longitude: stop1.coordinate.longitude
            )
            let loc2 = CLLocation(
                latitude: stop2.coordinate.latitude,
                longitude: stop2.coordinate.longitude
            )

            return loc1.distance(from: regionLocation)
                < loc2.distance(from: regionLocation)
        })
    }

    func search() {
        // Cancel previous search
        searchTask?.cancel()

        // If search text is empty – show all stops
        guard !searchText.isEmpty else {
            shownStops = allStops
            isSearching = false
            return
        }

        isSearching = true

        searchTask = Task(priority: .userInitiated) { [weak self] in
            guard let self = self, let engine = self.searchEngine else { return }

            let results = await engine.search(query: self.searchText)

            try? Task.checkCancellation()

            await MainActor.run {
                self.shownStops = results
                self.isSearching = false
            }
        }
    }

    // MARK: - Setup

    private func setupBindings() {
        locationService.$isAuthorized
            .sink { [weak self] isAuthorized in
                guard let self = self else { return }
                self.isAuthorized = isAuthorized
                if !isAuthorized {
                    self.alertMessage = String(localized: "Location access required")
                    self.showAlert = true
                }
            }
            .store(in: &cancellables)

        $searchText
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.search()
            }
            .store(in: &cancellables)
    }

    // MARK: - Initial Data Loading

    private func loadInitialStops() {
        Task {
            await loadStops(for: .astana)
        }
    }

    private func loadStops(for city: CityStopsSource) async {
        allStops = await loadStopsUseCase.execute(for: city)
        stopGrid = GridCalculator.buildGrid(from: allStops)

        shownStops = allStops

        searchEngine = await SearchEngine(stops: allStops)

        print("✅ Загружены остановки для города: \(city.rawValue), количество: \(allStops.count)")

        await updateVisibleStops()
    }

    // MARK: - Visible Stops Management

    private func updateVisibleStops() async {
        guard !allStops.isEmpty else {
            visibleStops = []
            return
        }

        let filtered = await filterStopsUseCase.execute(
            stops: allStops,
            grid: stopGrid,
            mapState: mapState,
            currentCity: currentCity
        )

        visibleStops = filtered
    }

    private func scheduleVisibleStopsUpdate() {
        updateWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }

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

    // MARK: - Map Interactions

    func handleMapTap(at location: CGPoint, proxy: MapProxy?) {
        guard let coordinate = proxy?.convert(location, from: .local) else { return }

        withAnimation {
            selectedCoordinate = coordinate
            animateMarkerAppearance()
        }
    }

    private func animateMarkerAppearance() {
        markerScale = 1.0
        markerOpacity = 0.0

        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            markerScale = 1.0
            markerOpacity = 1.0
        }
    }

    func toCenter(by location: CLLocationCoordinate2D) {
        withAnimation {
            let region = MKCoordinateRegion(
                center: location,
                span: Constants.userLocationSpan
            )
            cameraPosition = .region(region)
            mapState = MapState(
                center: location,
                span: Constants.userLocationSpan
            )

            Task {
                await updateVisibleStops()
            }
        }
    }

    func centerToUserLocation() {
        guard let location = locationService.currentLocation else {
            alertMessage = String(localized: "Failed to determine location")
            showAlert = true
            return
        }

        withAnimation {
            let region = MKCoordinateRegion(
                center: location.coordinate,
                span: Constants.userLocationSpan
            )
            cameraPosition = .region(region)

            mapState = MapState(
                center: location.coordinate,
                span: Constants.userLocationSpan
            )

            Task {
                await updateVisibleStops()
            }
        }
    }

    func handleCameraChange(_ context: MapCameraUpdateContext) {
        let newState = MapState(
            center: context.region.center,
            span: context.region.span
        )

        guard mapState.hasSignificantChanges(comparedTo: newState) else {
            return
        }

        mapState = newState

        if let newCity = detectCityUseCase.execute(for: newState.center),
           newCity != currentCity
        {
            currentCity = newCity
            Task {
                await loadStops(for: newCity)
            }
        }

        scheduleVisibleStopsUpdate()
    }

    func stopMonitoring(id: String) {
        startedMonitoringsIDs.removeAll(where: { $0 == id })

        locationService.stopMonitoringById(id: id)
    }

    func stopMonitoring() {
        locationService.stopMonitoring()
    }

    // MARK: - Monitoring

    func startMonitoring() {
        guard let coordinate = selectedCoordinate else {
            alertMessage = String(localized: "Select a point first")
            showAlert = true
            return
        }
        let id = UUID().uuidString
        startedMonitoringsIDs.append(id)

        locationService.startMonitoring(at: coordinate, radius: radius, id: id)
        alertMessage = String(localized: "Monitoring started")
        showAlert = true

        saveLastSelectedCoordinate(coordinate)
    }

    // MARK: - Persistence

    private func saveLastSelectedCoordinate(_ coordinate: CLLocationCoordinate2D) {
        UserDefaults.standard.set(coordinate.latitude, forKey: "last_selected_lat")
        UserDefaults.standard.set(coordinate.longitude, forKey: "last_selected_lon")
    }

    func loadLastSelectedCoordinate() -> CLLocationCoordinate2D? {
        guard let lat = UserDefaults.standard.value(forKey: "last_selected_lat") as? Double,
              let lon = UserDefaults.standard.value(forKey: "last_selected_lon") as? Double
        else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    // MARK: - State Management

    func clearSelection() {
        withAnimation {
            selectedCoordinate = nil
            markerScale = 1.0
            markerOpacity = 0.0
        }
    }

    func updateRegion(center: CLLocationCoordinate2D, span: MKCoordinateSpan? = nil) {
        withAnimation {
            let region = MKCoordinateRegion(
                center: center,
                span: span ?? Constants.defaultSpan
            )
            cameraPosition = .region(region)

            mapState = MapState(
                center: center,
                span: span ?? Constants.defaultSpan
            )

            Task {
                await updateVisibleStops()
            }
        }
    }
}
