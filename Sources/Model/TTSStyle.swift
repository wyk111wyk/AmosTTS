//
//  TTSStyle.swift
//  AmosVoice
//
//  Created by AmosFitness on 2023/4/5.
//

import SwiftUI
import AmosBase

public struct TTSStyle: Codable, Hashable, SimplePickerItem {
    public var titleColor: Color?
    
    public var iconName: String?
    public var systemImage: String?
    public var contentSystemImage: String?
    public var content: String?
    public let style, title, instruction: String
    
    public static let fileName = "tts_styles.json"
    public static let allStyles: [TTSStyle] = fileName.getFileFromBundle(bundle: .module) ?? []
    public static let noneStyle: TTSStyle = .init(style: "none", title: "无", instruction: "无特定语气")
    
    public static func style(from name: String) -> TTSStyle? {
        Self.allStyles.first { $0.style == name }
    }
}

extension TTSStyle: Identifiable, Equatable, Sendable {
    public var id: String { style }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.style == rhs.style
    }
}
