//
//  MessageActor.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/7.
//

import Speech
import UIKit

// MARK: - 处理语音识别actor

actor SpeechEngineActor {
    var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var audioEngine: AVAudioEngine?
    var recognitionTask: SFSpeechRecognitionTask?

    func startVoiceToText() -> AsyncThrowingStream<String, Error> {
        audioEngine = AVAudioEngine()
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        // 建立一个AVAudioSession 用于录音
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            debugPrint("audioSession properties weren't set because of an error.")
            return AsyncThrowingStream<String, Error> { continuation in
                continuation.finish(throwing: error)
            }
        }
        // 初始化RecognitionRequest，在后边我们会用它将录音数据转发给苹果服务器
        let inputNode = audioEngine?.inputNode
        // 在用户说话的同时，将识别结果分批次返回
        recognitionRequest?.shouldReportPartialResults = true
        if let recognitionRequest = recognitionRequest {
            return AsyncThrowingStream<String, Error> { continuation in
                // ... 建立AVAudioSession和其余的识别请求代码 ...
                recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { result, error in
                    if let error = error {
                        self.stopVoiceRecognition()
                        continuation.finish(throwing: error)
                    }
                    if result?.isFinal == true {
                        self.stopVoiceRecognition()
                        continuation.finish()
                    }
                    continuation.yield(result?.bestTranscription.formattedString ?? "")
                })

                // 向recognitionRequest加入一个音频输入
                let recordingFormat = inputNode?.outputFormat(forBus: 0)
                inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                    self.recognitionRequest?.append(buffer)
                }
                audioEngine?.prepare()
                do {
                    // 开始录音
                    try audioEngine?.start()
                } catch {
                    debugPrint("audioEngine couldn't start because of an error.")
                    continuation.finish(throwing: error)
                }
            }
        } else {
            return AsyncThrowingStream<String, Error> { continuation in
                continuation.finish(throwing: NSError(domain: "SpeechEngineActor", code: 0, userInfo: nil))
            }
        }
    }

    // 这是一个新的方法，用于停止语音识别。
    func stopVoiceRecognition() {
        recognitionTask?.cancel()
        recognitionTask = nil
        if let inputNode = audioEngine?.inputNode {
            inputNode.removeTap(onBus: 0)
        }
        audioEngine?.stop()
        audioEngine = nil
        recognitionRequest = nil
    }
}
