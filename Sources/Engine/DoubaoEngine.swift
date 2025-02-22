//
//  File.swift
//  AmosTTS
//
//  Created by Amos on 2025/1/12.
//

import Foundation
import AmosBase

let publicKey: String = "ynfeIgYdEufkkyet"
let publicIV: String = "I8xD9VKiRAkcW0W1"

class DoubaoEngine {
    var basePath: String {
        "https://openspeech.bytedance.com/api/v1/tts"
    }
    
    var cryptoKey: String {
        "pAidZUxqG10qg/XYLipebmxlmxU1sGp9NpET9N7+dOwig0H0ZQdo7XUvgOExPSwT"
    }
    
    private var key: String? {
        let crypto = SimpleAESCrypto(key: publicKey, iv: publicIV)
        return try? crypto.decrypt(encryptedText: cryptoKey)
    }
    
    private var header: [String: String] {
        if let key {
            ["Authorization": "Bearer \(key)"]
        }else {
            [:]
        }
    }
}
