//
//  LogManager.swift
//  AIChatCourse
//
//  Created by sinduke on 5/27/25.
//

import SwiftUI

protocol LogService: Sendable {
    func identifyUser(userId: String, name: String?, email: String?)
    func addUserProperties(dict: [String: Any])
    func deleteUserProfile()
    
    func trackEvent(event: LoggableEvent)
    func trackScreen(event: LoggableEvent)
}

protocol LoggableEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
}

struct ConsoleService: LogService {
    func identifyUser(userId: String, name: String?, email: String?) {
        let string = """
            Identify User
            userId: \(userId)
            name: \(name ?? "unknown")
            email: \(email ?? "unknown")
            """
        print(string)
    }
    
    func addUserProperties(dict: [String : Any]) {
        var string = """
            Log User Properties
            """
        let sortedKeys = dict.keys.sorted()
        for key in sortedKeys {
            if let value = dict[key] {
                string += "\n (key: \(key), value: \(value))"
            }
        }
        
        print(string)
    }
    
    func deleteUserProfile() {
        var string = """
            Delete User Profile
            """
        print(string)
    }
    
    func trackEvent(event: any LoggableEvent) {
        var string = "\(event.eventName)"
        
        if let parameters = event.parameters, !parameters.isEmpty {
            let sortedKeys = parameters.keys.sorted()
            for key in sortedKeys {
                if let value = parameters[key] {
                    string += "\n (key: \(key), value: \(value))"
                }
            }
        }
        
        print(string)
    }
    
    func trackScreen(event: any LoggableEvent) {
        trackEvent(event: event)
    }
    
}

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
