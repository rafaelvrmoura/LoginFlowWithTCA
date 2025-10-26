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
                photoSelectionView()
                nameField()
                emailField()
                passwordField()
                confirmPasswordField()
            }
            signUpButton()
        }
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
    private func photoSelectionView() -> some View {
        
        PhotoPickerView(
            store: store.scope(
                state: \.photoPickerState,
                action: \.photoPickerAction
            )
        ) {
            
            switch store.photoPickerState.selectionState {
            case .empty:
                Image(systemName: "person.crop.circle")
                    .resizable()  
            case .loading:
                ProgressView()
            case .loaded(let image):
                Image(uiImage: image)
                    .resizable()
            case .error:
                Image(systemName: "person.crop.circle.badge.xmark")
                    .resizable()
                    .tint(.red)
            }
        }
        .frame(width: 100,
               height: 100)
        .cornerRadius(50)
        .frame(maxWidth: .infinity, alignment: .center)
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

#Preview {
    NavigationStack {
        SignupFormView(
            store: Store(
                initialState: .init(isLoading: false),
                reducer: {
                    SignupFormReducer()
                },
                withDependencies: {
                    $0.signUpAPI = SignUpAPIClient {
                        return $0
                    }
                    $0.emailValidator = EmailValidator()
                    $0.passwordValidator = PasswordValidator()
                }
            )
        )
    }
}
