import Foundation

/// 1️⃣ Создаём обычный actor для выполнения работы
actor SearchEngineActor {
    // тут внутри будет очередь и методы search
}

/// 2️⃣ Создаём глобальный актор, который использует наш actor
@globalActor
struct SearchActor: GlobalActor {
    typealias ActorType = SearchEngineActor
    static let shared = SearchEngineActor()
}

@SearchActor
final class SearchEngine {
    /// Все остановки с предрасчитанным normalizedName
    private let allStops: [Stop]

    // Простой LRU-кэш (максимум 20 запросов)
    private var cache = [String: [Stop]]()
    private let cacheLimit = 20

    init(stops: [Stop]) {
        allStops = stops
    }

    // MARK: - Публичный API

    func search(query: String) async -> [Stop] {
        // Нормализуем запрос (сортируем буквы) – делаем один раз
        let normalizedQuery = String(query.lowercased().sorted())

        // Проверяем кэш
        if let cached = cache[normalizedQuery] {
            return cached
        }

        // Тяжёлая работа
        let results = performSearch(normalizedQuery: normalizedQuery)

        // Сохраняем в кэш (LRU – удаляем самый старый, если превышен лимит)
        cache[normalizedQuery] = results
        if cache.count > cacheLimit {
            if let oldestKey = cache.keys.first {
                cache.removeValue(forKey: oldestKey)
            }
        }

        return results
    }

    // MARK: - Приватная логика поиска

    private func performSearch(normalizedQuery: String) -> [Stop] {
        guard !normalizedQuery.isEmpty else { return [] }

        // Топ-20 результатов
        var topRated: [RateModel] = []
        var minIndex = 0 // индекс элемента с минимальным rate в topRated

        for stop in allStops {
            // 🔍 Дешёвые фильтры – отсекаем заведомо неподходящие
            // 1. Разница длин > 10 → точно не похоже
            if abs(normalizedQuery.count - stop.normalizedName.count) > 10 {
                continue
            }
            // 2. Первая буква должна совпадать (можно убрать, если нужно мягче)
            guard let qFirst = normalizedQuery.first,
                  let sFirst = stop.normalizedName.first,
                  qFirst == sFirst
            else {
                continue
            }

            // ⚡️ Быстрое вычисление процента сходства (на основе частот символов)
            let percent = similarity(normalizedQuery, stop.normalizedName)

            // Слишком низкое качество – пропускаем
            if percent < 30 { continue }

            let candidate = RateModel(rate: percent, value: stop)

            // 🎯 Поддержание топ-20 (приоритетная очередь через массив)
            if topRated.count < 20 {
                // Есть место – просто добавляем
                topRated.append(candidate)
                // Обновляем индекс минимума
                if topRated[minIndex].rate > candidate.rate {
                    minIndex = topRated.count - 1
                }
            } else {
                // Массив полон – заменяем, если кандидат лучше худшего
                if topRated[minIndex].rate < candidate.rate {
                    topRated[minIndex] = candidate
                    // Пересчитываем индекс нового минимума
                    minIndex = topRated.enumerated()
                        .min(by: { $0.element.rate < $1.element.rate })!
                        .offset
                }
            }
        }

        // Сортируем по убыванию релевантности и возвращаем только остановки
        return topRated
            .sorted { $0.rate > $1.rate }
            .map(\.value)
    }

    // MARK: - Быстрый similarity через частоты символов (O(n+m))

//    private func similarity(_ a: String, _ b: String) -> Int {
//        var freq = [Character: Int]()
//        for ch in b { freq[ch, default: 0] += 1 }
//
//        var matches = 0
//        for ch in a {
//            if let count = freq[ch], count > 0 {
//                matches += 1
//                freq[ch] = count - 1
//            }
//        }
//
//        let maxLen = max(a.count, b.count)
//        return maxLen == 0 ? 0 : matches * 100 / maxLen
//    }

    private func similarity(_ a: String, _ b: String) -> Int {
        let aChars = Array(a)
        let bChars = Array(b)
        let n = aChars.count
        let m = bChars.count

        if n == 0 { return m == 0 ? 100 : 0 }
        if m == 0 { return 0 }

        // Матрица (n+1)x(m+1)
        var dp = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)

        for i in 0 ... n {
            dp[i][0] = i
        }
        for j in 0 ... m {
            dp[0][j] = j
        }

        for i in 1 ... n {
            for j in 1 ... m {
                if aChars[i - 1] == bChars[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1]
                } else {
                    dp[i][j] = 1 + min(dp[i - 1][j - 1], min(dp[i][j - 1], dp[i - 1][j]))
                }
            }
        }

        let distance = dp[n][m]
        let maxLen = max(n, m)
        return maxLen == 0 ? 100 : max(0, 100 - distance * 100 / maxLen)
    }

    /// Очистка кэша (например, при смене города)
    func clearCache() {
        cache.removeAll()
    }
}

// MARK: - Вспомогательная структура для ранжирования

private struct RateModel {
    let rate: Int
    let value: Stop
}
