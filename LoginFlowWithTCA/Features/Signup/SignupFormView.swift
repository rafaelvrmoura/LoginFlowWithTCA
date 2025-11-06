//
//  SignUpFormView.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 16/10/25.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture

struct SignupFormView: View {
    
    @Bindable var store: StoreOf<SignupFormReducer>
    @State var passwordVisible: Bool = false
    @State var passwordConfirmationVisible: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Form {
                nameField()
                emailField()
                passwordField()
                confirmPasswordField()
            }
            signUpButton()
        }
        .alert(
            $store.scope(
                state: \.destination?.alert,
                action: \.destination.alert))
        .overlay {
            if store.isLoading {
                ZStack {
                    Color.black.opacity(0.7)
                    ProgressView()
                        .tint(.white)
                }
                .allowsHitTesting(true)
                .ignoresSafeArea()
                
            }
        }
    }
    
    @ViewBuilder
    private func signUpButton() -> some View {
        
        Button(action: {
            store.send(.didTapSignupButton)
        }) {
            Text("Sing Up")
                .frame(maxWidth: .infinity)
                .font(Font.title.bold())
                .padding(10)
        }
        .buttonStyle(.glass)
        .glassEffect(.regular.tint(.blue))
        .tint(.white)
        .padding()
    }
    
    @ViewBuilder
    private func nameField() -> some View {
        TextField(
            "Full Name",
            text: $store.name
        )
    }
    
    @ViewBuilder
    private func emailField() -> some View {
     
        ZStack(alignment: .trailing) {
            TextField(
                "Email",
                text: $store.email
            )
            .textInputAutocapitalization(.never)
            .onSubmit { store.send(.didSubmitEmail) }
            .keyboardType(.emailAddress)
            inputStatusIndicator(for: store.state.emailStatus)
                .padding(.trailing, 5)
        }
    }
    
    @ViewBuilder
    private func passwordField() -> some View {
        HStack {
            if passwordVisible {
                TextField(
                    "Password",
                    text: $store.password
                )
                .textInputAutocapitalization(.never)
                .onSubmit { store.send(.didSubmitPassword) }
            } else {
                SecureField(
                    "Password",
                    text: $store.password
                )
                .textInputAutocapitalization(.never)
                .onSubmit { store.send(.didSubmitPassword) }
            }
            inputStatusIndicator(for: store.state.passwordStatus)
                .padding(.trailing, 5)
            Button {
                passwordVisible.toggle()
            } label: {
                Image(systemName: passwordVisible ? "lock.open" : "lock")
                    .font(.title2)
                    .tint(.gray)
            }
        }
    }
    
    @ViewBuilder
    private func confirmPasswordField() -> some View {
        HStack {
            if passwordConfirmationVisible {
                
                TextField(
                    "Confirm Password",
                    text: $store.passwordConfirmation
                )
                .textInputAutocapitalization(.never)
                .onSubmit { store.send(.didSubmitPasswordConfirmation) }
                
            } else {
                
                SecureField(
                    "Confirm Password",
                    text: $store.passwordConfirmation
                )
                .textInputAutocapitalization(.never)
                .onSubmit { store.send(.didSubmitPasswordConfirmation) }
            }
            inputStatusIndicator(for: store.state.passwordConfirmationStatus)
                .padding(.trailing, 5)
            Button {
                passwordConfirmationVisible.toggle()
            } label: {
                Image(systemName: passwordConfirmationVisible ? "lock.open" : "lock")
                    .font(.title2)
                    .tint(.gray)
            }
        }
    }
    
    @ViewBuilder
    private func inputStatusIndicator(for status: InputStatus) -> some View {
        
        if status == .valid {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        } else if status == .invalid {
            Image(systemName: "x.circle.fill")
                .foregroundStyle(.red)
        }
    }
}

private struct UsersAPIMock: UsersAPIProtocol {
    
    typealias API = UsersAPI
    
    func create(user: UserModel) async throws -> UserModel {
        throw NSError()
    }
    
    var delegate: (any APIClientDelegate)?
}

#Preview {
    NavigationStack {
        SignupFormView(
            store: Store(
                initialState: .init(),
                reducer: {
                    SignupFormReducer()
                },
                withDependencies: {
                    $0.usersAPI = UsersAPIMock()
                    $0.emailValidator = EmailValidator()
                    $0.passwordValidator = PasswordValidator()
                }
            )
        )
    }
}
