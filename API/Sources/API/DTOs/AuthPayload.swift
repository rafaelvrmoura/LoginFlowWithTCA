//
//  AuthPayload.swift
//  API
//
//  Created by Rafael Vieira Moura on 29/10/25.
//

import Vapor
import JWT

struct AuthPayload: JWTPayload {
    
    enum CodingKeys: String, CodingKey {
        
        case subject = "sub"
        case expiration = "exp"
        case userId
    }
    
    var subject: SubjectClaim
    var expiration: ExpirationClaim
    var userId: UUID
    
    func verify(using algorithm: some JWTAlgorithm) async throws {
        try self.expiration.verifyNotExpired()
    }
}
