//
//  SwiftUIView.swift
//  AmosTTS
//
//  Created by AmosFitness on 2024/9/20.
//

import SwiftUI
import AmosBase

public struct DefaultSpeakerCell: View {
    @AppStorage("DefaultConfig") private var savedDefaultConfig: Data?
    
    @Bindable var ttsManager: TTSManager
    
    var defaultConfig: TTSConfig {
        if let savedConfig = savedDefaultConfig?.decode(type: TTSConfig.self) {
            savedConfig
        } else {
            TTSConfig()
        }
    }
    
    public init(ttsManager: TTSManager) {
        self.ttsManager = ttsManager
    }
    
    public var body: some View {
        NavigationLink {
            ConfigSetting(
                ttsManager: ttsManager,
                config: defaultConfig
            ) { newConfig in
                // 保存默认全局播放属性
                savedDefaultConfig = newConfig?.toData()
            }
        } label: {
            SimpleCell("默认播放属性") {
                Text(defaultConfig.speaker.speakerName)
                    .simpleTag(.border())
            }
        }
    }
}

#Preview {
    NavigationStack {
        Form {
            Section {
                DefaultSpeakerCell(ttsManager: .init())
            }
        }
    }
}
