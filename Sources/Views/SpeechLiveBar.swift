//
//  SwiftUIView.swift
//  AmosTTS
//
//  Created by AmosFitness on 2024/10/13.
//

import SwiftUI
import AmosBase

public struct SpeechLiveBar: View {
    @Bindable var ttsManager: TTSManager
    let showDismissButton: Bool
    let hasShadow: Bool
    
    public init(
        ttsManager: TTSManager = .init(),
        showDismissButton: Bool = false,
        hasShadow: Bool = false
    ) {
        self.ttsManager = ttsManager
        self.showDismissButton = showDismissButton
        self.hasShadow = hasShadow
    }
    
    public var body: some View {
        controlBar()
    }
}

extension SpeechLiveBar {
    @ViewBuilder
    private func controlBar() -> some View {
        if let playingContent = ttsManager.playingContent {
            VStack(spacing: 10) {
                HStack(spacing: 15) {
                    controlButton()
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(ttsManager.isPlaying == true ? "正在播放" : "点击播放")
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
                        ProgressView(
                            value: playingContent.textOffset.toDouble,
                            total: max(playingContent.fullText.count, playingContent.textOffset).toDouble
                        )
                        .progressViewStyle(.linear)
                    }
                }
                .padding()
                .background {
                    if hasShadow {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.regularMaterial)
                            .shadow(radius: 5)
                    }else {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.regularMaterial)
                    }
                }
                
                if showDismissButton {
                    HStack {
                        Spacer()
                        Button {
                            ttsManager.stopSpeech()
                            ttsManager.showSpeechBar = false
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark")
                                Text("关闭")
                            }
                            .simpleTag(.border(verticalPad: 4, horizontalPad: 8, cornerRadius: 15, contentColor: .secondary))
                        }
                        .padding(.trailing, 6)
                    }
                }
            }
            .padding()
        }
    }
    
    private var isMSTTSReady: Bool {
        ttsManager.playingContent?.engine == .ms &&
        ttsManager.isPlaying == false &&
        ttsManager.playingContent?.wordLength == 0
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
                if ttsManager.isPlaying == false {
                    // 停止时
                    Button(action: play, label: {
                        playButton()
                    }).buttonStyle(.plain)
                }else if ttsManager.systemTTS.systemSynthesizer.isPaused {
                    // 暂停时
                    Button(action: play, label: {
                        playButton()
                    }).buttonStyle(.plain)
                    Button(action: stop, label: {
                        stopButton()
                    }).buttonStyle(.plain)
                }else {
                    // 播放时
                    Button(action: pause, label: {
                        pauseButton()
                    }).buttonStyle(.plain)
                    Button(action: stop, label: {
                        stopButton()
                    }).buttonStyle(.plain)
                }
            }
        }else {
            // 微软TTS控制
            if ttsManager.isPlaying == nil {
                Button(action: stop, label: {
                    loadingButton()
                })
                .buttonStyle(.plain)
                .disabled(true)
            }else if ttsManager.isPlaying == true {
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
    @Previewable @State var tts = TTSManager()
    NavigationStack {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Hello world")
                Spacer()
            }
            Spacer()
        }
        .overlay(alignment: .top) {
            SpeechLiveBar(ttsManager: tts, showDismissButton: true, hasShadow: true)
        }
    }
}