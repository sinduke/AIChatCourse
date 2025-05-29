//
//  Error+EXT.swift
//  AIChatCourse
//
//  Created by sinduke on 5/28/25.
//

import SwiftUI

extension Error {
    var eventParameters: [String: Any] {
        ["error_description": localizedDescription]
    }
}
