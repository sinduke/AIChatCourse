//
//  LogService.swift
//  AIChatCourse
//
//  Created by sinduke on 5/27/25.
//

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
    var type: LogType { get }
}
