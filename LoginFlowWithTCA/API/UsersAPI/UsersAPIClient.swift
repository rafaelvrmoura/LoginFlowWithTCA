//
//  UsersAPIClient.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 16/10/25.
//

import ComposableArchitecture
import Foundation

protocol UsersAPIProtocol: APIClient {
    
    func create(user: UserModel) async throws -> UserModel
    func me() async throws -> UserModel
    func update(user: UserModel) async throws -> UserModel
    func delete(userWithId id: String) async throws
    func uploadProfilePicture(data: Data, forUserWithId id: String) async throws -> URL
}

extension UsersAPIProtocol {
    
    func create(user: UserModel) async throws -> UserModel { fatalError("Missing implementation") }
    func me() async throws -> UserModel { fatalError("Missing implementation") }
    func update(user: UserModel) async throws -> UserModel { fatalError("Missing implementation") }
    func delete(userWithId id: String) async throws { fatalError("Missing implementation") }
    func uploadProfilePicture(data: Data, forUserWithId id: String) async throws -> URL { fatalError("Missing implementation") }
}

struct UsersAPIClient: UsersAPIProtocol {
    
    typealias API = UsersAPI
    
    var delegate: (any APIClientDelegate)?
    
    func create(user: UserModel) async throws -> UserModel {
        
        return try await self.requestDecodable(.create(user: user))
    }
    
    func me() async throws -> UserModel {
        
        return try await self.requestDecodable(.me)
    }
    
    func update(user: UserModel) async throws -> UserModel {
        
        return try await self.requestDecodable(.update(user: user))
    }
    
    func delete(userWithId id: String) async throws {
        
        try await self.request(.delete(userId: id))
    }
    
    func uploadProfilePicture(data: Data, forUserWithId id: String) async throws -> URL {
        
        return try await self.requestDecodable(.uploadProfilePicture(data, userId: id))
    }
}

extension UsersAPIClient: DependencyKey {
    
    static var liveValue: any UsersAPIProtocol = UsersAPIClient()
}

extension DependencyValues {
    
    var usersAPI: any UsersAPIProtocol {
        get { self[UsersAPIClient.self] }
        set { self[UsersAPIClient.self] = newValue }
    }
}
