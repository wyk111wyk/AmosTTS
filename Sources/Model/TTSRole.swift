//
//  TTSRole.swift
//  AmosVoice
//
//  Created by AmosFitness on 2023/4/5.
//

import SwiftUI
import AmosBase

public struct TTSRole: Codable, Hashable, SimplePickerItem {
    public var titleColor: Color?
    
    public var iconName: String?
    public var systemImage: String?
    public var contentSystemImage: String?
    public var content: String?
    
    public let role, title, instruction: String
    
    public static let fileName = "tts_roles.json"
    public static let allRoles: [TTSRole] = fileName.getFileFromBundle(bundle: .module) ?? []
    public static let noneRole: TTSRole = .init(role: "none", title: "无", instruction: "无特定角色")
    
    public static func role(from name: String) -> TTSRole? {
        Self.allRoles.first { $0.role == name }
    }
}

extension TTSRole: Identifiable, Equatable, Sendable {
    public var id: String { role }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.role == rhs.role
    }
}
