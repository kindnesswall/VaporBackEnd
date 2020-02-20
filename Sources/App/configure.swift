
import FluentPostgreSQL
import Vapor
import Authentication
import FCM

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())
    
    services.register(Shell.self)
    
    let serverConfigure = NIOServerConfig.default(hostname: Constants.appInfo.hostName, port: Constants.appInfo.hostPort,maxBodySize:20_000_000)
    services.register(serverConfigure)
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a PostgreSQL database

    let postgreSQLConfig = PostgreSQLDatabaseConfig(hostname: Constants.appInfo.dataBaseHost, port: Constants.appInfo.dataBasePort, username: Constants.appInfo.dataBaseUser, database: Constants.appInfo.dataBaseName,password: Constants.appInfo.dataBasePassword)
    
    let postgreSQL = PostgreSQLDatabase(config: postgreSQLConfig)
    
    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: postgreSQL, as: .psql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    
    //models
    migrations.add(model: Gift.self, database: .psql)
    migrations.add(model: Category.self, database: .psql)
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: UserPhoneNumberLog.self, database: .psql) 
    migrations.add(model: Token.self, database: .psql)
    migrations.add(model: TextMessage.self, database: .psql)
    migrations.add(model: Country.self, database: .psql)
    migrations.add(model: Province.self, database: .psql)
    migrations.add(model: County.self, database: .psql)
    migrations.add(model: City.self, database: .psql)
    migrations.add(model: Region.self, database: .psql)
    migrations.add(model: Chat.self, database: .psql)
    migrations.add(model: ChatNotification.self, database: .psql)
    migrations.add(model: ChatBlock.self, database: .psql)
    migrations.add(model: GiftRequest.self, database: .psql)
    migrations.add(model: UserPushNotification.self, database: .psql)
    migrations.add(model: Charity.self, database: .psql)
    
    //models extension
    migrations.add(migration: AddUserCharityName.self, database: .psql)
    migrations.add(migration: AddCategoryFarsiTitle.self, database: .psql)
    
    //seeds
    migrations.add(migration: CategorySeed.self, database: .psql)
    
    services.register(migrations)
    
    // Create a new NIO websocket server
    let wss = NIOWebSocketServer.default()
    sockets(wss: wss)
    // Register our server
    services.register(wss, as: WebSocketServer.self)
    
    //Firebase
    let appInfo = AppInfo()
    let path = "\(appInfo.rootPath)\(appInfo.firebaseConfig.keyPath)"
    let fcm = FCM(pathToServiceAccountKey: path)
    fcm.androidDefaultConfig = FCMAndroidConfig(ttl: "86400s", restricted_package_name: AppInfo().firebaseConfig.restricted_package_name, notification: FCMAndroidNotification(sound: "default"))
    services.register(fcm, as: FCM.self)
}
