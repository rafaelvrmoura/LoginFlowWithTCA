//
//  EmailValidator.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 13/10/25.
//

import ComposableArchitecture
import Foundation

struct EmailValidator {
    
    let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    func isValid(email: String) -> Bool {

        let emailPred = NSPredicate(format:"SELF MATCHES %@", self.regex)
        return emailPred.evaluate(with: email)
    }
}

extension EmailValidator: DependencyKey {
    
    static var liveValue: EmailValidator = .init()
}

extension DependencyValues {
    
    var emailValidator: EmailValidator {
        get { self[EmailValidator.self] }
        set { self[EmailValidator.self] = newValue }
    }
}
