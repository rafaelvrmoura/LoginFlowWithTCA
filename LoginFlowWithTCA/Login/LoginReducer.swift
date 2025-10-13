//
//  LoginReducer.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 13/10/25.
//

import ComposableArchitecture

@Reducer
struct LoginReducer {
    
    @Dependency(\.emailValidator) var emailValidator
    
    enum LoginError: Error {
        
        case invalidEmail
        case loginFailed
    }
    
    enum InputStatus {
        
        case invalid
        case valid
        case idle
    }
    
    struct State: Equatable {
        
        var email: String = ""
        var emailStatus: LoginReducer.InputStatus = .idle
        var password: String = ""
        var error: LoginError? = nil
    }
    
    enum Action {
        
        case didChangeEmail(String)
        case didSubmitEmail
        case didChangePassword(String)
        case emailStatus(LoginReducer.InputStatus)
        case didTapForgotPasswordButton
        case didTapLoginButton
        case didTapRegisterButton
    }
    
    var body: some Reducer<State, Action> {
        
        Reduce { state, action in
            
            switch action {
            case .didChangeEmail(let email):
                state.email = email
                let status: LoginReducer.InputStatus = emailValidator.isValid(email: email) ? .valid : .idle
                return .send(.emailStatus(status))
                
            case .didSubmitEmail:
                let status: LoginReducer.InputStatus = emailValidator.isValid(email: state.email) ? .valid : .invalid
                return .send(.emailStatus(status))
                
            case .didChangePassword(let password):
                state.password = password
                return .none
                
            case .emailStatus(let status):
                state.emailStatus = status
                return .none
                
            case .didTapLoginButton: return .none // TODO: Authenticate
            case .didTapForgotPasswordButton: return .none // TODO: Navigate
            case .didTapRegisterButton: return .none // TODO: Navigate
            }
        }
    }
}

