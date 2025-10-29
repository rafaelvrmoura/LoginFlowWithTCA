//
//  Application+Utils.swift
//  API
//
//  Created by Rafael Vieira Moura on 29/10/25.
//

import Vapor

extension Application {
    
    var uploadsDirectory: String {
        self.directory.publicDirectory + "uploads/"
    }
    
    var uploadsURL: String {
        
        "http://" +
        self.http.server.configuration.hostname +
        ":" +
        String(self.http.server.configuration.port) +
        "/uploads/"
    }
}
