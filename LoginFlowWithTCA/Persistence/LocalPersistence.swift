//
//  LocalPersistence.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 15/10/25.
//

typealias UserEmail = String

class LocalPersistence {
    
    private var users: [UserEmail: UserModel] = [:]
    
    func user(email: String) -> UserModel? {
            
        return self.users[email]
    }
    
    func save(user: UserModel) {
        
        self.users[user.email] = user
    }
    
    static var shared: LocalPersistence = {
        
        LocalPersistence()
    }()
}
