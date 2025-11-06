//
//  RootReducer.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 13/10/25.
//

import ComposableArchitecture

struct CoreEnvironment {
    
    var loggedInUser: UserModel?
    var authToken: String?
}

extension CoreEnvironment: DependencyKey {
    static var liveValue: CoreEnvironment {
        .init()
    }
    
    
    
    static var dev: CoreEnvironment {
       
        .init(loggedInUser: UserModel(id:nil,
                                      name: "User Test",
                                      email: "email@test.com",
                                      password: "password",
                                      preferredTheme: nil,
                                      profilePictureURL: nil))
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
    
    @Dependency(\.core) var core
    
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
    
