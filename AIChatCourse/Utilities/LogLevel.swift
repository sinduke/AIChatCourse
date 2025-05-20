//
//  LogLevel.swift
//  AIChatCourse
//
//  Created by sinduke on 5/20/25.
//


import SwiftUI

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
    print("DEBUG [\(level.rawValue)] [\(function):\(line)]: \(message())")
    #endif
}
