//
//  PasswordValidator.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 13/10/25.
//

import Foundation
import ComposableArchitecture

struct PasswordValidator {
    
    private let regex = #"^(?=.*[A-Za-z])(?=.*\d).{6,}$"#
    
    func isValid(password: String) -> Bool {
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: password)
    }
}

extension PasswordValidator: DependencyKey {
    
    static var liveValue = PasswordValidator()
}

extension DependencyValues {
    
    var passwordValidator: PasswordValidator {
        get { self[PasswordValidator.self] }
        set { self[PasswordValidator.self] = newValue }
    }
}
