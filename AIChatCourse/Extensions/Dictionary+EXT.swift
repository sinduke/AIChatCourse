//
//  Dictionary+EXT.swift
//  AIChatCourse
//
//  Created by sinduke on 5/27/25.
//

// MARK: - Dictionary + Sort by Key
extension Dictionary where Key: Comparable {

    /// 返回 **排好序的元组数组**（不改变原字典）
    func sortedKeyValuePairs(ascending: Bool = true) -> [(key: Key, value: Value)] {
        sorted { ascending ? $0.key < $1.key : $0.key > $1.key }
    }

    /// 原地按 Key 重排字典（会重新构造插入顺序）
    ///
    /// > Swift 5 以后字典保持「插入顺序」，所以重新赋值即可改变遍历顺序。
    ///   ⚠️ 这会触发一次 O(*n* log *n*) 排序和 O(*n*) 重新插入的开销。
    mutating func sortByKey(ascending: Bool = true) {
        self = Dictionary(uniqueKeysWithValues: sortedKeyValuePairs(ascending: ascending))
    }
}

extension Dictionary where Key == String {
    mutating func first(upTo maxItems: Int) {
        var counter: Int = 0
        for (key, _) in self {
            if counter >= maxItems {
                removeValue(forKey: key)
            } else {
                counter += 1
            }
        }
    }
}
