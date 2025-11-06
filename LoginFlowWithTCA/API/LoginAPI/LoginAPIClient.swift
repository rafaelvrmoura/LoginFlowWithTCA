//
//  APIClient.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 13/10/25.
//

import Foundation
import ComposableArchitecture

struct AuthResult: Decodable, Equatable {
  
    let token: String
}

protocol LoginAPIProtocol: APIClient {
    
    func login(email: String, password: String) async throws -> AuthResult
    func logout() async throws
}

struct LoginAPIClient: LoginAPIProtocol {
    
    typealias API = LoginAPI
    
    var delegate: (any APIClientDelegate)?
    
    enum Error: Swift.Error, Equatable {
        
        case invalidCredentials
        case serverError
        case badResponse
    }
    
    func login(email: String, password: String) async throws -> AuthResult {
        
        return try await self.requestDecodable(.login(email: email, password: password))
    }
    
    func logout() async throws {
        
        try await self.request(.logout)
    }
}

extension LoginAPIClient: DependencyKey {
    
    static var liveValue: any LoginAPIProtocol = LoginAPIClient()
}

extension DependencyValues {
    
    var loginAPIClient: any LoginAPIProtocol {
        
        get { self[LoginAPIClient.self] }
        set { self[LoginAPIClient.self] = newValue }
    }
}
