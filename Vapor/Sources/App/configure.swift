import FluentSQLite
import Vapor

public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
    ) throws {
    /// Register providers first
    try services.register(FluentSQLiteProvider())
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    var serverConfig = NIOServerConfig.default()
    serverConfig.hostname = "192.168.1.66"
    services.register(serverConfig)
    
    var databaseConfig = DatabasesConfig()
    let db = try SQLiteDatabase(storage: .file(path: "tokens.db"))
    databaseConfig.add(database: db, as: .sqlite)
    services.register(databaseConfig)

    var migrations = MigrationConfig()
    migrations.add(model: Token.self, database: .sqlite)
    services.register(migrations)
}
