//
//  SignUpAPIClient.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 16/10/25.
//

import ComposableArchitecture

struct SignUpAPIClient {
    
    enum Error: Swift.Error, Equatable {
        case unknown
    }
    
    var createUser: (UserModel) async throws -> UserModel
    
    static var live = SignUpAPIClient { userModel in
        
        LocalPersistence.shared.save(user: userModel)
        return userModel
    }
}

extension SignUpAPIClient: DependencyKey {
    
    static var liveValue: SignUpAPIClient = .live
}

extension DependencyValues {
    
    var signUpAPI: SignUpAPIClient {
        get { self[SignUpAPIClient.self] }
        set { self[SignUpAPIClient.self] = newValue }
    }
}
