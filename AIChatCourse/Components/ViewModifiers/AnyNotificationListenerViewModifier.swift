//
//  AnyNotificationListenerViewModifier.swift
//  AIChatCourse
//
//  Created by sinduke on 6/4/25.
//

import SwiftUI

struct AnyNotificationListenerViewModifier: ViewModifier {
    
    let notificationName: Notification.Name
    let onNotificationReceived: @MainActor (Notification) -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: notificationName)) { notification in
                onNotificationReceived(notification)
            }
    }
}

extension View {
    func onNotificationReceieved(name: Notification.Name, action: @MainActor @escaping (Notification) -> Void) -> some View {
        modifier(AnyNotificationListenerViewModifier(notificationName: name, onNotificationReceived: action))
    }
}

/**
 代码封装的依据
 .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification), perform: { notification in

 })
 .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: { notification in
     Task {
         await checkUserStatus()
     }
 })
 */
