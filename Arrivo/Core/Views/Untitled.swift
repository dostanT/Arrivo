import SwiftUI

struct Untitled: View {
    @EnvironmentObject private var untitledVM: UntitledViewModel
    @StateObject private var mapVM: MapViewModel

    init() {
        let ILocationVM = LocationViewModel()
        let IMapVM = DependencyContainer.makeMapViewModel(locationService: ILocationVM)

        _mapVM = StateObject(wrappedValue: IMapVM)
    }

    var body: some View {
        TabView(selection: $untitledVM.selectedTab) {
            Group {
                NavigationStack {
                    ArrivoView()
                }
                .tag(TabEnum.arrivo)
                .tabItem {
                    Label(
                        TabEnum.arrivo.displayName,
                        systemImage: TabEnum.arrivo.iconName
                    )
                }

                NavigationStack {
                    MapView()
                }
                .tag(TabEnum.map)
                .tabItem {
                    Label(
                        TabEnum.map.displayName,
                        systemImage: TabEnum.map.iconName
                    )
                }

                NavigationStack {
                    SettingsView()
                }
                .tag(TabEnum.settings)
                .tabItem {
                    Label(
                        TabEnum.settings.displayName,
                        systemImage: TabEnum.settings.iconName
                    )
                }
            }
            .toolbarBackground(
                ColorConstants.background,
                for: .tabBar
            )
        }
        .sheet(item: $mapVM.activeSheet) { sheet in
            Group {
                switch sheet {
                case .oldMonitorings:
                    HistorySheetView()

                case .startedMonitorings:
                    ActiveSheetView()
                }
            }
            .environmentObject(mapVM)
        }
        .accentColor(ColorConstants.foreground)
        .environmentObject(mapVM)
    }
}
