//
//  Request+Utils.swift
//  API
//
//  Created by Rafael Vieira Moura on 29/10/25.
//

import Fluent
import Vapor
import JWT

extension Request {
 
    @discardableResult
    func authenticate() async throws -> (Session, AuthPayload) {
        
        let authPayload = try await self.jwt.verify(as: AuthPayload.self)
        
        let token = try await self.jwt.sign(authPayload)
        
        guard let session = try await Session.query(on: self.db)
            .filter(\.$token == token)
            .first()
        else {
            
            throw Abort(.unauthorized)
        }
        
        return (session, authPayload)
    }
}
