//
//  SignupFeatureTests.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 23/10/25.
//

import Testing
import ComposableArchitecture

@testable import LoginFlowWithTCA

@MainActor
struct SignupFeatureTests {
    
    @Test
    func happyPath() async {
        
        let name = "Test"
        let validEmail = "test@test.com"
        let validPassword = "p422w0rd"
        let expectedUserModel = UserModel(name: name,
                                          email: validEmail,
                                          password: validPassword,
                                          preferredTheme: nil,
                                          photo: nil)
        
        let store = TestStore(
            initialState: SignupFormReducer.State(),
            reducer: {
                SignupFormReducer()
            },
            withDependencies: {
                $0.emailValidator = .liveValue
                $0.passwordValidator = .liveValue
                $0.signUpAPI = SignUpAPIClient { _ in
                    return expectedUserModel
                }
            }
        )
        
        // Type name
        await store.send(.binding(.set(\.name, name))) {
            $0.name = name
        }
        
        // Type email
        await store.send(.binding(.set(\.email, validEmail))) {
            $0.email = validEmail
        }
        await store.receive(.didChangeEmail(validEmail)) {
            $0.emailStatus = .valid
        }
        
        // Type password
        await store.send(.binding(.set(\.password, validPassword))) {
            $0.password = validPassword
        }
        await store.receive(.didChangePassword(validPassword)) {
            $0.passwordStatus = .valid
        }
        
        // Type password confirmation
        await store.send(.binding(.set(\.passwordConfirmation, validPassword))) {
            $0.passwordConfirmation = validPassword
        }
        
        await store.receive(.didChangePasswordConfirmation(validPassword)) {
            $0.passwordConfirmationStatus = .valid
        }

        // Tap signup button
        await store.send(.didTapSignupButton) {
            $0.isLoading = true
        }
        
        await store.receive(.didSignup(.success(expectedUserModel))) {
            $0.isLoading = false
        }
    }
    
    @Test
    func signupFailure() async {
        
        let state = SignupFormReducer.State(
            name: "Test",
            email: "test@test.com",
            emailStatus: .valid,
            password: "p422w0rd",
            passwordStatus: .valid,
            passwordConfirmation: "p422w0rd",
            passwordConfirmationStatus: .valid)
        
        let store = TestStore(
            initialState: state,
            reducer: {
                SignupFormReducer()
            },
            withDependencies: {
                $0.emailValidator = .liveValue
                $0.passwordValidator = .liveValue
                $0.signUpAPI = SignUpAPIClient { _ in
                    throw SignUpAPIClient.Error.unknown
                }
            }
        )
    
        // Tap signup button
        await store.send(.didTapSignupButton) {
            $0.isLoading = true
        }
        
        await store.receive(.didSignup(.failure(SignUpAPIClient.Error.unknown))) {
            $0.isLoading = false
            $0.error = SignUpAPIClient.Error.unknown
        }
    }
    
    @Test
    func missingRequiredFields() async {
        
        let store = TestStore(
            initialState: SignupFormReducer.State(),
            reducer: {
                SignupFormReducer()
            },
            withDependencies: {
                $0.emailValidator = .liveValue
                $0.passwordValidator = .liveValue
                $0.signUpAPI = SignUpAPIClient { _ in
                    throw SignUpAPIClient.Error.unknown
                }
            }
        )
        
        // Tap signup button
        await store.send(.didTapSignupButton) {
            $0.emailStatus = .invalid
            $0.passwordStatus = .invalid
            $0.passwordConfirmationStatus = .invalid
        }
    }
}
