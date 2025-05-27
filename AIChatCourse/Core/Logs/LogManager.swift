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
    
    func addUserProperties(dict: [String: Any]) {
        broadcast { $0.addUserProperties(dict: dict) }
    }
    
    func deleteUserProfile() {
        broadcast { $0.deleteUserProfile() }
    }

    func trackEvent(event: LoggableEvent) {
        broadcast { $0.trackEvent(event: event) }
    }
    
    func trackScreen(event: LoggableEvent) {
        broadcast { $0.trackScreen(event: event) }
    }
    
    private func broadcast(_ body: (LogService) -> Void) {
        services.forEach(body)
    }
}
