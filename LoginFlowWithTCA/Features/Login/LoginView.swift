//
//  LoginView.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 11/10/25.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
    
    let store: StoreOf<LoginReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack(alignment: .center) {
                    emailField(with: viewStore)
                    .padding([.leading, .trailing])
                    passwordField(with: viewStore)
                    .padding([.leading, .trailing])
                    forgotPasswordButton(with: viewStore)
                    .padding([.leading, .trailing])
                    buttonsStack(with: viewStore)
                    .padding()
                }
            }
            .defaultScrollAnchor(.center)
        }
    }
    
    @ViewBuilder
    private func buttonsStack(with viewStore: ViewStoreOf<LoginReducer>) -> some View {
        VStack(spacing: 10) {
            loginButton(with: viewStore)
            Text("or")
            registerButton(with: viewStore)
        }
    }
    
    @ViewBuilder
    private func forgotPasswordButton(with viewStore: ViewStoreOf<LoginReducer>) -> some View {
        Button(action: {
            viewStore.send(.didTapForgotPasswordButton)
        }) {
          Text("Forgot password")
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        
    }
    
    
    @ViewBuilder
    private func loginButton(with viewStore: ViewStoreOf<LoginReducer>) -> some View {
        Button(action: {
            viewStore.send(.didTapLoginButton)
        }) {
            Text("Login")
                .foregroundStyle(.white)
                .frame(width: 200, height: 50)
                .background {
                    Color.blue
                }
        }
    }
    
    @ViewBuilder
    private func registerButton(with viewStore: ViewStoreOf<LoginReducer>) -> some View {
        Button(action: {
            viewStore.send(.didTapRegisterButton)
        }) {
            Text("Create Account")
                .frame(width: 200, height: 50)
                .border(.blue)
        }
    }
    
    //MARK: - Email field
    @ViewBuilder
    private func emailField(with viewStore: ViewStoreOf<LoginReducer>) -> some View {
        
        ZStack(alignment: .trailing) {
            TextField(
                "Email",
                text: viewStore.binding(
                    get: \.email,
                    send: { .didChangeEmail($0) }
                )
            )
            .textInputAutocapitalization(.never)
            .onSubmit { viewStore.send(.didSubmitEmail) }
            .keyboardType(.emailAddress)
            .textFieldStyle(.roundedBorder)
            emailStatusIndicator(with: viewStore)
                .padding(.trailing, 5)
        }
    }
    
    @ViewBuilder
    private func emailStatusIndicator(with viewStore: ViewStoreOf<LoginReducer>) -> some View {
        
        if viewStore.state.emailStatus == .valid {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        } else if viewStore.state.emailStatus == .invalid {
            Image(systemName: "x.circle.fill")
                .foregroundStyle(.red)
        }
    }
    
    // MARK: - Password field
    @ViewBuilder
    private func passwordField(with viewStore: ViewStoreOf<LoginReducer>) -> some View {
        
        SecureField(
            "Password",
            text: viewStore.binding(
                get: \.password,
                send: { .didChangePassword($0) }
            )
        )
        .textFieldStyle(.roundedBorder)
    }
}

#Preview {
    LoginView(
        store: Store(
            initialState: .init(),
            reducer: {
                LoginReducer()
            },
            withDependencies: {
                $0.emailValidator = .liveValue
                $0.loginAPIClient = LoginAPIClient {
                    return $0.email + $0.password
                }
            }
        )
    )
}
