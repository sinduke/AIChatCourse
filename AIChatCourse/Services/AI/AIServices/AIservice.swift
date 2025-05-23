//
//  AIservice.swift
//  AIChatCourse
//
//  Created by sinduke on 5/23/25.
//

import SwiftUI

protocol AIservice: Sendable {
    func generateImage(input: String) async throws -> UIImage
}
