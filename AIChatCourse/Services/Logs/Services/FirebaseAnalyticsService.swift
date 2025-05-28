//
//  FirebaseAnalyticsService.swift
//  AIChatCourse
//
//  Created by sinduke on 5/27/25.
//

import SwiftUI
import FirebaseAnalytics

fileprivate extension String {
    // 高阶
    func clean(maxCharacters: Int) -> String {
        self
            .clipped(maxCharacters: maxCharacters)
            .replaceSpacesWithUnderscores()
    }
}

struct FirebaseAnalyticsService: LogService {
    
    func identifyUser(userId: String, name: String?, email: String?) {
        Analytics.setUserID(userId)
        if let name {
            Analytics.setUserProperty(name, forName: "account_name")
        }
        if let email {
            Analytics.setUserProperty(email, forName: "account_email")
        }
    }
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        guard isHighPriority else { return }
        for (key, value) in dict {
            if let string = String.convertToString(value) {
                
                let key = key.clean(maxCharacters: 40)
                let string = string.clean(maxCharacters: 100)
                Analytics.setUserProperty(string, forName: key)
            }
        }
    }
    
    func deleteUserProfile() {
        
    }
    
    func trackEvent(event: any LoggableEvent) {
        var parameters = event.parameters ?? [:]
        // 修复类型错误
        for (key, value) in parameters {
            if let date = value as? Date, let string = String.convertToString(date) {
                parameters[key] = string
            } else if let array = value as? [Any] {
                if let string = String.convertToString(array) {
                    parameters[key] = string
                } else {
                    parameters[key] = nil
                }
            }
        }
        
        // 修复key长度错误问题
        for (key, value) in parameters where key.count > 40 {
            parameters.removeValue(forKey: key)
            let newKey = key.clean(maxCharacters: 40)
            parameters[newKey] = value
        }
//        var cleaned: [String: Any] = [:]
//
//        for (key, value) in parameters where key.count > 40 {
//            let newKey = key.clean(maxCharacters: 40)
//            cleaned[newKey] = value
//        }
//
//        // 2️⃣ 把原来需要保留的 + 新 key 一起合并
//        parameters.merge(cleaned) { (_, new) in new }
//
//        // 3️⃣ (可选) 删除旧的超长 key
//        for key in cleaned.keys {
//            parameters.removeValue(forKey: key)
//        }
//        
//        // 修复value长度错误问题
//        for (key, value) in parameters {
//            if let string = value as? String {
//                if string.count > 100 {
//                    parameters[key] = string.clean(maxCharacters: 100)
//                }
//            }
//        }
        
        parameters.first(upTo: 25)
        let name = event.eventName.clean(maxCharacters: 40)
        
        Analytics.logEvent(name, parameters: parameters.isEmpty ? nil : parameters)
    }
    
    func trackScreen(event: any LoggableEvent) {
        let name = event.eventName.clean(maxCharacters: 40)
        // 常用且特殊的方法
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: name
        ])
    }
    
}
