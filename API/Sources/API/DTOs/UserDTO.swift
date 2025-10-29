//
//  UserDTO.swift
//  API
//
//  Created by Rafael Vieira Moura on 26/10/25.
//

import Fluent
import Vapor

struct UserDTO: Content {
    
    var id: UUID?
    var name: String?
    var email: String?
    var password: String?
    var preferredTheme: String?
    var profilePictureURL: String?
    
    func toModel() -> User {
     
        let model = User()
        
        if let id = self.id {
            model.id = id
        }
        
        if let name = self.name {
            model.name = name
        }
        
        if let email = self.email {
            model.email = email
        }
        
        if let password = self.password {
            model.password = password
        }
        
        if let theme = self.preferredTheme {
            model.preferredTheme = theme
        }
        
        if let pictureURL = self.profilePictureURL {
            model.profilePictureURL = pictureURL
        }
        
        return model
    }
}
