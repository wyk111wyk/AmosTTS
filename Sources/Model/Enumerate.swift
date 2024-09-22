//
//  Enumerate.swift
//  AmosVoice
//
//  Created by AmosFitness on 2024/4/3.
//

import Foundation
import SwiftUI

/// 播放的引擎
public enum TTSEngine: Codable, Sendable {
    case system, ms
    
    var title: String {
        switch self {
        case .system:
            return "系统TTS"
        case .ms:
            return "微软TTS"
        }
    }
}

/// 播放的状态
public enum PlayStatus: Sendable {
    case start, pause, stop
    case play(reading: (word:String, offset:Int, length:Int))
    case error(error: Error)
    
    public var name: String {
        switch self {
        case .start:
            return "开始"
        case .pause:
            return "暂停"
        case .stop:
            return "停止"
        case .play(let reading):
            return reading.word
        case .error(let error):
            return "错误：\(error.localizedDescription)"
        }
    }
    
    public var isPlaying: Bool {
        switch self {
        case .play:
            return true
        case .start, .pause:
            return true
        default:
            return false
        }
    }
}

/// 播放内容的类型
public enum ContentType: Hashable, Codable, Sendable {
    case text
    case pause(level: BreakLevel)
    
    public static func type(_ input: String) -> Self {
        if input == "text" {
            return .text
        }else {
            return .pause(level: .init(rawValue: input) ?? .medium)
        }
    }
    
    public var name: String {
        switch self {
        case .text:
            return "text"
        case .pause(let level):
            return level.rawValue
        }
    }
}

/// 停顿的类型
public enum BreakLevel: String, Codable, Sendable {
    case x_weak
    case weak
    case medium
    case strong
    case x_strong
    
    public func name() -> String {
        switch self {
        case .x_weak:
            return "极弱停顿"
        case .weak:
            return "弱停顿"
        case .medium:
            return "中停顿"
        case .strong:
            return "强停顿"
        case .x_strong:
            return "极强停顿"
        }
    }
    
    // 毫秒
    public func pause() -> Int {
        switch self {
        case .x_weak:
            return 250
        case .weak:
            return 500
        case .medium:
            return 750
        case .strong:
            return 1000
        case .x_strong:
            return 1250
        }
    }
    
    public static func allCases() -> [Self] {
        [.x_weak, .weak, .medium, .strong, .x_strong]
    }
}

public enum RateLevel: Sendable {
    case slow, normal, fast, superFast
    public static var allLevel: [Self] {
        [.slow, .normal, .fast, .superFast]
    }
    
    public var name: String {
        switch self {
        case .slow:
            return "慢速"
        case .normal:
            return "正常"
        case .fast:
            return "快速"
        case .superFast:
            return "飞快"
        }
    }
    
    public var rate: Double {
        switch self {
        case .slow:
            return -25
        case .normal:
            return 0
        case .fast:
            return 30
        case .superFast:
            return 60
        }
    }
    
    public static func level(_ rate: Double) -> Self {
        if rate < 0 {
            return .slow
        }else if rate < 10 {
            return .normal
        }else if rate < 40 {
            return .fast
        }else {
            return .superFast
        }
    }
}

public enum TTSGender: Int, Codable, Sendable {
    case female = 1
    case male = 2
    case girl = 3
    
    public func name() -> String {
        switch self {
        case .female:
            return "女性"
        case .male:
            return "男性"
        case .girl:
            return "小女孩"
        }
    }
    
    public func color() -> Color {
        switch self {
        case .female:
            return .purple
        case .male:
            return .blue
        case .girl:
            return .pink
        }
    }
}
