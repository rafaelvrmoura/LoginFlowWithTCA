//
//  LoginAPI.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 30/10/25.
//

import Foundation

struct LoginRequestModel: Encodable {
    
    let email: String
    let password: String
}

enum LoginAPI: APIProtocol {
    
    var headers: [HTTPHeaderField : String]? {
        
        switch self {
        case .login: return [.ContentType: "application/json"]
        case .logout: return [:]
        }
    }
    
    var path: String {
    
        switch self {
        case .login: return "v1/login"
        case .logout: return "v1/logout"
        }
    }
    
    var body: Data? {
        
        switch self {
        case .login(let email, let password):
            return try? JSONEncoder().encode(LoginRequestModel(email: email, password: password))
        case .logout:
            return nil
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .login: return .POST
        case .logout: return .DELETE
        }
    }
    
    var queryItems: [URLQueryItem]? { nil }
    
    case login(email: String, password: String)
    case logout
}
