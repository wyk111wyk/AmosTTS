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
                    let highLightString = Binding<AttributedString?> (
                        get: {playingContent.highlightedText()}, set: {_ in}
                    )
                    SimpleSelectableText(
                        variedString: highLightString,
                        isInScroll: true
                    ).padding(.horizontal)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                SpeechLiveBar(ttsManager: ttsManager)
            }
            .navigationTitle("播报内容")
            .buttonCircleNavi(role: .cancel) {
                ttsManager.stopSpeech()
                dismissPage()
            }
        }
        .simpleErrorToast(error: $ttsManager.occurError)
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
}

#Preview {
    SpeechLiveView(ttsManager: TTSManager())
}
