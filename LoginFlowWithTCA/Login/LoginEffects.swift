//
//  LoginEffects.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 13/10/25.
//

import ComposableArchitecture

func login(email: String, password: String, APIClient: APIClient) -> EffectOf<LoginReducer> {
    
    return .send(.didLogin(APIClient.login(email: email, password: password)))
}

func dummyLogin(email: String, password: String, APIClient: APIClient) -> EffectOf<LoginReducer> {
    
    return .send(.didLogin(.success(email + password)))
}
