//
//  CreateSession.swift
//  API
//
//  Created by Rafael Vieira Moura on 29/10/25.
//

import Fluent
import Vapor

struct CreateSession: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        
        try await database.schema(Session.schema)
            .id()
            .field("token", .string, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Session.schema).delete()
    }
}
