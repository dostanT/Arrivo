enum TabEnum: String, CaseIterable {
    case arrivo = "Profile"
    case map = "Map"
    case settings = "Settings"

    var displayName: String {
        switch self {
        case .arrivo:
            return "Arrivo"
        case .map:
            return "Map"
        case .settings:
            return "Settings"
        }
    }

    var iconName: String {
        switch self {
        case .arrivo:
            return "bus.fill"
        case .map:
            return "map.fill"
        case .settings:
            return "gear"
        }
    }
}
