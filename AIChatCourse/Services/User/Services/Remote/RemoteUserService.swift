//
//  RemoteUserService.swift
//  AIChatCourse
//
//  Created by sinduke on 5/22/25.
//

import SwiftUI

protocol RemoteUserService: Sendable {
    func saveUser(user: UserModel) async throws
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error>
    func deleteUser(userId: String) async throws
    func onBoardingCompleted(userId: String, profileColorHex: String) async throws
}
