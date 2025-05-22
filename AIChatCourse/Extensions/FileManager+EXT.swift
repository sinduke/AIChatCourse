//
//  FileManager+EXT.swift
//  AIChatCourse
//
//  Created by sinduke on 5/22/25.
//

import SwiftUI

public extension FileManager {
    /// 保存 Codable 模型到 Documents 目录下的 .txt 文件
    ///
    /// - Parameters:
    ///   - key: 文件名（不带扩展名）
    ///   - value: 可选的 Codable 模型实例，为 nil 时将删除对应文件
    /// - Throws: 编码或写入过程中的错误
    static func saveDocument<T: Codable>(key: String, value: T?) throws {
        let fileURL = documentsDirectory.appendingPathComponent("\(key).txt")

        // 如果 value 为 nil，则删除文件
        if value == nil {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            return
        }

        // 编码为 JSON 数据
        let data = try JSONEncoder().encode(value)

        // 写入文件（原子操作）
        try data.write(to: fileURL)
    }

    /// 从 Documents 目录下读取 .txt 文件并解码为 Codable 模型
    ///
    /// - Parameter key: 文件名（不带扩展名）
    /// - Returns: 解码后的模型实例，如果文件不存在或解码失败则返回 nil
    static func getDocument<T: Codable>(key: String) -> T? {
        let fileURL = documentsDirectory.appendingPathComponent("\(key).txt")
        let fileManager = FileManager.default

        // 文件不存在时返回 nil
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        // 读取数据并解码
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    /// 应用的 Documents 目录 URL
    private static var documentsDirectory: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
    }
}
