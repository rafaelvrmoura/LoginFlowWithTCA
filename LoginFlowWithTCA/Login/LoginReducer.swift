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
    @Dependency(\.core) var core
    @Dependency(\.apiClient) var apiClient
    
    enum LoginError: Error {
        
        case invalidEmail
        case invalidCredentials
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
        
        case didLogin(Result<AuthToken, APIError>)
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
                
            case .didTapLoginButton:
                if state.emailStatus == .valid {
                    state.error = nil
                    return login(email: state.email, password: state.password, APIClient: apiClient)
                } else {
                    print("Invalid email")
                    state.error = .invalidEmail
                    return .none
                }
                
            case .didLogin(let loginResult):
                switch loginResult {
                case .success(let token): // TODO: Get user with token
                    state.error = nil
                    print("Auth Token - \(token)")
                    return .none
                case .failure(let error):
                    if case .invalidCredentials = error {
                        print("Invalid credentials")
                        state.error = .invalidCredentials
                    }
                    return .none
                }
            case .didTapForgotPasswordButton: return .none // TODO: Navigate
            case .didTapRegisterButton: return .none // TODO: Navigate
            }
        }
    }
}

