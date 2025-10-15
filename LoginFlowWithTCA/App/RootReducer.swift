//
//  RootReducer.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 13/10/25.
//

import ComposableArchitecture

struct CoreEnvironment {
    
    var loggedInUser: UserModel?
    var authToken: AuthToken?
}

extension CoreEnvironment: DependencyKey {
    static var liveValue: CoreEnvironment {
        .init()
    }
    
    
    
    static var dev: CoreEnvironment {
       
        .init(loggedInUser: UserModel(email: "email@test.com",
                                      password: "password",
                                      photo: nil))
    }
}

extension DependencyValues {
    
    var core: CoreEnvironment {
        
        get { self[CoreEnvironment.self] }
        set { self[CoreEnvironment.self] = newValue }
    }
}

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
    