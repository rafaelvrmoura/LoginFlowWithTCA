//
//  User.swift
//  API
//
//  Created by Rafael Vieira Moura on 26/10/25.
//

import Fluent
import Foundation

final class User: Model, @unchecked Sendable {
    
    static let schema = "users"
    
    @ID(key: .id) var id: UUID?
    @Field(key: "name") var name: String
    @Field(key: "email") var email: String
    @Field(key: "password") var password: String
    @Field(key: "preferred_theme") var preferredTheme: String?
    @Field(key: "profile_picture_url") var profilePictureURL: String?
    
    init() { }
    convenience init(
        id: UUID?,
        name: String,
        email: String,
        password: String,
        preferredTheme: String?,
        profilePictureURL: String?
    ) {
     
        self.init()
        
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.preferredTheme = preferredTheme
        self.profilePictureURL = profilePictureURL
    }
    
    func toDTO() -> UserDTO {
        
        return .init(
            id: self.id,
            name: self.$name.value,
            email: self.$email.value,
            password: self.$password.value,
            preferredTheme: self.$preferredTheme.value ?? nil,
            profilePictureURL: self.$profilePictureURL.value ?? nil)
    }
}
