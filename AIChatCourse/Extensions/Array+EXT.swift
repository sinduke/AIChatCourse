//
//  Array+EXT.swift
//  AIChatCourse
//
//  Created by sinduke on 5/26/25.
//

extension Array {
    /// 返回排序后的新数组（按 KeyPath 排序）
    func sortedByKeyPath<T: Comparable>(keyPath: KeyPath<Element, T>, ascending: Bool = true) -> [Element] {
        self
            .sorted {
                let lhs = $0[keyPath: keyPath]
                let rhs = $1[keyPath: keyPath]
                
                return ascending ? (lhs < rhs) : (lhs > rhs)
            }
    }
    
    /// 原地排序（按 KeyPath 排序）
    mutating func sortedByKeyPath<T: Comparable>(keyPath: KeyPath<Element, T>, ascending: Bool = true) {
        self
            .sort {
                let lhs = $0[keyPath: keyPath]
                let rhs = $1[keyPath: keyPath]
                
                return ascending ? (lhs < rhs) : (lhs > rhs)
            }
    }
}
