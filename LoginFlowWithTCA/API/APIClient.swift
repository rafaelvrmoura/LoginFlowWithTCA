//
//  APIClient.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 01/11/25.
//

import Foundation

private let baseURL = URL(string: "http://127.0.0.1:8080")!

protocol APIClientDelegate {
    
    func optionalHeaders(for endpoint: APIProtocol) -> [HTTPHeaderField: String]?
}

protocol APIClient {
    
    associatedtype API: APIProtocol
    
    var delegate: APIClientDelegate? { get }

    @discardableResult
    func request(_ endpoint: API) async throws -> Data
    func requestDecodable<Resource: Decodable>(_ endpoint: API) async throws -> Resource
}

enum APIClientError: Error {
    
    case failed(statusCode: Int)
}

extension APIClient {
    
    @discardableResult
    func request(_ endpoint: API) async throws -> Data {
        
        let requestBuilder = URLRequestBuilder(url: baseURL)
            .appendPath(endpoint.path)
            .setHTTPMethod(endpoint.httpMethod)
        
        if let queryItems = endpoint.queryItems {
            requestBuilder.addQueryItems(queryItems)
        }
        
        if let headers = endpoint.headers {
            requestBuilder.setHeaders(headers)
        }
        
        if let optionalHeaders = self.delegate?.optionalHeaders(for: endpoint) {
            requestBuilder.setHeaders(optionalHeaders)
        }
        
        if let body = endpoint.body {
            
            requestBuilder.setHTTPBody(body)
        }
        
        let request = requestBuilder.build()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let httpResponse = response as! HTTPURLResponse
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw APIClientError.failed(statusCode: httpResponse.statusCode)
        }
        
        return data
    }
    
    func requestDecodable<Resource: Decodable>(_ endpoint: API) async throws -> Resource {
        
        let data = try await request(endpoint)
        
        return try JSONDecoder().decode(Resource.self, from: data)
    }
}
