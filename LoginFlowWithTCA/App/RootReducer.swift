//
//  RootReducer.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 13/10/25.
//

import ComposableArchitecture

@Reducer
struct RootReducer {
    
    struct State: Equatable {
        
        var loginState = LoginReducer.State()
    }
    
    enum Action {
        
        case loginAction(LoginReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        
        Scope(
            state: \.loginState,
            action: \.loginAction,
            child: {
                LoginReducer()
            }
        )
    }
}
