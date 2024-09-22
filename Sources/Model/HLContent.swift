//
//  HLContent.swift
//  AmosVoice
//
//  Created by AmosFitness on 2024/4/8.
//

import Foundation
import SwiftUI

public struct HLContent {
    let isDebuging: Bool
    public var textColor: Color
    
    public let fullText: String
    public let allContent: [TTSContent]
    public let engine: TTSEngine
    
    public var textOffset: Int
    public var wordLength: Int
    public var playWord: String
    
    // 是否正在播放（控制播放按钮）
    public var isPlaying: Bool
    // 是否跳过回车（微软 TTS 需要跳过）
    public let isSkipReturn: Bool
    
    public let fontSize: CGFloat
    public let rowSpace: CGFloat
    
    public init(
        isDebuging: Bool = false,
        textColor: Color = .black,
        allContent: [TTSContent],
        engine: TTSEngine,
        textOffset: Int = 0,
        wordLength: Int = 0,
        playWord: String = .init(),
        isPlaying: Bool = false,
        fontSize: CGFloat = 18,
        rowSpace: CGFloat = 8
    ) {
        self.isDebuging = isDebuging
        self.textColor = textColor
        self.fullText = allContent.fullText
        self.allContent = allContent
        self.engine = engine
        self.textOffset = textOffset
        self.wordLength = wordLength
        self.playWord = playWord
        self.isPlaying = isPlaying
        self.isSkipReturn = engine == .ms
        self.fontSize = fontSize
        self.rowSpace = rowSpace
    }
    
    public func highlightedText(
        options: String.CompareOptions = []
    ) -> AttributedString {
        if isDebuging && (textOffset > 0 || wordLength > 0) {
            debugPrint("- 高亮播放进度 -")
            debugPrint("Total Text Count: \(fullText.count)")
            debugPrint("Offset: \(textOffset)")
            debugPrint("Length: \(wordLength)")
            if let range = Range(
                .init(
                    location: textOffset,
                    length: wordLength
                ),
                in: fullText
            ) {
                debugPrint("Select Word: \(fullText[range])")
            }
            debugPrint("Play Word: \(playWord)")
        }
        
        var offSet = textOffset
        // 计算有几个回车
        if isSkipReturn {
            let returnCount = countNewLines(
                before: textOffset,
                in: fullText
            )
            offSet += returnCount
        }
        // 计算高亮的起始位置和结束位置
        let endIndex = fullText.endIndex
        let totalCount = fullText.count
        let start = fullText.index(
            fullText.startIndex,
            offsetBy: min(offSet, totalCount),
            limitedBy: endIndex
        ) ?? endIndex
        let end = fullText.index(
            start,
            offsetBy: min(wordLength, totalCount - offSet),
            limitedBy: endIndex
        ) ?? endIndex
        
        // 选择前的文字
        let beforeText = String(fullText[..<start])
        // 选择的文字
        let selectedText = String(fullText[start..<end])
        // 选择后的文字
        let afterText = String(fullText[end...])
        
        // 转换为AttributedString
        var before = AttributedString(beforeText)
        var selected = AttributedString(selectedText)
        var after = AttributedString(afterText)
        
        // 设置文字显示的样式
        #if os(iOS)
        before.uiKit.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        selected.uiKit.backgroundColor = UIColor(Color.blue.opacity(0.3))
        selected.uiKit.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        after.uiKit.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        #elseif os(macOS)
        
        #endif
        
        // 合并前后的文字
        var attributedString = before + selected + after
        #if os(iOS)
        attributedString.uiKit.foregroundColor = UIColor(textColor)
        #elseif os(macOS)
                
        #endif
        // 设置文字的行距
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = rowSpace
        attributedString.paragraphStyle = paragraphStyle
        
        return attributedString
    }
    
    public func countNewLines(before textOffset: Int, in fullText: String) -> Int {
        // 首先检查textOffset是否在字符串的有效范围内
        guard textOffset >= 0 && textOffset <= fullText.count else {
            return 0
        }

        // 获取到textOffset位置之前的子字符串
        let index = fullText.index(fullText.startIndex, offsetBy: textOffset)
        let substring = fullText[..<index]

        // 计算子字符串中回车符的数量
        let newLinesCount = substring.filter { $0 == "\n" }.count

        return newLinesCount
    }
}

extension HLContent: Codable {
    public enum CodingKeys: String, CodingKey {
        case fullText
        case allContent
        case engine
        case textOffset
        case wordLength
        case playWord
        case isPlaying
        case isSkipReturn
        case fontSize
        case rowSpace
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fullText = try container.decode(String.self, forKey: .fullText)
        allContent = try container.decode([TTSContent].self, forKey: .allContent)
        engine = try container.decode(TTSEngine.self, forKey: .engine)
        textOffset = try container.decode(Int.self, forKey: .textOffset)
        wordLength = try container.decode(Int.self, forKey: .wordLength)
        playWord = try container.decode(String.self, forKey: .playWord)
        isPlaying = try container.decode(Bool.self, forKey: .isPlaying)
        isSkipReturn = try container.decode(Bool.self, forKey: .isSkipReturn)
        fontSize = try container.decode(CGFloat.self, forKey: .fontSize)
        rowSpace = try container.decode(CGFloat.self, forKey: .rowSpace)
        
        // 以下属性不参与编码储存
        isDebuging = false
        textColor = .black
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fullText, forKey: .fullText)
        try container.encode(allContent, forKey: .allContent)
        try container.encode(engine, forKey: .engine)
        try container.encode(textOffset, forKey: .textOffset)
        try container.encode(wordLength, forKey: .wordLength)
        try container.encode(playWord, forKey: .playWord)
        try container.encode(isPlaying, forKey: .isPlaying)
        try container.encode(isSkipReturn, forKey: .isSkipReturn)
        try container.encode(fontSize, forKey: .fontSize)
        try container.encode(rowSpace, forKey: .rowSpace)
    }
}
