//
//  ActiveSheet.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 28.02.2026.
//

enum ActiveSheet: Identifiable {
    case oldMonitorings
    case startedMonitorings

    var id: Int {
        hashValue
    }
}
