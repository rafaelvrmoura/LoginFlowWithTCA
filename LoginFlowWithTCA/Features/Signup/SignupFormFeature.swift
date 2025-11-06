//
//  SignupFormReducer.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 16/10/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct SignupFormReducer {
    
    @Dependency(\.usersAPI) var apiClient
    @Dependency(\.emailValidator) var emailValidator
    @Dependency(\.passwordValidator) var passwordValidator
    @Dependency(\.dismiss) var dismiss
 
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        
        case alert(AlertState<Alert>)
        
        @CasePathable
        enum Alert {
            
            case confirm
        }
    }
    
    @ObservableState
    struct State: Equatable {
        
        var name: String = ""
        var email: String = ""
        var emailStatus: InputStatus = .idle
        var password: String = ""
        var passwordStatus: InputStatus = .idle
        var passwordConfirmation: String = ""
        var passwordConfirmationStatus: InputStatus = .idle
        var isLoading: Bool = false
        
        @Presents var destination: Destination.State?
    }
    
    @CasePathable
    enum Action: BindableAction, Equatable {
     
        case didChangePassword(String)
        case didSubmitPassword
        case didChangePasswordConfirmation(String)
        case didSubmitPasswordConfirmation
        case didChangeEmail(String)
        case didSubmitEmail
        case didTapSignupButton
        case didSignup(Result<UserModel, NSError>)
        
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
            .onChange(of: \.email) { oldValue, newValue in
                Reduce { state, action in
                    return .run { send in await send(.didChangeEmail(newValue)) }
                }
            }
            .onChange(of: \.password) { oldValue, newValue in
                Reduce { state, action in
                    return .run { send in await send(.didChangePassword(newValue)) }
                }
            }
            .onChange(of: \.passwordConfirmation) { oldValue, newValue in
                Reduce { state, action in
                    return .run { send in await send(.didChangePasswordConfirmation(newValue)) }
                }
            }
        Reduce { state, action in
            
            switch action {
                
            case .destination(.presented(.alert(let alertAction))):
                switch alertAction {
                case .confirm:
                    return .run { _ in await dismiss() }
                }
                
            case .destination:
                return .none
                
            case .binding:
                return .none
                
            case .didChangeEmail(let email):
                state.emailStatus = emailValidator.isValid(email: email) ? .valid : .idle
                return .none
                
            case .didSubmitEmail:
                state.emailStatus = emailValidator.isValid(email: state.email) ? .valid : .invalid
                return .none
                
            case .didChangePassword(let password):
                state.passwordStatus = passwordValidator.isValid(password: password) ? .valid : .idle
                return .none
                
            case .didSubmitPassword:
                state.passwordStatus = passwordValidator.isValid(password: state.password) ? .valid : .invalid
                return .none
                
            case .didChangePasswordConfirmation(let confirmation):
                state.passwordConfirmationStatus = passwordValidator.isValid(password: confirmation) &&
                                                         state.password == confirmation ?
                                                         .valid : .idle
                return .none
                
            case .didSubmitPasswordConfirmation:
                state.passwordConfirmationStatus = passwordValidator.isValid(password: state.passwordConfirmation) &&
                                                                     state.password == state.passwordConfirmation ?
                                                                     .valid : .invalid
                return .none
                
            case .didTapSignupButton:
                if state.emailStatus != .valid {
                    state.emailStatus = .invalid
                }
                
                if state.passwordStatus != .valid {
                    state.passwordStatus = .invalid
                }
                
                if state.passwordConfirmationStatus != .valid {
                    state.passwordConfirmationStatus = .invalid
                }
                
                guard state.emailStatus == .valid &&
                        state.passwordStatus == .valid &&
                        state.passwordConfirmationStatus == .valid else {
                    
                    return .none
                }
                
                let userModel = UserModel(
                    name: state.name,
                    email: state.email,
                    password: state.password,
                )
                
                state.isLoading = true
                return .run { send in
                    
                    do {
                        let user = try await self.apiClient.create(user: userModel)
                        
                        await send(.didSignup(.success(user)))
                        
                    } catch {
                        
                        await send(.didSignup(.failure(error as NSError)))
                    }
                }
                
            case .didSignup(let result):
                state.isLoading = false
                switch result {
                case .success:
                    return .run { _ in await dismiss() }
                case .failure(let error):
                    state.destination = .alert(AlertState {
                        TextState("Error")
                    } actions: {
                        ButtonState(action: .confirm) {
                          TextState("Ok")
                        }
                    } message: {
                        TextState(error.localizedDescription)
                    })
                    return .none
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
