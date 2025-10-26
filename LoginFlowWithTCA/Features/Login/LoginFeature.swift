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

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        
        case signupForm(SignupFormReducer)
    }
    
    @ObservableState
    struct State: Equatable {
        
        var email: String = ""
        var emailStatus: InputStatus = .idle
        var password: String = ""
        var error: LoginError? = nil
        
        var signupFormState: SignupFormReducer.State? = nil
        var isPresentingSignupForm = false
        
        @Presents var destination: Destination.State? = nil
    }
    
    @CasePathable
    enum Action: Equatable {
        
        case didChangeEmail(String)
        case didSubmitEmail
        case didChangePassword(String)
        case didTapForgotPasswordButton
        case didTapLoginButton
        case didTapRegisterButton
        case didLogin(Result<AuthToken, LoginAPIClient.Error>)
        
        case destination(PresentationAction<Destination.Action>)
    }
    
    var body: some Reducer<State, Action> {
    
        Reduce { state, action in
            
            switch action {
                
            // Navigation State
            case .destination:
                return .none
                
            case .didTapRegisterButton:
                state.destination = .signupForm(SignupFormReducer.State())
                return .none
                
            case .didTapForgotPasswordButton:
                return .none
                
            // View State
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
                    print("## TOKEN \(token)")
                    state.error = nil
                    return .none
                case .failure(let error):
                    if case .invalidCredentials = error {
                        state.error = .invalidCredentials
                    }
                    return .none
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
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
