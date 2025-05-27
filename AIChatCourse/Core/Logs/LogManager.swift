//
//  LogManager.swift
//  AIChatCourse
//
//  Created by sinduke on 5/27/25.
//

import SwiftUI

@MainActor
@Observable
class LogManager {
    private let services: [LogService]
    
    init(services: [LogService] = []) {
        self.services = services
    }
    
    func identifyUser(userId: String, name: String?, email: String?) {
        broadcast { $0.identifyUser(userId: userId, name: name, email: email) }
    }
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        broadcast { $0.addUserProperties(dict: dict, isHighPriority: isHighPriority) }
    }
    
    func deleteUserProfile() {
        broadcast { $0.deleteUserProfile() }
    }
    // 第3层封装
    func trackEvent(eventName: String, parameters: [String: Any]? = nil, type: LogType = .analytic) {
        let event = AnyLoggableEvent(eventName: eventName, parameters: parameters, type: type)
        broadcast { $0.trackEvent(event: event) }
    }
    // 第2层封装
    func trackEvent(event: AnyLoggableEvent) {
        broadcast { $0.trackScreen(event: event) }
    }
    // 第1层封装
    func trackEvent(event: LoggableEvent) {
        broadcast { $0.trackScreen(event: event) }
    }
    
    func trackScreen(event: LoggableEvent) {
        broadcast { $0.trackScreen(event: event) }
    }
    
    private func broadcast(_ body: (LogService) -> Void) {
        services.forEach(body)
    }
}
