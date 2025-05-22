//
//  Color+EXT.swift
//  AIChatCourse
//
//  Created by sinduke on 5/18/25.
//

import SwiftUI

public extension Color {
    /// 支持 `#RGB`, `#RRGGBB`, `#RGBA`, `#RRGGBBAA`
    init?(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.replacingOccurrences(of: "#", with: "")
        if hex.count == 3 || hex.count == 4 {
            hex = hex.map { "\($0)\($0)" }.joined()
        }
        guard let value = UInt64(hex, radix: 16) else { return nil }
        let r, g, b, a: Double // swiftlint:disable:this identifier_name
        switch hex.count {
        case 6:
            (r, g, b, a) = (
                Double((value >> 16) & 0xFF) / 255,
                Double((value >> 8) & 0xFF) / 255,
                Double(value & 0xFF) / 255,
                1.0
            )
        case 8:
            (r, g, b, a) = (
                Double((value >> 24) & 0xFF) / 255,
                Double((value >> 16) & 0xFF) / 255,
                Double((value >> 8) & 0xFF) / 255,
                Double(value & 0xFF) / 255
            )
        default:
            return nil
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    /// 输出 `#RRGGBB` 或 `#RRGGBBAA`, 可选
    func toHex(includeAlpha: Bool = false) -> String? {
        // swiftlint:disable identifier_name
#if canImport(UIKit)
        var uiColor = UIColor(self).resolvedColor(with: UITraitCollection.current)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
#elseif canImport(AppKit)
        guard let rgb = NSColor(self).usingColorSpace(.deviceRGB) else { return nil }
        let r = rgb.redComponent, g = rgb.greenComponent
        let b = rgb.blueComponent, a = rgb.alphaComponent
#endif
        // swiftlint:enable identifier_name
        let toInt = { (c: CGFloat) in Int(round(c * 255)) } // swiftlint:disable:this identifier_name
        return includeAlpha || a < 1
            ? String(format: "#%02X%02X%02X%02X", toInt(r), toInt(g), toInt(b), toInt(a))
            : String(format: "#%02X%02X%02X", toInt(r), toInt(g), toInt(b))
    }

    /// 输出非可选字符串，转换失败返回 `#000000` 或 `#000000FF`
    func asHex(includeAlpha: Bool = false) -> String {
        // 优先尝试可选方法
        if let hex = toHex(includeAlpha: includeAlpha) {
            return hex
        }
        // 转换失败时返回默认值
        return includeAlpha ? "#000000FF" : "#000000"
    }
}
