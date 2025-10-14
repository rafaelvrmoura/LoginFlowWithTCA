//
//  APIClient.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 13/10/25.
//

import ComposableArchitecture

typealias AuthToken = String
private typealias UserEmail = String

private var UsersDB: [UserEmail: UserModel] = ["email@test.com": UserModel(email: "email@test.com",
                                                                           password: "password",
                                                                           photo: nil)]

enum APIError: Error {
    case invalidCredentials
}

struct APIClient {
    
    func login(email: String, password: String) -> Result<AuthToken, APIError> {
        
        // TODO: - Encrypt password
        guard let user = UsersDB[email], user.password == password else {
            
            return .failure(.invalidCredentials)
        }
        
        return .success(email + password)
    }
}

extension APIClient: DependencyKey {
    
    static var liveValue: APIClient = .init()
}

extension DependencyValues {
    
    var apiClient: APIClient {
        
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
