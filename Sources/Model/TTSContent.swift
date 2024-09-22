//
//  TTSContent.swift
//  AmosVoice
//
//  Created by AmosFitness on 2023/4/6.
//

import Foundation
import AmosBase

public struct TTSContent: Identifiable, Codable, Sendable {
    
    public let id: UUID
    public var type: ContentType
    // 播报的文字内容
    public var speechText: String
    // 自定义播放属性 / 全局播放属性
    public var useDefaultConfig: Bool
    // 播报属性
    public var config: TTSConfig
    
    public init(id: UUID = UUID(),
         type: ContentType = .text,
         speechText: String = "",
         useDefaultConfig: Bool = true,
         config: TTSConfig = .init()) {
        self.id = id
        self.type = type
        self.speechText = speechText
        self.useDefaultConfig = useDefaultConfig
        self.config = config
    }
    
    public enum CodingKeys: String, CodingKey {
        case id, type, speechText, useDefaultConfig, config
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.speechText, forKey: .speechText)
        try container.encode(self.useDefaultConfig, forKey: .useDefaultConfig)
        try container.encode(self.config, forKey: .config)
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.type = try container.decode(ContentType.self, forKey: .type)
        self.speechText = try container.decode(String.self, forKey: .speechText)
        self.useDefaultConfig = try container.decode(Bool.self, forKey: .useDefaultConfig)
        self.config = try container.decode(TTSConfig.self, forKey: .config)
    }
    
    public mutating func emptyStyle() {
        self.config.style = .noneStyle
    }
    
    public mutating func emptyRole() {
        self.config.role = .noneRole
    }
    
    public mutating func defautConfig() {
        self.config = .init()
    }
}

extension TTSContent {
    public static func example(_ textType: String.TestType) -> TTSContent {
        .init(speechText: textType.content)
    }
    
    public static func pause(_ level: BreakLevel) -> TTSContent {
        .init(type: .pause(level: level))
    }
}

extension Array where Element == TTSContent {
    public var fullText: String {
        let pureText = self.reduce("") { partialResult, content in
            if partialResult.isNotEmpty {
                partialResult + "\n" + content.speechText
            }else {
                partialResult + content.speechText
            }
        }
        return pureText
    }
    
    public func allTextType() -> [TTSContent] {
        self.filter { cont in
            cont.type == .text
        }
    }
}
