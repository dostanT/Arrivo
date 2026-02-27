////
////  Limiter.swift
////  ArrivoNuvuCollection
////
////  Created by Dostan Turlybek on 11.02.2026.
////
//
// @propertyWrapper
// struct Limiter<T: RateProtocol> {
//    var value: [T]
//    let limit: Int
//    var wrappedValue: [T] {
//        get {
//            value.sorted(by: {$0.rate > $1.rate})
//        }
//        set {
//            value.append(contentsOf: newValue)
//        }
//    }
//
//    init(wrappedValue: [T], limit: Int) {
//        self.value = wrappedValue
//        self.limit = limit
//    }
//
//    var projectedValue: Bool {
//        value.count >= limit
//    }
// }
