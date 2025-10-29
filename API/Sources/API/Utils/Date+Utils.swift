//
//  Date+Utils.swift
//  API
//
//  Created by Rafael Vieira Moura on 29/10/25.
//

import Foundation
import JWT

extension Date {
    
    static var tomorrow: Date {
        
        let calendar = Calendar.current
        
        var components: DateComponents = .init()
        components.day = 1
        
        return calendar.date(byAdding: components, to: Date())!
    }
}

extension ExpirationClaim {
    
    static var tokenExpiration: Self {
        
        return .init(value: .tomorrow)
    }
}
