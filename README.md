# AmosTTS
[![Supported Swift Version](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fargmaxinc%2FWhisperKit%2Fbadge%3Ftype%3Dswift-versions&labelColor=353a41&color=32d058)](https://www.amosstudio.com.cn/) 
[![Supported Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fargmaxinc%2FWhisperKit%2Fbadge%3Ftype%3Dplatforms&labelColor=353a41&color=32d058)](https://www.amosstudio.com.cn/)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)

作者 Amos 网址 [AmosStudio](https://www.amosstudio.com.cn/)。
<img width="1030" height="211" alt="Logo-Black" src="https://github.com/user-attachments/assets/566ff915-d24e-4c37-9fb8-3a450e93d206" />


# 主要功能
这是一款基于Swift构建的语音合成（TTS）管理库，底层封装系统AVSpeechSynthesis框架，同时支持主流第三方TTS接口，提供统一、简洁的语音合成与播放控制能力。
> 核心依赖：AVFoundation，兼容iOS 13+/macOS 10.15+
1. 系统原生语音合成与自定义参数配置
2. 多语音引擎/音色切换，支持中英文等多语种
3. 语音合成播放控制（播放、暂停、停止、语速/音调调节）
4. 合成语音本地保存为音频文件
5. 批量文本合成与队列播放管理

# 相关特性
- 独立线程处理语音合成与播放，避免主线程阻塞
~~~swift
ttsQueue = DispatchQueue(label: "com.amosstudio.amostts.queue", attributes: [])
~~~
- 支持语音合成进度实时回调，适配UI展示
- 统一封装系统/第三方TTS接口，底层切换无感知
- 支持`AppGroup`共享语音配置，适配小组件语音播报
- 内置语音合成错误处理与重试机制

# 使用语音合成库
## 初始化TTS管理器
初始化核心管理类`TTSManager`，支持全局配置默认语音参数，指定合成引擎类型。
~~~swift
// 初始化系统原生TTS引擎，配置默认参数
let ttsConfig = TTSConfig(
    engine: .system, // 可选.system/.custom(第三方)
    language: "zh-CN",
    rate: 0.5, // 语速 0.0~1.0
    pitch: 1.0, // 音调 0.5~2.0
    volume: 1.0 // 音量 0.0~1.0
)
self.ttsManager = TTSManager(config: ttsConfig)
// 监听合成/播放状态
ttsManager.stateHandler = { state in
    switch state {
    case .synthesizing(let progress): print("合成中：\(progress*100)%")
    case .playing: print("语音播放中")
    case .paused: print("语音已暂停")
    case .stopped: print("语音已停止")
    case .completed: print("合成播放完成")
    }
}
~~~

## 核心功能使用示例
### 基础文本语音合成与播放
```swift
/// 合成并播放单段文本
func speakText(_ text: String) async {
    do {
        let ttsRequest = TTSRequest(text: text)
        try await ttsManager.speak(ttsRequest)
    } catch {
        handleTTSError(error)
    }
}

/// 暂停/继续/停止播放
func pauseSpeak() { ttsManager.pause() }
func resumeSpeak() { ttsManager.resume() }
func stopSpeak() { ttsManager.stop() }
```

### 自定义语音参数合成
支持为单条合成请求单独配置参数，覆盖全局默认设置。
```swift
/// 自定义音色、语速合成英文文本
func speakEnglishWithCustomConfig() async {
    do {
        let customRequest = TTSRequest(
            text: "Hello, AmosTTS is a lightweight TTS library for Swift.",
            language: "en-US",
            rate: 0.6,
            pitch: 0.8,
            voiceName: "Samantha" // 指定系统音色名称
        )
        try await ttsManager.speak(customRequest)
    } catch {
        handleTTSError(error)
    }
}
```

### 合成语音并本地保存为音频文件
将合成的语音保存为WAV/MP3格式，支持离线播放。
```swift
/// 合成文本并保存为本地音频文件
func synthesizeAndSaveText(_ text: String) async -> URL? {
    do {
        let savePath = FileManager.default.temporaryDirectory.appendingPathComponent("tts_audio.wav")
        let request = TTSRequest(text: text)
        // 仅合成不播放，保存至指定路径
        try await ttsManager.synthesize(request, saveTo: savePath, format: .wav)
        return savePath
    } catch {
        handleTTSError(error)
        return nil
    }
}
```

### 批量文本队列合成与播放
支持多段文本按顺序合成播放，支持插队、清空队列操作。
```swift
/// 批量添加文本至播放队列，按顺序合成播放
func speakTextQueue(_ texts: [String]) async {
    do {
        let requests = texts.map { TTSRequest(text: $0) }
        // 添加至队列并开始播放
        try await ttsManager.addToQueue(requests, playImmediately: true)
    } catch {
        handleTTSError(error)
    }
}

/// 清空播放队列并停止当前播放
func clearSpeakQueue() {
    ttsManager.clearQueue()
    ttsManager.stop()
}
```

### 切换语音引擎/音色
统一接口切换系统不同音色或第三方TTS引擎，无需修改业务代码。
```swift
/// 切换系统音色
func switchSystemVoice(_ voiceName: String) {
    ttsManager.updateConfig { config in
        config.voiceName = voiceName
    }
}

/// 切换至第三方TTS引擎（如讯飞/百度）
func switchCustomTTSEngine() {
    let customConfig = TTSConfig(
        engine: .custom,
        apiKey: "your_custom_tts_api_key", // 第三方接口密钥
        language: "zh-CN",
        rate: 0.5
    )
    ttsManager.reloadConfig(customConfig)
}
```

## 支持的协议与自定义模型
自定义TTS请求/引擎需遵循对应协议，便于扩展第三方TTS接口。
### 自定义TTS引擎协议
```swift
/// 自定义TTS引擎需遵循此协议
protocol TTSEngineProtocol {
    func synthesize(_ request: TTSRequest) async throws -> Data
    func speak(_ request: TTSRequest, progress: ((Double) -> Void)?) async throws
    func stop()
}
```
### 自定义语音请求模型
```swift
/// 自定义TTS请求，遵循TTSRequestProtocol
struct CustomTTSRequest: TTSRequestProtocol {
    var text: String // 合成文本
    var language: String // 语言标识
    var rate: Double // 语速
    var pitch: Double // 音调
    var volume: Double // 音量
    var customParams: [String: Any]? // 第三方引擎自定义参数
}
```

## 错误处理
库内封装统一的`TTSError`枚举，覆盖合成、播放、引擎配置等所有错误场景。
```swift
/// 全局TTS错误处理
func handleTTSError(_ error: Error) {
    guard let ttsError = error as? TTSError else {
        print("TTS未知错误：\(error.localizedDescription)")
        return
    }
    switch ttsError {
    case .invalidText: print("错误：合成文本为空或无效")
    case .unsupportedLanguage: print("错误：不支持当前语言类型")
    case .engineInitFailed: print("错误：TTS引擎初始化失败")
    case .synthesizeFailed: print("错误：语音合成失败")
    case .saveFileFailed: print("错误：音频文件保存失败")
    case .customEngineError(let msg): print("第三方引擎错误：\(msg)")
    default: print("TTS错误：\(ttsError.localizedDescription)")
    }
}
```

## 监听TTS全局通知
通过通知中心监听语音合成/播放的全局状态变化，适配跨页面UI更新。
```swift
import Combine
var cancellables = Set<AnyCancellable>()

// 监听语音合成完成通知
NotificationCenter.default.publisher(for: .ttsSynthesizeCompleted)
    .sink { _ in
        print("全局通知：语音合成完成")
        // 执行后续业务逻辑
    }
    .store(in: &cancellables)

// 监听语音播放完成通知
NotificationCenter.default.publisher(for: .ttsPlayCompleted)
    .sink { notification in
        guard let text = notification.userInfo?["text"] as? String else { return }
        print("全局通知：文本\(text)播放完成")
    }
    .store(in: &cancellables)
```
