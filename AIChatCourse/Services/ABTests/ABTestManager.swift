//
//  ABTestManager.swift
//  AIChatCourse
//
//  Created by sinduke on 6/10/25.
//

import SwiftUI

protocol ABTestsService {
    var activeTests: ActiveABTests { get }
//    var createAccountTest2: Bool { get }
    
    func saveUpdatedConfig(updatedTest: ActiveABTests) throws
}

struct ActiveABTests: Codable {
    private(set) var createAccountTest: Bool
    private(set) var onBoardingCommunityTest: Bool
    
    init(createAccountTest: Bool, onBoardingCommunityTest: Bool) {
        self.createAccountTest = createAccountTest
        self.onBoardingCommunityTest = onBoardingCommunityTest
    }
    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_20250610_CreateAccountTest"
        case onBoardingCommunityTest = "_20250610_OnBCommunityTest"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "test\(CodingKeys.onBoardingCommunityTest.rawValue)": onBoardingCommunityTest
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
}

class MockABTestsService: ABTestsService {
    var activeTests: ActiveABTests
    //    let createAccountTest2: Bool
    init(createAccountTest: Bool? = nil, onBoardingCommunityTest: Bool? = nil) {
        self.activeTests = ActiveABTests(
            createAccountTest: createAccountTest ?? false,
            onBoardingCommunityTest: onBoardingCommunityTest ?? false
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
    
    var activeTests: ActiveABTests {
        ActiveABTests(createAccountTest: createAccountTest, onBoardingCommunityTest: onBoardingCommunityTest)
    }
    
    init() {
        
    }
    
    func saveUpdatedConfig(updatedTest: ActiveABTests) throws {
        createAccountTest = updatedTest.createAccountTest
        onBoardingCommunityTest = updatedTest.onBoardingCommunityTest
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
