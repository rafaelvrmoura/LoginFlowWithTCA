//
//  LoginReducerTests.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 14/10/25.
//

import Testing
import ComposableArchitecture

@testable import LoginFlowWithTCA

@MainActor
struct LoginReducerTests {
    
    let store = TestStore(
        initialState: LoginReducer.State(),
        reducer: { LoginReducer() },
        withDependencies: {
            $0.emailValidator = EmailValidator()
        }
    )
    
    @Test
    func didEnterValidEmail() async {
        
        let email = "rafael@example.com"
        
        await store.send(.didChangeEmail(email)) { expectedState in
            
            expectedState.email = email
            expectedState.emailStatus = .valid
        }
    }
    
    @Test
    func enteringEmail() async {
        
        let email = "rafael@examp"
        
        await store.send(.didChangeEmail(email)) { expectedState in
                
            expectedState.email = email
            expectedState.emailStatus = .idle
        }
    }
    
    @Test
    func didSubmitInvalidEmail() async {
        
        let email = "rafael@example."
        
        await store.send(.didChangeEmail(email)) { expectedState in
            expectedState.email = email
        }
        
        await store.send(.didSubmitEmail) { expectedState in
        
            expectedState.email = email
            expectedState.emailStatus = .invalid
        }
    }
    
    @Test
    func didSubmitValidEmail() async {
        
        let email = "rafael@example.com"
        
        await store.send(.didChangeEmail(email)) { expectedState in
            
            expectedState.email = email
            expectedState.emailStatus = .valid
        }
        
        await store.send(.didSubmitEmail)
    }
    
    @Test
    func didChangePassword() async {
        
        let password = "foo"
        
        await store.send(.didChangePassword(password)) { expectedState in
            
            expectedState.password = password
        }
    }
    
    @Test
    func didTapLoginButtonWithInvalidEmail() async {
        
        let email = "rafael@test"
        let password = "foo"
    
        let initialState = LoginReducer.State(email: email, emailStatus: .invalid, password: password)
        
        let store = TestStore(
            initialState: initialState,
            reducer: {
                LoginReducer()
            }, withDependencies: {
                $0.emailValidator = EmailValidator()
            }
        )
        
        await store.send(.didTapLoginButton) { expectedState in

            expectedState.error = .invalidEmail
        }
    }
    
    @Test
    func didTapLoginButtonWithEmptyPassword() async {
        
        let email = "rafael@test.com"
        let password = ""
    
        let initialState = LoginReducer.State(email: email, emailStatus: .valid, password: password)
        
        let store = TestStore(
            initialState: initialState,
            reducer: {
                LoginReducer()
            }, withDependencies: {
                $0.emailValidator = EmailValidator()
            }
        )
        
        await store.send(.didTapLoginButton) { expectedState in

            expectedState.error = .emptyPassword
        }
    }
    
    @Test
    func didTapLoginButtonWithInvalidCredentials() async {
        
        let email = "rafael@test.com"
        let password = "foo"
    
        let initialState = LoginReducer.State(email: email, emailStatus: .valid, password: password)
        
        let store = TestStore(
            initialState: initialState,
            reducer: {
                LoginReducer()
            }, withDependencies: {
                $0.emailValidator = EmailValidator()
                $0.loginAPIClient = LoginAPIClient { _ in
                    throw LoginAPIClient.Error.invalidCredentials
                }
            }
        )
        
        await store.send(.didTapLoginButton)
        await store.receive(.didLogin(.failure(.invalidCredentials))) { expectedState in
            
            expectedState.error = .invalidCredentials
        }
    }
    
    @Test
    func didTapLoginButtonWithValidCredentials() async {
        
        let email = "rafael@test.com"
        let password = "foo"
    
        let initialState = LoginReducer.State(email: email, emailStatus: .valid, password: password)
        
        let store = TestStore(
            initialState: initialState,
            reducer: {
                LoginReducer()
            }, withDependencies: {
                $0.emailValidator = EmailValidator()
                $0.loginAPIClient = LoginAPIClient { _ in
                    return email + password
                }
            }
        )
        
        await store.send(.didTapLoginButton)
        await store.receive(.didLogin(.success(email + password)))
    }
}

