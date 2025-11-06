//
//  LoginView.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 11/10/25.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
    
    @Bindable
    var store: StoreOf<LoginReducer>
    @State private var passwordFieldVisible: Bool = false
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack(alignment: .center) {
                    Text("TCA")
                        .font(Font.system(size: 100).bold())
                    emailField(with: viewStore)
                        .padding([.leading, .trailing])
                        .padding(.bottom, 5)
                    passwordField(with: viewStore)
                        .padding([.leading, .trailing])
                    forgotPasswordButton(with: viewStore)
                        .padding([.leading, .trailing])
                    buttonsStack(with: viewStore)
                        .padding()
                }
            }
            .overlay {
                if viewStore.isLoading {
                    ZStack {
                        Color.black.opacity(0.7)
                        ProgressView()
                            .tint(.white)
                    }
                    .allowsHitTesting(true)
                    .ignoresSafeArea()
                    
                }
            }
            .defaultScrollAnchor(.center)
        }
        .alert(
            $store.scope(
                state: \.destination?.alert,
                action: \.destination.alert))
        .sheet(
            item: $store.scope(
                state: \.destination?.signupForm,
                 action: \.destination.signupForm
            )
        ) { signupFormStore in
            NavigationStack {
                SignupFormView(store: signupFormStore)
                    .toolbar {
                        ToolbarItem(
                            placement: .cancellationAction
                        ) {
                            Button(action: {
                                store.send(.dismissSigupForm)
                            }) {
                                Image(systemName: "xmark")
                            }
                        }
                    }
            }
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
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
        }
        .buttonStyle(.glass)
        .glassEffect(.regular.tint(.blue))
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func registerButton(with viewStore: ViewStoreOf<LoginReducer>) -> some View {
        Button(action: {
            viewStore.send(.didTapRegisterButton)
        }) {
            Text("Create Account")
                .foregroundStyle(.white)
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
        }
        .buttonStyle(.glass)
        .glassEffect(.regular.tint(.gray))
        .padding(.horizontal, 20)
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
        
        ZStack(alignment: .trailing) {
            if passwordFieldVisible {
                
                TextField(
                    "Password",
                    text: viewStore.binding(
                        get: \.password,
                        send: { .didChangePassword($0) }
                    )
                )
                .textFieldStyle(.roundedBorder)
                
            } else {
                
                SecureField(
                    "Password",
                    text: viewStore.binding(
                        get: \.password,
                        send: { .didChangePassword($0) }
                    )
                )
                .textFieldStyle(.roundedBorder)
            }
            Button {
                passwordFieldVisible.toggle()
            } label: {
                Image(systemName: passwordFieldVisible ? "lock.open" : "lock")
                    .tint(.gray)
            }
            .padding(.trailing, 5)
        }
    }
}

private struct LoginMock: LoginAPIProtocol {
    typealias API = LoginAPI
    var delegate: (any APIClientDelegate)?
    func login(email: String, password: String) async throws -> AuthResult {
        throw APIClientError.failed(statusCode: 300)
    }
    
    func logout() async throws { }
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
                $0.loginAPIClient = LoginMock()
            }
        )
    )
}
