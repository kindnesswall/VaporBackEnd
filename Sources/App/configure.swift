
import FluentPostgreSQL
import Vapor
import Leaf
import Authentication
import FCM

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())
    
    services.register(Shell.self)
    
    let portOffset = configuration.replicaId - 1
    let port = configuration.main.hostPort + portOffset
    let serverConfigure = NIOServerConfig.default(hostname: configuration.main.hostName, port: port, maxBodySize: 20_000_000)
    services.register(serverConfigure)
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    middlewares.use(corsMiddleware)
    
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a PostgreSQL database

    let postgreSQLConfig = PostgreSQLDatabaseConfig(
        hostname: configuration.main.dataBaseHost,
        port: configuration.main.dataBasePort,
        username: configuration.main.dataBaseUser,
        database: configuration.main.dataBaseName,
        password: configuration.main.dataBasePassword)
    
    let postgreSQL = PostgreSQLDatabase(config: postgreSQLConfig)
    
    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: postgreSQL, as: .psql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    
    //models
    migrations.add(model: Gift.self, database: DatabaseIdentifier<Gift.Database>.psql)
    migrations.add(model: Category.self, database: DatabaseIdentifier<Category.Database>.psql)
    migrations.add(model: User.self, database: DatabaseIdentifier<User.Database>.psql)
    migrations.add(model: UserPhoneNumberLog.self, database: DatabaseIdentifier<UserPhoneNumberLog.Database>.psql)
    migrations.add(model: PhoneNumberActivationCode.self, database: DatabaseIdentifier<PhoneNumberActivationCode.Database>.psql)
    migrations.add(model: Token.self, database: DatabaseIdentifier<Token.Database>.psql)
    migrations.add(model: TextMessage.self, database: DatabaseIdentifier<TextMessage.Database>.psql)
    migrations.add(model: Country.self, database: DatabaseIdentifier<Country.Database>.psql)
    migrations.add(model: Province.self, database: DatabaseIdentifier<Province.Database>.psql)
    migrations.add(model: County.self, database: DatabaseIdentifier<County.Database>.psql)
    migrations.add(model: City.self, database: DatabaseIdentifier<City.Database>.psql)
    migrations.add(model: Region.self, database: DatabaseIdentifier<Region.Database>.psql)
    migrations.add(model: DirectChat.self, database: DatabaseIdentifier<DirectChat.Database>.psql)
    migrations.add(model: ChatBlock.self, database: DatabaseIdentifier<ChatBlock.Database>.psql)
    migrations.add(model: GiftRequest.self, database: DatabaseIdentifier<GiftRequest.Database>.psql)
    migrations.add(model: UserPushNotification.self, database: DatabaseIdentifier<UserPushNotification.Database>.psql)
    migrations.add(model: Charity.self, database: DatabaseIdentifier<Charity.Database>.psql)
    migrations.add(model: ApplicationVersion.self, database: DatabaseIdentifier<ApplicationVersion.Database>.psql)
    migrations.add(model: Sponsor.self, database: DatabaseIdentifier<Sponsor.Database>.psql)
    migrations.add(model: Rating.self, database: DatabaseIdentifier<Rating.Database>.psql)
    migrations.add(model: RatingResult.self, database: DatabaseIdentifier<RatingResult.Database>.psql)
    
    //models extension
    //
    
    
    //seeds
    migrations.add(migration: CategorySeed.self, database: .psql)
    migrations.add(migration: ApplicationVersionSeed.self, database: .psql)
    
    services.register(migrations)
    
    
    //Firebase
    let path = CertificatesPath.path(of: .firebase)
    let fcm = FCM(pathToServiceAccountKey: path)
    services.register(fcm, as: FCM.self)
}
