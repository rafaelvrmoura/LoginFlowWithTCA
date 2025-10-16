//
//  APIClient.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 13/10/25.
//

import ComposableArchitecture

typealias AuthToken = String

struct LoginRequestModel {
    
    let email: String
    let password: String
}

struct LoginAPIClient {

    enum Error: Swift.Error {
        case invalidCredentials
    }
    
    var loginRequest: (LoginRequestModel) async throws -> AuthToken
    
    static var live = LoginAPIClient { requestModel in
        
        let email = requestModel.email
        let password = requestModel.password
        
        // TODO: - Encrypt password
        guard let user = LocalPersistence.shared.user(email: email),
              user.password == password else {
            
            throw Error.invalidCredentials
        }
        
        return email + password
    }
}

extension LoginAPIClient: DependencyKey {
    
    static var liveValue: LoginAPIClient = .live
}

extension DependencyValues {
    
    var loginAPIClient: LoginAPIClient {
        
        get { self[LoginAPIClient.self] }
        set { self[LoginAPIClient.self] = newValue }
    }
}
