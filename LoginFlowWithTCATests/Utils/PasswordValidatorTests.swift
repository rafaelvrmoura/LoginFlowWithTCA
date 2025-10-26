//
//  PasswordValidatorTests.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 16/10/25.
//

import Testing
@testable import LoginFlowWithTCA

struct PasswordValidatorTests {
    
    @Test(arguments: ["Str0ngP4ssw0rd", "Valid123!", "A1b2c##"])
    func validPasswords(password: String) {
        
        let validator = PasswordValidator()
        #expect(validator.isValid(password: password))
    }
    
    @Test(arguments:["weakpassword", "123456", "sh0r1"])
    func invalidPasswords(password: String) {
        
        let validator = PasswordValidator()
        #expect(validator.isValid(password: password) == false)
    }
}
