//
//  LoginReducer.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 13/10/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct LoginReducer {
    
    enum LoginError: Error, Equatable {
        
        case invalidCredentials
        case underlying(NSError)
    }
    
    @Dependency(\.emailValidator) var emailValidator
    @Dependency(\.core) var core
    @Dependency(\.loginAPIClient) var apiClient
    @Dependency(\.dismiss) var dismiss
    
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        
        case signupForm(SignupFormReducer)
        case alert(AlertState<Alert>)
        
        @CasePathable
        enum Alert {
            
            case confirm
        }
    }
    
    @ObservableState
    struct State: Equatable {
        
        var email: String = ""
        var emailStatus: InputStatus = .idle
        var password: String = ""
        var isLoading: Bool = false
        
        var signupFormState: SignupFormReducer.State? = nil
        
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
        case didLogin(Result<AuthResult, LoginError>)
        case dismissSigupForm
        
        case destination(PresentationAction<Destination.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            
            switch action {
                
            // Navigation State
            case .destination(.presented(.alert(let alertAction))):
                switch alertAction {
                case .confirm:
                    state.destination = nil
                    return .none
                }
                
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
                
            case .dismissSigupForm:
                state.destination = nil
                return .none
                
            case .didTapLoginButton:
                
                guard state.emailStatus == .valid else {
                    return .none
                }
                
                guard state.password.isEmpty == false else {
                    return .none
                }
                
                state.isLoading = true
                return self.loginEffect(email: state.email, password: state.password)
                
            case .didLogin(let loginResult):
                
                state.isLoading = false
                
                switch loginResult {
                case .success(let authResult): // TODO: Get user with token
                    state.destination = .alert(AlertState{
                        TextState("Success")
                    } actions: {
                        ButtonState(action: .confirm) {
                            TextState("Ok")
                        }
                    } message: {
                        TextState("Loged in with token \n \(authResult.token)")
                    })
                    return .none
                case .failure(let error):
                    state.destination = .alert(AlertState.alert(for: error))
                    return .none
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension AlertState where Action == LoginReducer.Destination.Alert {
    
    static func alert(for error: LoginReducer.LoginError)-> Self {
        AlertState{
            TextState("Error")
        } actions: {
            ButtonState(action: .confirm) {
                TextState("Ok")
            }
        } message: {
            switch error {
            case .invalidCredentials:
                TextState("Invalid email or password")
            case .underlying(let nsError):
                TextState(nsError.localizedDescription)
            }
        }
    }
}

// MARK: - Effects

private extension LoginReducer {
    
    func loginEffect(email: String, password: String) -> Effect<LoginReducer.Action> {
        
        return .run { send in
            
            do {
                
                let authToken = try await self.apiClient.login(email: email, password: password)
                
                return await send(.didLogin(.success(authToken)))
                
            } catch APIClientError.failed(statusCode: 401) {
                
                return await send(.didLogin(.failure(.invalidCredentials)))
                
            } catch {
                
                return await send(.didLogin(.failure(.underlying(error as NSError))))
            }
        }
    }
}
