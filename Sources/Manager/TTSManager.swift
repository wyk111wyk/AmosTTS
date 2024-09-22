//
//  VoiceData.swift
//  AmosVoice
//
//  Created by AmosFitness on 2023/4/5.
//

import Foundation
import SwiftUI
import AmosBase

@Observable
public final class TTSManager: @unchecked Sendable {
    @ObservationIgnored
    @AppStorage("DefaultConfig") private var savedDefaultConfig: Data?
    
    // TTS引擎
    let msTTS: MsTTSEngine?
    let systemTTS: SystemTTSEngine
    public var msEngineIsReady: Bool {
        msTTS != nil
    }
    
    public var playingContent: HLContent? = nil
    public var playOffset: Int = 0
    public var defaultConfig: TTSConfig {
        if let savedConfig = savedDefaultConfig?.decode(type: TTSConfig.self) {
            savedConfig
        } else {
            TTSConfig()
        }
    }
    
    public var showLiveSpeechPage: Bool = false
    public var errorMsg: String? = nil
    
    let isDebuging: Bool
    
    public init(
        sub: String = "",
        region: String = "",
        isDebuging: Bool = false
    ) {
        self.isDebuging = isDebuging
        
        self.msTTS = MsTTSEngine(sub: sub, region: region, isDebuging: isDebuging)
        self.systemTTS = SystemTTSEngine()
        
        if isPreviewCondition {
            playingContent = HLContent(
                allContent: [.example(.chineseAndEngish)],
                engine: .system
            )
        }
    }
}

// MARK: - Speech Methods
extension TTSManager {
    // 统一播放的入口
    // 1. 系统TTS 2.默认设置 3.分别播放设置
    public func playContents(
        engine: TTSEngine,
        config: TTSConfig? = nil,
        allContent: [TTSContent],
        showLive: Bool,
        textColor: Color = .black
    ) {
        self.playingContent = HLContent(
            isDebuging: isDebuging,
            textColor: textColor,
            allContent: allContent,
            engine: engine
        )
        
        switch engine {
        case .system:
            systemTTS.play(
                for: allContent,
                defaultConfig: config ?? defaultConfig
            ) { playStatus in
                self.updatePlayLive(playStatus)
            }
        case .ms:
            guard let msTTS else { return }
            msTTS.play(
                for: allContent,
                defaultConfig: config ?? defaultConfig
            ) { playStatus in
                self.updatePlayLive(playStatus)
            }
        }
        
        if showLive {
            if engine == .system {
                showLiveSpeechPage = true
            }else if (engine == .ms && msTTS != nil) {
                showLiveSpeechPage = true
            }
        }
    }
    
    private func updatePlayLive(_ playStatus: PlayStatus) {
        switch playStatus {
        case .start:
            self.playOffset = 0
            self.playingContent?.isPlaying = true
        case .play(let reading):
            if self.playingContent?.isPlaying == true {
                self.playingContent?.playWord = reading.word
                self.playingContent?.wordLength = reading.length
                if self.playingContent?.engine == .system {
                    self.playingContent?.textOffset = reading.offset
                }else {
                    self.playingContent?.textOffset = self.playOffset
                    self.playOffset += reading.length
                }
            }
        case .stop:
            debugPrint("停止播放：\(playingContent?.engine.title ?? "N/A")")
            self.resetSpeech()
        case .error(let error):
            self.errorMsg = error.localizedDescription
        default: break
        }
    }
    
    /// 保存为音频文件（不播放）
    public func outputContents(
        for allContent: [TTSContent],
        saveName: String
    ) async -> URL? {
        await withCheckedContinuation { continuation in
            let fileHelper = SimpleFileHelper()
            
            guard !fileHelper.fileExists(saveName) else {
                continuation.resume(returning: fileHelper.filePath(saveName))
                return
            }
            
            guard let msTTS else {
                continuation.resume(returning: nil)
                return
            }
            
            msTTS.synthesisToSpeaker(
                allContent,
                defaultConfig: defaultConfig,
                audioFileName: saveName
            ) { playStatus in
                switch playStatus {
                case .stop:
                    continuation.resume(returning: fileHelper.filePath(saveName))
                case .error:
                    continuation.resume(returning: nil)
                default: break
                }
            }
        }
    }
    
    /// 检测任何引擎是否在播放
    public func isSpeaking() -> Bool {
        systemTTS.systemSynthesizer.isSpeaking || msTTS?.isSpeaking == true
    }
    
    public func resetSpeech() {
        debugPrint("重置播放进度的展示")
        self.playingContent?.playWord = .init()
        self.playingContent?.textOffset = 0
        self.playingContent?.wordLength = 0
        self.playOffset = 0
        self.playingContent?.isPlaying = false
    }
    
    /// 只有系统TTS支持暂停
    public func pauseSpeech() {
        if systemTTS.systemSynthesizer.isSpeaking {
            systemTTS.systemSynthesizer.pauseSpeaking(at: .word)
        }else {
            guard let msTTS else { return }
            msTTS.stop()
        }
    }
    
    public func continueSpeech() {
        if systemTTS.systemSynthesizer.isPaused {
            systemTTS.systemSynthesizer.continueSpeaking()
        }else if let playingContent {
            playContents(
                engine: playingContent.engine,
                allContent: playingContent.allContent,
                showLive: false
            )
        }
    }
    
    public func stopSpeech() {
        if systemTTS.systemSynthesizer.isSpeaking {
            systemTTS.systemSynthesizer.stopSpeaking(at: .word)
        }else {
            guard let msTTS else { return }
            msTTS.stop()
        }
    }
    
    public func testSpeaker(
        for speaker: TTSSpeaker,
        style: TTSStyle? = nil,
        role: TTSRole? = nil
    ) {
        let inputText = speaker.language.testSpeech(speaker.speakerName)
        stopSpeech()
        
        let content = TTSContent(
            speechText: inputText,
            useDefaultConfig: false,
            config: .init(
                speaker: speaker,
                role: role,
                style: style
            )
        )
        
        // 直接播放
        playContents(
            engine: speaker.language == .system ? .system : .ms,
            allContent: [content],
            showLive: false
        )
    }
}
