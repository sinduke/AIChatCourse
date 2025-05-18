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
        // 1⃣️ 清理输入
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.replacingOccurrences(of: "#", with: "")
        
        // 2⃣️ 3/4 位扩充到 6/8 位
        if hex.count == 3 || hex.count == 4 {
            hex = hex.map { "\($0)\($0)" }.joined()
        }
        
        guard let value = UInt64(hex, radix: 16) else { return nil }
        
        let r, g, b, a: Double // swiftlint:disable:this identifier_name
        switch hex.count {
        case 6:              // RRGGBB
            (r, g, b, a) = (
                Double((value >> 16) & 0xFF) / 255,
                Double((value >> 8) & 0xFF) / 255,
                Double(value & 0xFF) / 255,
                1.0
            )
        case 8:              // RRGGBBAA
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
    
    /// 输出 `#RRGGBB` 或 `#RRGGBBAA`
    func toHex(includeAlpha: Bool = false) -> String? {
#if canImport(UIKit)
        var uiColor = UIColor(self)
        uiColor = uiColor.resolvedColor(with: UITraitCollection.current)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0 // swiftlint:disable:this identifier_name
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
#elseif canImport(AppKit)
        guard let rgb = NSColor(self).usingColorSpace(.deviceRGB) else { return nil }
        let r = rgb.redComponent, g = rgb.greenComponent // swiftlint:disable:this identifier_name
        let b = rgb.blueComponent, a = rgb.alphaComponent // swiftlint:disable:this identifier_name
#endif
        let toInt = { (c: CGFloat) in Int(round(c * 255)) } // swiftlint:disable:this identifier_name
        return includeAlpha || a < 1
            ? String(format: "#%02X%02X%02X%02X", toInt(r), toInt(g), toInt(b), toInt(a))
            : String(format: "#%02X%02X%02X", toInt(r), toInt(g), toInt(b))
    }
}
