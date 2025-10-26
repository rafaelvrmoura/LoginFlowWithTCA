//
//  UserModel.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 13/10/25.
//

import Foundation

struct UserModel: Equatable {
 
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var preferredTheme: ThemeModel? = nil
    var photo: Data? = nil
}
