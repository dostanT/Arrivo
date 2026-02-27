//
//  CityStopsSource.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 09.02.2026.
//

enum CityStopsSource: String, CaseIterable, Equatable {
    case aktau = "Kazakhstan_Aktau_stops_parsed"
    case aktobe = "Kazakhstan_Aktobe_stops_parsed"
    case almaty = "Kazakhstan_Almaty_stops_parsed"
    case astana = "Kazakhstan_Astana_stops_parsed"
    case atyrau = "Kazakhstan_Atyrau_stops_parsed"
    case karaganda = "Kazakhstan_Karaganda_stops_parsed"
    case kokshetau = "Kazakhstan_Kokshetau_stops_parsed"
    case kostanaj = "Kazakhstan_Kostanaj_stops_parsed"
    case pavlodar = "Kazakhstan_Pavlodar_stops_parsed"
    case petropavlovsk = "Kazakhstan_Petropavlovsk_stops_parsed"
    case semej = "Kazakhstan_Semej_stops_parsed"
    case shchuchinsk = "Kazakhstan_Shchuchinsk_stops_parsed"
    case taldykorgan = "Kazakhstan_Taldykorgan_stops_parsed"
    case temirtau = "Kazakhstan_Temirtau_stops_parsed"
    case uralsk = "Kazakhstan_Uralsk_stops_parsed"

    var name: String {
        switch self {
        case .aktau:
            return "Актау"
        case .aktobe:
            return "Актобе"
        case .almaty:
            return "Алматы"
        case .astana:
            return "Астана"
        case .atyrau:
            return "Атырау"
        case .karaganda:
            return "Караганда"
        case .kokshetau:
            return "Кокшетау"
        case .kostanaj:
            return "Костанай"
        case .pavlodar:
            return "Павлодар"
        case .petropavlovsk:
            return "Петропавловск"
        case .semej:
            return "Семей"
        case .shchuchinsk:
            return "Щучинск"
        case .taldykorgan:
            return "Талдыкорган"
        case .temirtau:
            return "Темиртау"
        case .uralsk:
            return "Уральск"
        }
    }
}
