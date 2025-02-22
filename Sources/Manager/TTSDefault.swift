//
//  File.swift
//  AmosTTS
//
//  Created by AmosFitness on 2024/10/16.
//

import AmosBase
import SwiftUI

extension SimpleDefaults.Keys {
    // 统计已使用的字数
    static let totalPlayedWord = Key<Int>("TTS_TotalPlayedWord", default: 0, iCloud: true)
    static let defaultConfig = Key<TTSConfig?>("TTS_DefaultConfig", iCloud: true)
}

extension TTSConfig: SimpleDefaults.Serializable {
    public static let bridge = TTSConfigBridge()
}

public struct TTSConfigBridge: SimpleDefaults.Bridge, Sendable {
    public typealias Value = TTSConfig
    public typealias Serializable = Data
    
    public func serialize(_ value: Value?) -> Serializable? {
        guard let value else {
            return nil
        }

        return value.toData()
    }

    public func deserialize(_ object: Serializable?) -> Value? {
        guard let object else {
            return nil
        }

        return object.decode(type: Value.self)
    }
}
