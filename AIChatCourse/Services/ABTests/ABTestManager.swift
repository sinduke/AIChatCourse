//
//  ABTestManager.swift
//  AIChatCourse
//
//  Created by sinduke on 6/10/25.
//

import SwiftUI

enum CategoryRowTestOption: String, Codable, CaseIterable {
    case original, top, hidden
    
    static var `default`: Self {
        .original
    }
}

protocol ABTestsService {
    var activeTests: ActiveABTests { get }
//    var createAccountTest2: Bool { get }
    
    func saveUpdatedConfig(updatedTest: ActiveABTests) throws
}

struct ActiveABTests: Codable {
    private(set) var createAccountTest: Bool
    private(set) var onBoardingCommunityTest: Bool
    private(set) var categoryRowTest: CategoryRowTestOption
    
    init(createAccountTest: Bool, onBoardingCommunityTest: Bool, categoryRowTest: CategoryRowTestOption) {
        self.createAccountTest = createAccountTest
        self.onBoardingCommunityTest = onBoardingCommunityTest
        self.categoryRowTest = categoryRowTest
    }
    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_20250610_CreateAccountTest"
        case onBoardingCommunityTest = "_20250610_OnBCommunityTest"
        case categoryRowTest = "_20250610_CategoryRowTest"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "test\(CodingKeys.onBoardingCommunityTest.rawValue)": onBoardingCommunityTest,
            "test\(CodingKeys.categoryRowTest.rawValue)": categoryRowTest.rawValue
        ]
        // 返回把Nil丢弃之后的值
        return dict.compactMapValues({ $0 })
    }
    
    mutating func update(createAccountTest newValue: Bool) {
        createAccountTest = newValue
    }
    
    mutating func update(onBoardingCommunityTest newValue: Bool) {
        onBoardingCommunityTest = newValue
    }
    
    mutating func update(categoryRowTest newValue: CategoryRowTestOption) {
        categoryRowTest = newValue
    }
}

class MockABTestsService: ABTestsService {
    var activeTests: ActiveABTests
    //    let createAccountTest2: Bool
    init(createAccountTest: Bool? = nil, onBoardingCommunityTest: Bool? = nil, categoryRowTest: CategoryRowTestOption? = nil) {
        self.activeTests = ActiveABTests(
            createAccountTest: createAccountTest ?? false,
            onBoardingCommunityTest: onBoardingCommunityTest ?? false,
            categoryRowTest: categoryRowTest ?? .default
        )
    }
    
    func saveUpdatedConfig(updatedTest: ActiveABTests) throws {
        activeTests = updatedTest
    }
    
}

class LocalABTestService: ABTestsService {
    
    @UserDefault(
        key: ActiveABTests.CodingKeys.createAccountTest.rawValue,
        startingValue: .random()
    )
    private var createAccountTest: Bool
    
    @UserDefault(
        key: ActiveABTests.CodingKeys.onBoardingCommunityTest.rawValue,
        startingValue: .random()
    )
    private var onBoardingCommunityTest: Bool
    
    @UserDefaultEnum(
        key: ActiveABTests.CodingKeys.categoryRowTest.rawValue,
        startingValue: CategoryRowTestOption.allCases.randomElement()!
    )
    private var categoryRowTest: CategoryRowTestOption
    
    var activeTests: ActiveABTests {
        ActiveABTests(
            createAccountTest: createAccountTest,
            onBoardingCommunityTest: onBoardingCommunityTest,
            categoryRowTest: categoryRowTest
        )
    }
    
    init() {
        
    }
    
    func saveUpdatedConfig(updatedTest: ActiveABTests) throws {
        createAccountTest = updatedTest.createAccountTest
        onBoardingCommunityTest = updatedTest.onBoardingCommunityTest
        categoryRowTest = updatedTest.categoryRowTest
    }
    
}

@MainActor
@Observable
class ABTestManager {
    // 协议
    private let service: ABTestsService
    // Struct
    private let logManager: LogManager?
    // Struct
    var activeTests: ActiveABTests
    
    init(service: ABTestsService, logManager: LogManager? = nil) {
        self.service = service
        self.activeTests = service.activeTests
        self.logManager = logManager
        
        self.configure()
        
    }
    
    private func configure() {
        activeTests = service.activeTests
        logManager?.addUserProperties(dict: activeTests.eventParameters, isHighPriority: false)
    }
    
    func override(updateTest: ActiveABTests) throws {
        try service.saveUpdatedConfig(updatedTest: updateTest)
        configure()
    }
    
}
