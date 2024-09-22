//
//  TTSConfig.swift
//  AmosVoice
//
//  Created by AmosFitness on 2023/4/6.
//

import Foundation

public struct TTSConfig: Codable, Identifiable, Sendable {
    public var id: UUID
    public var speaker: TTSSpeaker
    public var role: TTSRole?
    public var style: TTSStyle?
    public var styledegree: Double = 1 // 0.01 到 2
    // 语速
    public var rate: Double = 0 // -50% - 200%
    // 语气
    public var pitch: Double = 0 // 50% - 150%
    // 音量
    public var volume: Double = 100 // 0% - 100%

    public init(
        id: UUID = .init(),
        speaker: TTSSpeaker = .xiaomo,
        role: TTSRole? = nil,
        style: TTSStyle? = nil,
        styledegree: Double = 1,
        rate: Double = 0,
        pitch: Double = 0,
        volume: Double = 100
    ) {
        self.id = id
        self.speaker = speaker
        self.role = role
        self.style = style
        self.styledegree = styledegree
        self.rate = rate
        self.pitch = pitch
        self.volume = volume
    }
    
    public init(speakingVoice: String?) {
        let speaker = TTSSpeaker.speaker(from: speakingVoice)
        self.init(
            speaker: speaker ?? .systemTTSEngine
        )
    }
    
    /// 系统引擎的速度 0 - 1
    public var wrappedRate: Double {
        if speaker == .systemTTSEngine {
            if rate > 0 {
                // 0.55 - 1.0
                return 1 - (200 - rate) / 200 * 0.45
            }else {
                // 0 - 0.55
                return (rate + 50) / 50 * 0.55
            }
        }else {
            return rate
        }
    }
}

extension TTSConfig: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.speaker == rhs.speaker &&
        lhs.role == rhs.role &&
        lhs.style == rhs.style &&
        lhs.rate == rhs.rate
    }
}
