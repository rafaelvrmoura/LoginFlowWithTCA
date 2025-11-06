//
//  UsersAPI.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 30/10/25.
//

import Foundation

enum UsersAPI: APIProtocol {
    
    var headers: [HTTPHeaderField : String]? {
        
        switch self {
        case .me, .delete: nil
        case .create, .update: [.ContentType: "application/json"]
        case .uploadProfilePicture: [.ContentType: "image/jpeg"]
        }
    }
    
    var path: String {
        
        switch self {
        case .me: "v1/users/me"
        case .create: "v1/users"
        case .update(let user): "v1/users/\(user.id ?? "")"
        case .delete(let userId): "v1/users/\(userId)"
        case .uploadProfilePicture(_, let userId): "v1/users/\(userId)/profile-picture"
        }
    }
    
    var body: Data? {
        
        switch self {
        case .me, .delete: nil
        case .create(let userModel),
            .update(let userModel): try? JSONEncoder().encode(userModel)
            
        case .uploadProfilePicture(let data, _): data
        }
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
    
    var httpMethod: HTTPMethod {
        
        switch self {
        case .me: .GET
        case .create,
             .uploadProfilePicture: .POST
        case .update: .PATCH
        case .delete: .DELETE
        }
    }
    
    case me
    case create(user: UserModel)
    case update(user: UserModel)
    case delete(userId: String)
    case uploadProfilePicture(Data, userId: String)
}
