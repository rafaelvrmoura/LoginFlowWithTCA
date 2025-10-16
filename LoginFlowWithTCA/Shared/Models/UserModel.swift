//
//  UserModel.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 13/10/25.
//

import Foundation

struct UserModel {
 
    let name: String
    let email: String
    let password: String
    let preferredTheme: ThemeModel?
    let photo: Data?
}
