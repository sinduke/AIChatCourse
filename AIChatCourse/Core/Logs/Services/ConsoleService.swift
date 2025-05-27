//
//  ConsoleService.swift
//  AIChatCourse
//
//  Created by sinduke on 5/27/25.
//

import OSLog

// MARK: - 日志等级
enum LogType {
    // ℹ️ 普通信息
    case info
    // 📈 埋点 / 业务事件
    case analytic
    // ⚠️ 业务可恢复错误
    case warning
    // 🚨 致命异常
    case severe

    /// 对应 OSLogType
    var OSLogType: OSLogType {
        switch self {
        case .info:      return .info
        case .analytic:  return .default
        case .warning:   return .error
        case .severe:    return .fault
        }
    }

    /// 每个等级的可视化表情
    var emoji: String {
        switch self {
        case .info:      return "ℹ️"
        case .analytic:  return "📈"
        case .warning:   return "⚠️"
        case .severe:    return "🚨"
        }
    }
}

// MARK: - 日志系统
actor LogSystem {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "ConsoleLogger"
    )

    /// 真·写日志（actor 隔离）
    private func log(level: OSLogType, message: String) {
        logger.log(level: level, "\(message, privacy: .public)")
    }

    /// 对外非隔离接口 —— 自动 hop 回主隔离域
    nonisolated func log(level: LogType = LogType.analytic, message: String) {
        Task { await log(level: level.OSLogType, message: "\(level.emoji) \(message)") }
    }
}

struct ConsoleService: LogService {
    
    let logger = LogSystem()
    private let printParameters: Bool
    
    init(printParameters: Bool = true) {
        self.printParameters = printParameters
    }
    
    func identifyUser(userId: String, name: String?, email: String?) {
        let string = """
            Identify User
            userId: \(userId)
            name: \(name ?? "unknown")
            email: \(email ?? "unknown")
            """
        logger.log(level: LogType.info, message: string)
//        logger.log(level: LogType.analytic, message: string)
//        logger.log(level: LogType.warning, message: string)
//        logger.log(level: LogType.severe, message: string)
    }
    
    func addUserProperties(dict: [String: Any]) {
        var string = """
            Log User Properties
            """
        if printParameters {
            let sortedKeys = dict.keys.sorted()
            for key in sortedKeys {
                if let value = dict[key] {
                    string += "\n (key: \(key), value: \(value))"
                }
            }
        }
        
        logger.log(message: string)
    }
    
    func deleteUserProfile() {
        let string = """
            Delete User Profile
            """
        logger.log(message: string)
    }
    
    func trackEvent(event: any LoggableEvent) {
        var string = "\(event.eventName)"
        
        if printParameters, let parameters = event.parameters, !parameters.isEmpty {
            let sortedKeys = parameters.keys.sorted()
            for key in sortedKeys {
                if let value = parameters[key] {
                    string += "\n (key: \(key), value: \(value))"
                }
            }
        }
        
        logger.log(level: event.type, message: string)
    }
    
    func trackScreen(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}
