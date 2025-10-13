//
//  LoginFlowWithTCAApp.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 11/10/25.
//

import SwiftUI
import ComposableArchitecture

@main
struct LoginFlowWithTCAApp: App {
    
    let store: StoreOf<RootReducer> = Store(
        initialState: .init(),
        reducer: {
            RootReducer()
        },
        withDependencies: {
            $0.emailValidator = .liveValue
        }
    )

    var body: some Scene {
        WindowGroup {
            LoginView(
                store: store.scope(
                    state: \.loginState,
                    action: \.loginAction
                )
            )
        }
    }
}
