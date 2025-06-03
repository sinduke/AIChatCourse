//
//  PushManager.swift
//  AIChatCourse
//
//  Created by sinduke on 6/3/25.
//

import SwiftUI

@MainActor
@Observable
class PushManager {
    
    private let logManager: LogManager?

    init(logManager: LogManager? = nil) {
        self.logManager = logManager
    }

    func requestAuthorization() async throws -> Bool {
        let isAuthorized = try await LNotifications.requestAuthorization()
        logManager?.addUserProperties(dict: ["push_notifications_authorized": isAuthorized], isHighPriority: true)
        return isAuthorized
    }
    
    func canRequestAuthorization() async -> Bool {
        await LNotifications.canRequestAuthorization()
    }

    func schedulePushNotificationsForNextWeek() {
        LNotifications.removeAllPendingNotifications()
        LNotifications.removeAllDeliveredNotifications()
        
        Task {
            do {
                try await scheduleNotification(
                    title: "Hey you! Ready to Chat?",
                    subtitle: "AI Chat is already waiting for you.",
                    triggerDate: Date().addingTimeInterval(days: 1)
                )
                try await scheduleNotification(
                    title: "Hey you! Ready to Chat?",
                    subtitle: "AI Chat send you a reminder.",
                    triggerDate: Date().addingTimeInterval(days: 3)
                )
                try await scheduleNotification(
                    title: "Hey you! Ready to Chat?",
                    subtitle: "Don't miss out on your daily chat.",
                    triggerDate: Date().addingTimeInterval(days: 5)
                )
                logManager?.trackEvent(event: Event.weekSchedulePushNotificationSuccess)
            } catch {
                logManager?.trackEvent(event: Event.weekSchedulePushNotificationFailure(error: error))
            }
        }
        
    }
    
    private func scheduleNotification(title: String, subtitle: String, triggerDate: Date) async throws {
        let content = AnyNContent(
            title: title,
            body: subtitle,
        )
        let trigger = NTriggerOption.date(date: triggerDate, repeats: false)
        try await LNotifications.scheduleNotification(content: content, trigger: trigger)
    }
    
    enum Event: LoggableEvent {
        case weekSchedulePushNotificationSuccess
        case weekSchedulePushNotificationFailure(error: Error)
        
        var eventName: String {
            switch self {
            case .weekSchedulePushNotificationSuccess: return "PushManager_WeekSchedule_Success"
            case .weekSchedulePushNotificationFailure: return "PushManager_WeekSchedule_Failure"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .weekSchedulePushNotificationFailure(let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .weekSchedulePushNotificationFailure:
                return .severe
            default:
                return .analytic
            }
        }
        
    }
    
}
