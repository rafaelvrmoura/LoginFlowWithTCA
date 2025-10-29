//
//  LoginRequest.swift
//  API
//
//  Created by Rafael Vieira Moura on 29/10/25.
//

import Vapor

struct LoginRequest: Content {
    
    let email: String
    let password: String
}
