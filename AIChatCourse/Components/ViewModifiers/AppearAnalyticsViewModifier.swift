//
//  AppearAnalyticsViewModifier.swift
//  AIChatCourse
//
//  Created by sinduke on 5/28/25.
//

import SwiftUI

extension View {
    func screenAppearAnalytics(name: String) -> some View {
        modifier(AppearAnalyticsViewModifier(name: name))
    }
}

struct AppearAnalyticsViewModifier: ViewModifier {
    
    @Environment(LogManager.self) private var logManager
    let name: String
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                logManager.trackEvent(event: Event.appear(name: name))
            }
            .onDisappear {
                logManager.trackEvent(event: Event.disappear(name: name))
            }
    }
    
    enum Event: LoggableEvent {
        case appear(name: String)
        case disappear(name: String)
        
        var eventName: String {
            switch self {
            case .appear(name: let name):
                return "Screen_\(name)_Appear"
            case .disappear(name: let name):
                return "Screen_\(name)_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            nil
        }
        
        var type: LogType {
            .analytic
        }
    }
}
