enum TabEnum: String, CaseIterable {
    case profile = "Profile"
    case map = "Map"
    case settings = "Settings"
    
    var displayName: String {
        switch self {
        case .profile:
            return "Profile"
        case .map:
            return "Map"
        case .settings:
            return "Settings"
        }
    }
    
    var iconName: String {
        switch self {
        case .profile:
            return "person" // неактивная
        case .map:
            return "map" // неактивная
        case .settings:
            return "gearshape" // неактивная
        }
    }
    
    var selectedIconName: String {
        switch self {
        case .profile:
            return "person.fill" // активная
        case .map:
            return "map.fill" // активная
        case .settings:
            return "gearshape.fill" // активная
        }
    }
}
