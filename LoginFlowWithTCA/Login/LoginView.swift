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
                VStack(alignment: .leading) {
                    emailField(with: viewStore)
                    .padding([.leading, .trailing])
                    passwordField(with: viewStore)
                    .padding([.leading, .trailing])
                    Button("Forgot password") {
                        viewStore.send(.didTapForgotPasswordButton)
                    }
                    .padding([.leading, .trailing])
                    HStack {
                        Spacer()
                        Button("Login") {
                            viewStore.send(.didTapLoginButton)
                        }
                        .buttonStyle(.borderedProminent)
                        Spacer()
                        Button("Create Account") {
                            viewStore.send(.didTapRegisterButton)
                        }
                        .buttonStyle(.borderedProminent)
                        Spacer()
                    }
                    .padding()
                }
            }
            .defaultScrollAnchor(.center)
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
    func passwordField(with viewStore: ViewStoreOf<LoginReducer>) -> some View {
        
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
            }
        )
    )
}
