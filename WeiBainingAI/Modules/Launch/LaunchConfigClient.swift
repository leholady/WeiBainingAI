//
//  LaunchConfigClient.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/23.
//  启动配置Client

import ComposableArchitecture
import Logging
import Reachability
import UIKit

struct LaunchConfigClient {
    /// 用于检测网络连接状态
    var reachable: @Sendable () async -> AsyncStream<Reachability.Connection>
}

extension LaunchConfigClient: DependencyKey {
    static var liveValue: LaunchConfigClient {
        Self {
            AsyncStream { continuation in
                let reachability = try? Reachability()

                reachability?.whenReachable = { reachable in
                    if reachable.connection == .wifi {
                        Logger(label: "LaunchConfigClient").info("Reachable via WiFi")
                    } else {
                        Logger(label: "LaunchConfigClient").info("Reachable via Cellular")
                    }
                    continuation.yield(reachable.connection)
                    switch reachable.connection {
                    case .unavailable:
                        break
                    default:
                        continuation.finish()
                    }
                }
                reachability?.whenUnreachable = { _ in
                    Logger(label: "LaunchConfigClient").info("Not reachable")
                    continuation.yield(.unavailable)
                }

                do {
                    try reachability?.startNotifier()
                } catch {
                    Logger(label: "LaunchConfigClient").info("Unable to start notifier")
                }

                continuation.onTermination = { _ in
                    reachability?.stopNotifier()
                }
            }
        }
    }
}

extension DependencyValues {
    var launchClient: LaunchConfigClient {
        get {
            self[LaunchConfigClient.self]
        }
        set {
            self[LaunchConfigClient.self] = newValue
        }
    }
}
