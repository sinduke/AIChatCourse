//
//  LogService.swift
//  AIChatCourse
//
//  Created by sinduke on 5/27/25.
//

protocol LogService: Sendable {
    func identifyUser(userId: String, name: String?, email: String?)
    func addUserProperties(dict: [String: Any], isHighPriority: Bool)
    func deleteUserProfile()
    
    func trackEvent(event: LoggableEvent)
    func trackScreen(event: LoggableEvent)
}
