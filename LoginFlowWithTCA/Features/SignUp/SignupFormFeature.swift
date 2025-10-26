//
//  SignupFormReducer.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 16/10/25.
//

import UIKit
import PhotosUI
import ComposableArchitecture

@Reducer
struct SignupFormReducer {
    
    @Dependency(\.signUpAPI) var apiClient
    @Dependency(\.emailValidator) var emailValidator
    @Dependency(\.passwordValidator) var passwordValidator
    @Dependency(\.dismiss) var dismiss
 
    @ObservableState
    struct State: Equatable {
        
        var photoPickerState: PhotoPickerReducer.State = .init()
        var name: String = ""
        var email: String = ""
        var emailStatus: InputStatus = .idle
        var password: String = ""
        var passwordStatus: InputStatus = .idle
        var passwordConfirmation: String = ""
        var passwordConfirmationStatus: InputStatus = .idle
        var isLoading: Bool = false
        var error: SignUpAPIClient.Error? = nil
    }
    
    @CasePathable
    enum Action: BindableAction, Equatable {
     
        case didChangePassword(String)
        case didSubmitPassword
        case didChangePasswordConfirmation(String)
        case didSubmitPasswordConfirmation
        case didChangeEmail(String)
        case didSubmitEmail
        case photoPickerAction(PhotoPickerReducer.Action)
        case didTapSignupButton
        case didSignup(Result<UserModel, SignUpAPIClient.Error>)
        
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
        Scope(state: \.photoPickerState,
              action: \.photoPickerAction,
              child: {
          PhotoPickerReducer()
        })
        Reduce { state, action in
            
            switch action {
                
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
                
            case .photoPickerAction:
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
                
                var photoData: Data?
                
                if case .loaded(let image) = state.photoPickerState.selectionState {
                    photoData = image.pngData()
                }
                
                let userModel = UserModel(
                    name: state.name,
                    email: state.email,
                    password: state.password,
                    photo: photoData
                )
                
                state.isLoading = true
                return .run { send in
                    
                    do {
                        let recordedUser = try await self.apiClient.createUser(userModel)
                        await send(.didSignup(.success(recordedUser)))
                    } catch {
                        await send(.didSignup(.failure(SignUpAPIClient.Error.unknown)))
                    }
                }
                
            case .didSignup(let result):
                state.isLoading = false
                switch result {
                case .success:
                    return .run { _ in await dismiss() }
                case .failure(let error):
                    state.error = error
                    return .none
                }
            }
        }
    }
}
