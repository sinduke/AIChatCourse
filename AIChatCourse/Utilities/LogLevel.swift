//
//  LogLevel.swift
//  AIChatCourse
//
//  Created by sinduke on 5/20/25.
//

import SwiftUI

/**
 使用方式
 
  dLog("ERROR: anonymous sign in success: \(result.user.uid)", .error)
  dLog("INFO: anonymous sign in success: \(result.user.uid)", .info)
  dLog("WARNING: anonymous sign in success: \(result.user.uid)", .warning)
 */

enum LogLevel: String {
    case info = "INFO"
    case warning = "⚠️ WARNING"
    case error = "❌ ERROR"
}

func dLog(_ message: @autoclosure () -> Any,
          _ level: LogLevel = .info,
          function: String = #function,
          line: Int = #line) {
    #if DEBUG
    debugPrint("DEBUG: [\(level.rawValue)] [\(function):\(line)]: \(message())")
    #endif
}
