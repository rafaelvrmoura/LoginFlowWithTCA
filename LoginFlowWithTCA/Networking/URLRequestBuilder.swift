//
//  URLRequestBuilder.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 30/10/25.
//

import Foundation

enum HTTPHeaderField: String {
    case Authorization
    case ContentType = "Content-Type"
}

class URLRequestBuilder {

    private var request: URLRequest
    
    init(url: URL) {
        
        self.request = URLRequest(url: url)
    }
    
    func build() -> URLRequest {
        
        return request
    }
    
    @discardableResult
    func appendPath(_ path: String) -> Self {

        request.url = request.url?.appendingPathComponent(path)
        return self
    }
    
    @discardableResult
    func addQueryItems(_ items: [URLQueryItem]) -> Self {
        
        request.url = request.url?.appending(queryItems: items)
        return self
    }
    
    @discardableResult
    func setHeaderValue(_ value: String, field: HTTPHeaderField) -> Self {
        
        request.setValue(value, forHTTPHeaderField: field.rawValue)
        return self
    }
    
    @discardableResult
    func setHeaders(_ headers: [HTTPHeaderField: String]) -> Self {
        
        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field.rawValue)
        }
        
        return self
    }
    
    @discardableResult
    func setHTTPMethod(_ method: HTTPMethod) -> Self {
        
        request.httpMethod = method.rawValue
        return self
    }
    
    @discardableResult
    func setHTTPBody(_ data: Data) -> Self {
        
        request.httpBody = data
        return self
    }
    
    @discardableResult
    func setTimeout(_ timeout: TimeInterval) -> Self {
        
        request.timeoutInterval = timeout
        return self
    }
    
    @discardableResult
    func setCachePolicy(_ policy: URLRequest.CachePolicy) -> Self {
        
        request.cachePolicy = policy
        return self
    }
}
