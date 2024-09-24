//
//  SpeechLiveView.swift
//  AmosVoice
//
//  Created by AmosFitness on 2023/4/7.
//

import SwiftUI
import AmosBase

public struct SpeechLiveView: View {
    @Environment(\.dismiss) private var dismissPage
    
    @Bindable var ttsManager: TTSManager
    
    public init(ttsManager: TTSManager = .init()) {
        self.ttsManager = ttsManager
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                if let playingContent = ttsManager.playingContent {
                    SimpleSelectableText(
                        attributedText: playingContent.highlightedText()
                    ).padding(.horizontal)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                controlBar()
            }
            .navigationTitle("播报内容")
            .buttonCircleNavi(role: .cancel) {
                stop()
                dismissPage()
            }
        }
    }
    
    @ViewBuilder
    private func contentText(_ content: TTSContent) -> some View {
        switch content.type {
        case .text:
            Text(content.speechText)
                .font(.body)
                .lineSpacing(8)
        case .pause(let level):
            Text("< \(level.name()): \(level.pause())毫秒 >")
                .font(.body)
                .bold()
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private func controlBar() -> some View {
        if let playingContent = ttsManager.playingContent {
            HStack(spacing: 15) {
                controlButton()
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(isSpeaking ? "正在播放" : "点击播放")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        if isMSTTSReady {
                            Text("准备播放")
                                .simpleTag(.border())
                        }
                        Text(playingContent.playWord)
                            .foregroundStyle(.primary)
                        Spacer()
                        Text("\(playingContent.textOffset) / \(playingContent.fullText.count)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: playingContent.textOffset.toDouble,
                                 total: playingContent.fullText.count.toDouble)
                        .progressViewStyle(.linear)
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.regularMaterial)
            }
            .padding()
        }
    }
}

// MARK: - 播放控制
extension SpeechLiveView {
    private var isMSTTSReady: Bool {
        ttsManager.playingContent?.engine == .ms &&
        ttsManager.playingContent?.isPlaying == false &&
        ttsManager.playingContent?.wordLength == 0
    }
    
    private var isSpeaking: Bool {
        ttsManager.playingContent?.isPlaying == true
    }
    
    private func play() {
        ttsManager.continueSpeech()
    }
    
    private func pause() {
        ttsManager.pauseSpeech()
    }
    
    private func stop() {
        ttsManager.stopSpeech()
    }
    
    @ViewBuilder
    private func controlButton() -> some View {
        if ttsManager.playingContent?.engine == .system {
            // 系统TTS控制
            HStack(spacing: 15) {
                if ttsManager.systemTTS.systemSynthesizer.isPaused {
                    // 暂停时
                    Button(action: play, label: {
                        playButton()
                    }).buttonStyle(.plain)
                    Button(action: stop, label: {
                        stopButton()
                    }).buttonStyle(.plain)
                }else if ttsManager.systemTTS.systemSynthesizer.isSpeaking {
                    // 播放时
                    Button(action: pause, label: {
                        pauseButton()
                    }).buttonStyle(.plain)
                    Button(action: stop, label: {
                        stopButton()
                    }).buttonStyle(.plain)
                }else {
                    // 停止时
                    Button(action: play, label: {
                        playButton()
                    }).buttonStyle(.plain)
                }
            }
        }else {
            // 微软TTS控制
            if isSpeaking {
                Button(action: stop, label: {
                    stopButton()
                }).buttonStyle(.plain)
            }else {
                Button(action: play, label: {
                    playButton()
                }).buttonStyle(.plain)
                    .disabled(!isMSTTSReady)
            }
        }
    }
    
    var buttonCircle: some View {
        Circle()
            .stroke(lineWidth: 2)
            .frame(width: 36)
            .foregroundStyle(.secondary)
    }
    
    private func loadingButton() -> some View {
        ZStack {
            buttonCircle
            ProgressView()
                .tint(.red)
        }
    }
    
    private func playButton() -> some View {
        ZStack {
            buttonCircle
            Image(systemName: "play.fill")
                .foregroundStyle(.blue)
        }
    }
    
    private func pauseButton() -> some View {
        ZStack {
            buttonCircle
            Image(systemName: "pause.fill")
                .foregroundStyle(.orange)
        }
    }
    
    private func stopButton() -> some View {
        ZStack {
            buttonCircle
            Image(systemName: "square.fill")
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    SpeechLiveView(ttsManager: .init())
}
