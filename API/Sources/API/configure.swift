import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    await app.jwt.keys.add(hmac: "RsFOPL3jKqgFxxnpmvW7RrDFDm4RPaLOhssaQycKCM8=", digestAlgorithm: .sha256)
    
    let uploadsDirectory = app.uploadsDirectory

    // Create the directory if it doesn't already exist
    do {
        try FileManager.default.createDirectory(
            atPath: uploadsDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
        app.logger.info("Created uploads directory at: \(uploadsDirectory)")
        
    } catch {
        
        app.logger.error("Failed to create uploads directory: \(error)")
    }
    
    app.databases.use(.sqlite(.memory), as: .sqlite)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateSession())

    try await app.autoMigrate()
    
    // register routes
    try routes(app)
}
