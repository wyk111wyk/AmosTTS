//
//  File.swift
//  AmosTTS
//
//  Created by AmosFitness on 2024/9/20.
//

import Foundation
import AVFAudio
import AmosBase
import SwiftUI

extension AVSpeechSynthesizer: @unchecked @retroactive Sendable {}

class SystemTTSEngine: NSObject, @unchecked Sendable {
    let systemSynthesizer = AVSpeechSynthesizer()
    var speechCallBack: (PlayStatus) -> Void = {_ in}
    
    override init() {}
    
    /// 开始播放 / 停止播放
    func play(
        for allContent: [TTSContent],
        defaultConfig: TTSConfig,
        speechCallBack: @escaping (PlayStatus) -> Void
    ) {
        if systemSynthesizer.isSpeaking {
            systemSynthesizer.stopSpeaking(at: .word)
        }else {
            debugPrint("系统TTS：开始播放")
            
            self.speechCallBack = speechCallBack
            systemSynthesizer.delegate = self
            
            let allText: String = allContent.fullText
            
            let utterance = AVSpeechUtterance(string: allText)
            
            // Configure the utterance.
            var baseRate: Float = 0.53
            var language: String? = nil
            
            if let possibleLanguage = SimpleLanguage().detectLanguage(
                for: allText
            )?.rawValue, possibleLanguage.hasPrefix("en") {
                language = possibleLanguage
            }
            
            baseRate = defaultConfig.wrappedRate.toFloat
            utterance.rate = baseRate
            utterance.postUtteranceDelay = 0.5
            utterance.volume = 1.0
            utterance.voice = AVSpeechSynthesisVoice(language: language)
            
            systemSynthesizer.speak(utterance)
        }
    }
}

// 系统TTS委托代理
extension SystemTTSEngine: AVSpeechSynthesizerDelegate {
    // 开始播放
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        debugPrint("TTS - 开始播放")
        self.speechCallBack(.start)
    }
    // 暂停播放
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        debugPrint("TTS - 暂停播放")
        self.speechCallBack(.pause)
    }
    // 取消播放
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        debugPrint("TTS - 取消播放")
        self.speechCallBack(.stop)
    }
    // 停止播放
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        debugPrint("TTS - 停止播放")
        self.speechCallBack(.stop)
    }
    // 继续播放
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        debugPrint("TTS - 继续播放")
    }
    // 播放进度
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let fullText = utterance.speechString as NSString
        let subString = fullText.substring(with: characterRange)
        self.speechCallBack(
            .play(
                reading: (
                    String(subString).firstCharacters(count: 8),
                    characterRange.location,
                    characterRange.length
                )
            )
        )
        
        let resultText = String(subString)
        debugPrint("TTS - 播放: \(resultText) (\(characterRange.location), \(characterRange.length))")
    }
}
