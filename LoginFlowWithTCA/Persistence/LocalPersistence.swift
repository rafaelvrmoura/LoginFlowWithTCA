//
//  LocalPersistence.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 15/10/25.
//

typealias UserEmail = String

class LocalPersistence {
    
    var users: [UserEmail: UserModel] = [:]
    
    static var shared: LocalPersistence = {
        
        LocalPersistence()
    }()
}
