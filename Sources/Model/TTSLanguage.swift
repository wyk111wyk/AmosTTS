//
//  TTSLanguage.swift
//  AmosVoice
//
//  Created by AmosFitness on 2024/4/8.
//

import Foundation

public enum TTSLanguage: String, Codable, Sendable {
    case system = "系统"
    case cn = "中文"
    case jp = "日语"
    case en = "英语"
    case ko = "韩语"
    case multi = "多语言"
    
    public var engine: TTSEngine {
        switch self {
        case .system:
            return .system
        case .cn, .jp, .en, .ko, .multi:
            return .ms
        }
    }
    
    public func iconName() -> String {
        switch self {
        case .system:
            return "book.closed"
        case .cn:
            return "character.book.closed.zh"
        case .jp:
            return "character.book.closed.ja"
        case .en:
            return "character.book.closed"
        case .ko:
            return "character.book.closed.ko"
        case .multi:
            return "character.book.closed.he"
        }
    }
    
    public func testSpeech(_ name: String) -> String {
        var inputText: String
        switch self {
        case .system :
            inputText = "你好，我是系统语音合成引擎，很高兴为你服务。"
        case .cn:
            inputText = "你好，我的名字叫\(name)，很高兴为你服务。"
        case .jp:
            inputText = "こんにちは、私の名前は\(name)です。あなたのお役に立てることをうれしく思います。"
        case .en:
            inputText = "Hello, my name is \(name), and I am glad to serve you."
        case .ko:
            inputText = "안녕하세요, 저의 이름은 \(name)입니다. 당신을 도와드릴 수 있어 기쁩니다."
        case .multi:
            inputText = "你好，我的名字叫\(name)，很高兴为你服务。"
        }
        return inputText
    }
}
