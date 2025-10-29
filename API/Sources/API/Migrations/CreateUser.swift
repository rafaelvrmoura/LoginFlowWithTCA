//
//  CreateUser.swift
//  API
//
//  Created by Rafael Vieira Moura on 27/10/25.
//

import Fluent

struct CreateUser: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        try await database.schema(User.schema)
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("password", .string, .required)
            .field("preferred_theme", .string)
            .field("profile_picture_url", .string)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(User.schema).delete()
    }
}
