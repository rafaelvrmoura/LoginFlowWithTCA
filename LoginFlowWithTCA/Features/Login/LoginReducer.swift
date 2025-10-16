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
    @Dependency(\.loginAPIClient) var apiClient
    
    enum LoginError: Error {
        
        case invalidEmail
        case emptyPassword
        case invalidCredentials
    }
    
    struct State: Equatable {
        
        var email: String = ""
        var emailStatus: InputStatus = .idle
        var password: String = ""
        var error: LoginError? = nil
    }
    
    enum Action: Equatable {
        
        case didChangeEmail(String)
        case didSubmitEmail
        case didChangePassword(String)
        case didTapForgotPasswordButton
        case didTapLoginButton
        case didTapRegisterButton
        
        case didLogin(Result<AuthToken, LoginAPIClient.Error>)
    }
    
    var body: some Reducer<State, Action> {
        
        Reduce { state, action in
            
            switch action {
            case .didChangeEmail(let email):
                state.email = email
                state.emailStatus = emailValidator.isValid(email: email) ? .valid : .idle
                return .none
                
            case .didSubmitEmail:
                state.emailStatus = emailValidator.isValid(email: state.email) ? .valid : .invalid
                return .none
                
            case .didChangePassword(let password):
                state.password = password
                return .none
                
            case .didTapLoginButton:
                
                guard state.emailStatus == .valid else {
                    state.error = .invalidEmail
                    return .none
                }
                
                guard state.password.isEmpty == false else {
                    state.error = .emptyPassword
                    return .none
                }
                
                state.error = nil
                return self.loginEffect(email: state.email, password: state.password)
                
            case .didLogin(let loginResult):
                switch loginResult {
                case .success(let token): // TODO: Get user with token
                    state.error = nil
                    return .none
                case .failure(let error):
                    if case .invalidCredentials = error {
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

// MARK: - Effects

private extension LoginReducer {
    
    func loginEffect(email: String, password: String) -> Effect<LoginReducer.Action> {
        
        return .run { send in
            
            do {
                
                let authToken = try await self.apiClient.loginRequest(
                    LoginRequestModel(
                        email: email,
                        password: password
                    )
                )
                
                return await send(.didLogin(.success(authToken)))
                
            } catch LoginAPIClient.Error.invalidCredentials {
                
                return await send(.didLogin(.failure(.invalidCredentials)))
            }
        }
    }
}
