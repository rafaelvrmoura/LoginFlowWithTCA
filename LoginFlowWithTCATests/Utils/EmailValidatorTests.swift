//
//  EmailValidatorTests.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 14/10/25.
//

import Testing

@testable import LoginFlowWithTCA

struct EmailValidatorTests {
    
    private let sut = EmailValidator()
    
    @Test
    func invalidEmail() {
        
        let invalidEmail = "rafael@test."
        
        #expect(sut.isValid(email: invalidEmail) == false)
    }
    
    @Test
    func validEmail() {
        
        let validEmail = "rafael.moura1234@test.com"
        
        #expect(sut.isValid(email: validEmail) == true)
    }
}
