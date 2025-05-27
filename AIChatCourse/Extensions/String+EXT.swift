//
//  String+EXT.swift
//  AIChatCourse
//
//  Created by sinduke on 5/28/25.
//

import Foundation

extension String {
    static func convertToString(_ value: Any) -> String? {
        switch value {
        case let value as String:
            return value
        case let value as Int:
            return String(value)
        case let value as Double:
            return String(value)
        case let value as Float:
            return String(value)
        case let value as Bool:
            return String(value)
        case let value as Date:
            return value.formatted(date: .abbreviated, time: .shortened)
        case let array as [Any]:
            return array.compactMap({ String.convertToString($0) }).sorted().joined(separator: ", ")
        case let value as CustomStringConvertible:
            return value.description
        default:
            return nil
        }
    }
}

extension String {
    func clipped(maxCharacters: Int) -> String {
        String(prefix(maxCharacters))
    }
    
    func replaceSpacesWithUnderscores() -> String {
        self.replacingOccurrences(of: " ", with: "_")
    }
    
}
