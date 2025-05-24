//
//  SwiftDataLocalAvatarPresistance.swift
//  AIChatCourse
//
//  Created by sinduke on 5/24/25.
//

import SwiftData
import SwiftUI

@MainActor
struct SwiftDataLocalAvatarPresistance: LocalAvatarPresistance {
    
    private let container: ModelContainer
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    init() {
        // 开发阶段一定要使用!  这时候错误可以第一时间发现(尽管这里一定不会出错)
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: AvatarEntry.self)
    }
    
    func addRecentAvatar(avatar: AvatarModel) throws {
        let entry = AvatarEntry(from: avatar)
        mainContext.insert(entry)
        try mainContext.save()
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        let descriptor = FetchDescriptor<AvatarEntry>(sortBy: [SortDescriptor(\.dateAdd, order: .reverse)])
        let entries = try mainContext.fetch(descriptor)
        return entries.map({ $0.toModel() })
    }
    
}
