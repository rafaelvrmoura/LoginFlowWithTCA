//
//  ProfileView.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 06/11/25.
//

import SwiftUI
import ComposableArchitecture

struct ProfileView: View {
    
    @Bindable
    var store: StoreOf<ProfileReducer>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                Text("Welcome, \(viewStore.user.name)!")
                    .font(.largeTitle)
                    .padding()
            }
        }
    }
}
