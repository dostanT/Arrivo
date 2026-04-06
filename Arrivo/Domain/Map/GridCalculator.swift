//
//  GridCalculator.swift
//  Arrivo
//

enum GridCalculator {
    static let defaultCellSize: Double = 0.02

    static func buildGrid(from stops: [Stop], cellSize: Double = defaultCellSize) -> [GridKey: [Stop]] {
        var grid: [GridKey: [Stop]] = [:]

        for stop in stops {
            let x = Int(stop.coordinate.latitude / cellSize)
            let y = Int(stop.coordinate.longitude / cellSize)
            let key = GridKey(x: x, y: y)
            grid[key, default: []].append(stop)
        }

        return grid
    }

    static func relevantCells(
        for center: GeoCoordinate,
        latitudeDelta: Double,
        longitudeDelta: Double,
        cellSize: Double = defaultCellSize
    ) -> [GridKey] {
        let latRange = center.latitude - latitudeDelta / 2 ... center.latitude + latitudeDelta / 2
        let lonRange = center.longitude - longitudeDelta / 2 ... center.longitude + longitudeDelta / 2

        let minX = Int(latRange.lowerBound / cellSize)
        let maxX = Int(latRange.upperBound / cellSize)
        let minY = Int(lonRange.lowerBound / cellSize)
        let maxY = Int(lonRange.upperBound / cellSize)

        var cells: [GridKey] = []
        for x in minX ... maxX {
            for y in minY ... maxY {
                cells.append(GridKey(x: x, y: y))
            }
        }
        return cells
    }
}
