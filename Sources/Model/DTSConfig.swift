//
//  File.swift
//  AmosTTS
//
//  Created by Amos on 2025/1/12.
//

import Foundation

/// DTSConfig 结构体，包含应用、用户、音频和请求的相关配置。
public struct DTSConfig: Codable {
    /// 应用相关配置，包括 appid 和 token。
    public let app: AppConfig
    
    /// 用户相关配置，包括 uid。
    public let user: UserConfig
    
    /// 音频相关配置，包括 voice_type, encoding, speed_ratio 等。
    public let audio: AudioConfig
    
    /// 请求相关配置，包括 reqid, text, text_type, with_timestamp, operation 等。
    public let request: RequestConfig
    
    /// 初始化 DTSConfig 结构体。
    public init(
        app: AppConfig,
        user: UserConfig = .init(),
        audio: AudioConfig,
        request: RequestConfig
    ) {
        self.app = app
        self.user = user
        self.audio = audio
        self.request = request
    }
}

extension DTSConfig {
    /// 应用相关配置。
    public struct AppConfig: Codable {
        /// 应用标识，需要申请。
        public let appid: String
        
        /// 应用令牌，可传任意非空字符串。
        public let token: String
        
        /// 业务集群，默认为 volcano_tts。
        public let cluster: String
        
        /// 初始化 AppConfig 结构体。
        public init(
            appid: String,
            token: String,
            cluster: String = "volcano_tts"
        ) {
            self.appid = appid
            self.token = token
            self.cluster = cluster
        }
    }
    
    /// 用户相关配置。
    public struct UserConfig: Codable {
        /// 用户标识，可传任意非空字符串，传入值可以通过服务端日志追溯。
        public let uid: String
        
        /// 初始化 UserConfig 结构体。
        public init(uid: String = UUID().uuidString) {
            self.uid = uid
        }
    }
    
    /// 音频相关配置。
    public struct AudioConfig: Codable {
        /// 音色类型。
        public let voice_type: String
        
        /// 音频编码格式，默认为 pcm。支持的格式包括 wav / pcm / ogg_opus / mp3。
        public let encoding: String
        
        /// 语速，范围在 [0.8, 2]，默认为 1。
        public let speed_ratio: Float
        
        /// 初始化 AudioConfig 结构体。
        public init(
            voice_type: String,
            encoding: String = "mp3",
            speed_ratio: Float = 1
        ) {
            self.voice_type = voice_type
            self.encoding = encoding
            self.speed_ratio = speed_ratio
        }
    }
    
    /// 请求相关配置。
    public struct RequestConfig: Codable {
        /// 请求标识，需要保证每次调用传入值唯一，建议使用 UUID。
        public let reqid: String
        
        /// 合成语音的文本，长度限制 1024 字节（UTF-8 编码）。
        public let text: String
        
        /// 文本类型，使用 ssml 时需要指定，值为"ssml"。
        public let text_type: String?
        
        /// 时间戳相关配置。传入 1 表示启用，可返回原文本的时间戳，而非 TN 后文本。
        public let with_timestamp: Int?
        
        /// 操作类型，包括 query（非流式，http 只能 query）和 submit（流式）。
        public let operation: String
        
        /// 初始化 RequestConfig 结构体。
        public init(
            reqid: String = UUID().uuidString,
            text: String,
            isSSML: Bool = false,
            with_timestamp: Int? = nil,
            operation: String = "query"
        ) {
            self.reqid = reqid
            self.text = text
            self.text_type = isSSML ? "ssml" : nil
            self.with_timestamp = with_timestamp
            self.operation = operation
        }
    }
}

extension DTSConfig {
    /// 将结构体内属性转换为 JSON 格式的字符串。
    public func toJSONString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // 使输出格式化，便于阅读
        do {
            let jsonData = try encoder.encode(self)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Error encoding DTSConfig to JSON: \(error)")
        }
        return nil
    }
}
