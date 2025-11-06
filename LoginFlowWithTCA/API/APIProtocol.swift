//
//  APIProtocol.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 30/10/25.
//

import Foundation

enum HTTPMethod: String {
    case GET, POST, PUT, PATCH, HEAD, DELETE
}

protocol APIProtocol {
    
    var path: String { get }
    var body: Data? { get }
    var queryItems: [URLQueryItem]? { get }
    var httpMethod: HTTPMethod { get }
    var headers: [HTTPHeaderField: String]? { get }
}
