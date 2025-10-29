//
//  Session.swift
//  API
//
//  Created by Rafael Vieira Moura on 29/10/25.
//

import Fluent
import Vapor

final class Session: Model, @unchecked Sendable {
    
    static let schema = "sessions"
    
    @ID var id: UUID?
    @Field(key: "token") var token: String
    
    init() { }
    
    convenience init(
        id: UUID? = nil,
        token: String) {
        
        self.init()
            
        self.id = UUID()
        self.token = token
    }
}
