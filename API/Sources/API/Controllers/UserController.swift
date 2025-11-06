//
//  UserController.swift
//  API
//
//  Created by Rafael Vieira Moura on 27/10/25.
//

import Fluent
import Vapor

struct UserController: RouteCollection {
    
    func boot(routes: any RoutesBuilder) throws {
        
        let users = routes.grouped("v1", "users")
        
        users.post(use: create)
        
        users.group(":userId") {
            $0.get(use: getById)
            $0.patch(use: update)
            $0.delete(use: delete)
        }
        
        users.group("me") {
            $0.get(use: me)
        }
        
        users.group(":userId", "profile-picture") {
            $0.on(
                .POST,
                body: .collect(maxSize: "50mb"),
                use: uploadPicture
            )
        }
    }
    
    func me(req: Request) async throws -> UserDTO {
        
        let (_, authPayload) = try await req.authenticate()
        
        guard let user = try await User.find(
            authPayload.userId,
            on: req.db
        ) else {
            throw Abort(.notFound)
        }
        
        return user.toDTO()
    }
    
    func getById(req: Request) async throws -> UserDTO {
        
        try await req.authenticate()
        
        guard let user = try await User.find(
            req.parameters.get("userId"),
            on: req.db
        ) else {
            throw Abort(.notFound)
        }
        
        return user.toDTO()
    }
    
    func create(req: Request) async throws -> UserDTO {
        let user = try req.content.decode(UserDTO.self).toModel()

        try await user.save(on: req.db)
        return user.toDTO()
    }
    
    func update(req: Request) async throws -> UserDTO {
        
        try await req.authenticate()
        
        let userDTO = try req.content.decode(UserDTO.self)
        
        guard let user = try await User.find(req.parameters.get("userId"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        if let newName = userDTO.name {
            user.name = newName
        }
        
        if let newEmail = userDTO.email {
            user.email = newEmail
        }
        
        if let newPassword = userDTO.password {
            user.password = newPassword
        }
        
        try await user.update(on: req.db)
        return user.toDTO()
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        
        let _ = try await req.jwt.verify(as: AuthPayload.self)
        
        guard let user = try await User.find(req.parameters.get("userId"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await user.delete(on: req.db)
        return .noContent
    }
    
    func uploadPicture(req: Request) async throws -> String {

        try await req.authenticate()
        
        guard let user = try await User.find(req.parameters.get("userId"),on: req.db) else {
            
            throw Abort(.notFound)
        }
        
        let image = try req.content.decode(UploadData.self).image
        
        // Access fileUpload.name and fileUpload.image (which contains the file data)
        let filename = [UUID().uuidString, image.filename].compactMap{$0} .joined(separator: "-")
        let imageData = image.data

        let path = req.application.uploadsDirectory + filename
        try await req.fileio.writeFile(imageData, at: path)
        
        let url = req.application.uploadsURL + filename
        
        user.profilePictureURL = url
        
        try await user.update(on: req.db)
        
        return url
    }
}
