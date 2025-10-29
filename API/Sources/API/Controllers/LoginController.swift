//
//  LoginController.swift
//  API
//
//  Created by Rafael Vieira Moura on 28/10/25.
//

import Fluent
import Vapor
import JWT

struct LoginController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        
        let loginRoute = routes.grouped("login")
        loginRoute.post(use: login)
        loginRoute.delete(use: logout)
    }
    
    func login(req: Request) async throws -> AuthResult {
        
        let loginRequest = try req.content.decode(LoginRequest.self)
        
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == loginRequest.email)
            .filter(\.$password == loginRequest.password)
            .first(),
              let userId = user.id else {
            
            throw Abort(.unauthorized)
        }
        
        let authPayload = AuthPayload(subject: "vapor",
                                      expiration: .tokenExpiration,
                                      userId: userId)
        
        let token = try await req.jwt.sign(authPayload)
        
        let session = Session(token: token)
        
        try await session.save(on: req.db)
        
        return AuthResult(token: token)
    }
    
    func logout(req: Request) async throws -> HTTPStatus {
        
        let (session, _) = try await req.authenticate()
        
        _ = try? await session.delete(on: req.db)
        
        return .noContent
    }
}

