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
}

struct ActiveABTests: Codable {
    let createAccountTest: Bool
    
    init(createAccountTest: Bool) {
        self.createAccountTest = createAccountTest
    }
    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_20250610_CreateAccountTest"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest
        ]
        // 返回把Nil丢弃之后的值
        return dict.compactMapValues({ $0 })
    }
    
}

struct MockABTestsService: ABTestsService {
    let activeTests: ActiveABTests
//    let createAccountTest2: Bool
    init(createAccountTest: Bool? = nil) {
        self.activeTests = ActiveABTests(
            createAccountTest: createAccountTest ?? false
        )
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
        logManager?.addUserProperties(dict: activeTests.eventParameters, isHighPriority: false)
    }
    
}
