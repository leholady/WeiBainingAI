//
//  LaunchConfigReducer.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/11/23.
//  启动配置Reducer

import ComposableArchitecture
import Reachability
import UIKit

struct LaunchConfigReducer: Reducer {
    struct State: Equatable {
        var userProfile: UserProfileModel?
        /// 无网络
        var loadError: Bool = false
    }

    @Dependency(\.launchClient) var launchClient
    @Dependency(\.httpClient) var httpClient

    enum Action {
        case launchApp
        case listenReachability(Reachability.Connection)
        case loadConfig
        case loadConfigSuccess(userProfile: UserProfileModel)
        case loadConfigFailure
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .launchApp:
                return .run { send in
                    for await reachable in await launchClient.reachable() {
                        await send(.listenReachability(reachable))
                    }
                }
            case let .listenReachability(connection):
                switch connection {
                case .unavailable:
                    state.loadError = true
                    return .none
                case .wifi, .cellular:
                    return .run { send in
                        await send(.loadConfig)
                    }
                }
            case .loadConfig:
                return .run { send in
                    let userProfile = try await httpClient.getNewUserProfile()
                    await send(.loadConfigSuccess(userProfile: userProfile))
                }
            case let .loadConfigSuccess(userProfile):
                state.userProfile = userProfile
                return .none
            case .loadConfigFailure:
                state.loadError = true
                return .none
            }
        }
    }
}
