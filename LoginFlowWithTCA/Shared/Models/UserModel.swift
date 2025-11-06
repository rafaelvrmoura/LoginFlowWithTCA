//
//  UserModel.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 13/10/25.
//

import Foundation

struct UserModel: Codable, Equatable {
 
    var id: String? = nil
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var preferredTheme: ThemeModel? = nil
    var profilePictureURL: URL? = nil
}
