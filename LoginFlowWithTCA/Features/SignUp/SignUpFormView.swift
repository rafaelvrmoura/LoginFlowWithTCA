//
//  SignUpFormView.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 16/10/25.
//

import SwiftUI
import ComposableArchitecture

struct SignUpFormView: View {
    
    let store: StoreOf<SignUpFormReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Form {
                photoSelectionView(with: viewStore)
                nameField(with: viewStore)
                emailField(with: viewStore)
                passwordField(with: viewStore)
            }
            signUpButton(with: viewStore)
        }
    }
    
    @ViewBuilder
    private func signUpButton(with viewStore: ViewStoreOf<SignUpFormReducer>) -> some View {
        
        Button(action: {
            viewStore.send(.didTapSignUpButton)
        }) {
            Text("Sing Up")
                .padding(.top)
                .frame(maxWidth: .infinity)
                .background(.blue)
                .foregroundStyle(.white)
                .font(Font.title.bold())
        }
    }
    
    @ViewBuilder
    private func photoSelectionView(with viewStore: ViewStoreOf<SignUpFormReducer>) -> some View {
        Button(action: {
            // TODO: Show image picker
        }) {
            ZStack(alignment: .bottomTrailing) {
                Image(
                    systemName: "person.crop.circle"
                )
                .resizable()
                .frame(width: 100, height: 100)
                .font(.largeTitle)
                .cornerRadius(50)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    @ViewBuilder
    private func nameField(with viewStore: ViewStoreOf<SignUpFormReducer>) -> some View {
        TextField(
            "Full Name",
            text: viewStore.binding(
                get: \.name,
                send: { .didChangeName($0) }
            )
        )
    }
    
    @ViewBuilder
    private func emailField(with viewStore: ViewStoreOf<SignUpFormReducer>) -> some View {
     
        TextField(
            "Email",
            text: viewStore.binding(
                get: \.email,
                send: { .didChangeEmail($0) }
            )
        )
        .onSubmit {
            viewStore.send(.didSubmitEmail)
        }
    }
    
    @ViewBuilder
    private func passwordField(with viewStore: ViewStoreOf<SignUpFormReducer>) -> some View {
        TextField(
            "Password",
            text: viewStore.binding(
                get: \.name,
                send: { .didChangeName($0) }
            )
        )
        .onSubmit {
            viewStore.send(.didSubmitPassword)
        }
    }
}

#Preview {
    NavigationStack {
        SignUpFormView(
            store: Store(
                initialState: .init(),
                reducer: {
                    SignUpFormReducer()
                }
            )
        )
    }
}
