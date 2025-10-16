//
//  SignUpFormReducer.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 16/10/25.
//

import UIKit
import ComposableArchitecture

@Reducer
struct SignUpFormReducer {
    
    struct State: Equatable {
        
        var photo: UIImage?
        var name: String = ""
        var email: String = ""
        var emailStatuns: InputStatus = .idle
        var password: String = ""
        var passwordStatus: InputStatus = .idle
    }
    
    enum Action: Equatable {
     
        case didChangeName(String)
        case didChangePassword(String)
        case didSubmitPassword
        case didChangeEmail(String)
        case didSubmitEmail
        case didTapSelectPhoto
        case didSelectPhoto(UIImage)
        case didTapSignUpButton
    }
    
    var body: some Reducer<State, Action> {
        
        Reduce { state, action in
            
            switch action {
                
            case .didChangeName(let name):
                state.name = name
                return .none
                
            case .didChangeEmail(let email):
                state.email = email
                return .none
                
            case .didSubmitEmail:
                
                return .none
                
            case .didChangePassword(let password):
                state.password = password
                return .none
                
            case .didSubmitPassword:
                return .none
                
            case .didTapSelectPhoto:
                return .none
                
            case .didSelectPhoto(let image):
                return .none
                
            case .didTapSignUpButton:
                
                guard state.emailStatus == .valid else {
                    return .none
                }
                
                guard state.passwordStatus == .valid else {
                    return .none
                }
                
                return .none
            }
        }
    }
}
