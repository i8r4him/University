//
//  Color+Hex.swift
//  University
//
//  Created by Ibrahim Abdullah on 17.12.24.
//

import SwiftUI

extension Color {
    func toHexString() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0; var g: CGFloat = 0; var b: CGFloat = 0; var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
    
    static func fromHexString(_ hex: String) -> Color {
        var hexString = hex
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        guard let rgbValue = UInt32(hexString, radix: 16) else {
            return Color.blue
        }
        let red = Double((rgbValue >> 16) & 0xff)/255
        let green = Double((rgbValue >> 8) & 0xff)/255
        let blue = Double(rgbValue & 0xff)/255
        return Color(red: red, green: green, blue: blue)
    }
}
