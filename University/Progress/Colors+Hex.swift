//
//  Color+Hex.swift
//  University
//
//  Created by Ibrahim Abdullah on 19.12.24.
//

import SwiftUI

extension Color {
    /// Initializes a Color from a hex string.
    /// - Parameter hex: The hex string, e.g., "#FF5733" or "FF5733".
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }

        var rgbValue: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgbValue) else { return nil }

        switch hexSanitized.count {
        case 6:
            self.init(
                .sRGB,
                red: Double((rgbValue & 0xFF0000) >> 16) / 255,
                green: Double((rgbValue & 0x00FF00) >> 8) / 255,
                blue: Double(rgbValue & 0x0000FF) / 255,
                opacity: 1.0
            )
        case 8:
            self.init(
                .sRGB,
                red: Double((rgbValue & 0xFF000000) >> 24) / 255,
                green: Double((rgbValue & 0x00FF0000) >> 16) / 255,
                blue: Double((rgbValue & 0x0000FF00) >> 8) / 255,
                opacity: Double(rgbValue & 0x000000FF) / 255
            )
        default:
            return nil
        }
    }

    /// Converts a Color to its hex string representation.
    /// - Returns: A hex string, e.g., "#FF5733" or `nil` if conversion fails.
    func toHexString() -> String? {
        // Convert Color to UIColor to access RGBA components
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        #elseif canImport(AppKit)
        let uiColor = NSColor(self)
        #endif

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        #if canImport(UIKit)
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #elseif canImport(AppKit)
        uiColor.usingColorSpace(.deviceRGB)?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #endif

        guard alpha == 1.0 else { return nil }

        let rgb: Int = (Int(red * 255) << 16) |
                       (Int(green * 255) << 8) |
                       Int(blue * 255)

        return String(format: "#%06X", rgb)
    }
}
