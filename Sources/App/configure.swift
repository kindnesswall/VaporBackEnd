
import FluentPostgreSQL
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())
    
    let serverConfigure = NIOServerConfig.default(hostname: Constants.appInfo.dataBaseHost, port: 8080)
    services.register(serverConfigure)
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a PostgreSQL database

    let postgreSQLConfig = PostgreSQLDatabaseConfig(hostname: Constants.appInfo.dataBaseHost, port: Constants.appInfo.dataBasePort, username: Constants.appInfo.dataBaseUser, database: Constants.appInfo.dataBaseName)
    let postgreSQL = PostgreSQLDatabase(config: postgreSQLConfig)
    
    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: postgreSQL, as: .psql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Gift.self, database: .psql)
    migrations.add(model: Category.self, database: .psql)
    migrations.add(model: User.self, database: .psql)
    migrations.add(migration: CategorySeed.self, database: .psql)
    services.register(migrations)

}
