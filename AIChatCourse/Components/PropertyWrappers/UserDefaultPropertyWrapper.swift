//
//  UserDefaultPropertyWrapper.swift
//  AIChatCourse
//
//  Created by sinduke on 6/19/25.
//

import SwiftUI

// MARK: - PropertyWrapper ----------------------------------------------------

@propertyWrapper
struct UserDefault<Value: UserDefaultCompatible> {
    private let key: String
    private let startingValue: Value
    private let store: UserDefaults

    init(key: String,
         startingValue: Value,
         store: UserDefaults = .standard) {
        self.key = key
        self.startingValue = startingValue
        self.store = store
    }
    
    var wrappedValue: Value {
        get {
            if let saved = store.object(forKey: key) as? Value {
                return saved
            } else {
                store.set(startingValue, forKey: key)
                return startingValue
            }
        }
        set { store.set(newValue, forKey: key) }
    }

    // 便于测试时移除
    var projectedValue: Self { self }
    func remove() { store.removeObject(forKey: key) }
}

// MARK: - 支持的基础类型 ------------------------------------------------------

protocol UserDefaultCompatible {}
// swiftlint:disable colon
extension Bool:    UserDefaultCompatible {}
extension Int:     UserDefaultCompatible {}
extension Float:   UserDefaultCompatible {}
extension Double:  UserDefaultCompatible {}
extension String:  UserDefaultCompatible {}
extension URL:     UserDefaultCompatible {}
// swiftlint:enable colon
