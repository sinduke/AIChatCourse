//
//  Date+EXT.swift
//  AIChatCourse
//
//  Created by sinduke on 5/17/25.
//

import Foundation

extension Date {
    /// 语义化时间偏移，支持正负值
    func addingTimeInterval(
        days: Int = 0,
        hours: Int = 0,
        minutes: Int = 0
    ) -> Date {
        let seconds =
            Double(days * 86_400) +     // 24 * 60 * 60
            Double(hours * 3_600) +
            Double(minutes * 60)
        return addingTimeInterval(seconds)
    }
}
