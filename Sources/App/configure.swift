
import Vapor
import Fluent
import FluentPostgresDriver
import Leaf
import FCM
import APNS
import Gatekeeper

/// Called before your application initializes.
public func configure(_ app: Application) throws {
    
    /// Register providers first
    app.views.use(.leaf)
    
    let portOffset = configuration.replicaId - 1
    let port = configuration.main.hostPort + portOffset
    
    app.http.server.configuration.hostname = configuration.main.hostName
    app.http.server.configuration.port = port
    
    try routes(app)

    /// Register middleware
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(corsMiddleware)
    
    let file = FileMiddleware(publicDirectory: app.directory.publicDirectory)
    app.middleware.use(file)
    
    let error = ErrorMiddleware.default(environment: app.environment)
    app.middleware.use(error)

    // Configure a PostgreSQL database
    app.databases.use(.postgres(
        hostname: configuration.main.dataBaseHost,
        port: configuration.main.dataBasePort,
        username: configuration.main.dataBaseUser,
        password: configuration.main.dataBasePassword ?? "",
        database: configuration.main.dataBaseName
        ), as: .psql)
    
    /// Configure migrations
//    var migrations = MigrationConfig()
    
    //models
//    migrations.add(model: Gift.self, database: DatabaseIdentifier<Gift.Database>.psql)
//    migrations.add(model: Category.self, database: DatabaseIdentifier<Category.Database>.psql)
//    migrations.add(model: User.self, database: DatabaseIdentifier<User.Database>.psql)
//    migrations.add(model: UserPhoneNumberLog.self, database: DatabaseIdentifier<UserPhoneNumberLog.Database>.psql)
//    migrations.add(model: PhoneNumberActivationCode.self, database: DatabaseIdentifier<PhoneNumberActivationCode.Database>.psql)
//    migrations.add(model: Token.self, database: DatabaseIdentifier<Token.Database>.psql)
//    migrations.add(model: TextMessage.self, database: DatabaseIdentifier<TextMessage.Database>.psql)
//    migrations.add(model: Country.self, database: DatabaseIdentifier<Country.Database>.psql)
//    migrations.add(model: Province.self, database: DatabaseIdentifier<Province.Database>.psql)
//    migrations.add(model: County.self, database: DatabaseIdentifier<County.Database>.psql)
//    migrations.add(model: City.self, database: DatabaseIdentifier<City.Database>.psql)
//    migrations.add(model: Region.self, database: DatabaseIdentifier<Region.Database>.psql)
//    migrations.add(model: DirectChat.self, database: DatabaseIdentifier<DirectChat.Database>.psql)
//    migrations.add(model: ChatBlock.self, database: DatabaseIdentifier<ChatBlock.Database>.psql)
//    migrations.add(model: GiftRequest.self, database: DatabaseIdentifier<GiftRequest.Database>.psql)
//    migrations.add(model: UserPushNotification.self, database: DatabaseIdentifier<UserPushNotification.Database>.psql)
//    migrations.add(model: Charity.self, database: DatabaseIdentifier<Charity.Database>.psql)
//    migrations.add(model: ApplicationVersion.self, database: DatabaseIdentifier<ApplicationVersion.Database>.psql)
//    migrations.add(model: Sponsor.self, database: DatabaseIdentifier<Sponsor.Database>.psql)
//    migrations.add(model: Rating.self, database: DatabaseIdentifier<Rating.Database>.psql)
//    migrations.add(model: RatingResult.self, database: DatabaseIdentifier<RatingResult.Database>.psql)
//    migrations.add(model: PhoneNumberSeenLog.self, database: DatabaseIdentifier<PhoneNumberSeenLog.Database>.psql)
    
    //models extension
//    migrations.add(migration: AddPhoneVisibilityToUser.self, database: .psql)
    
    
    //seeds
//    migrations.add(migration: CategorySeed.self, database: .psql)
//    migrations.add(migration: ApplicationVersionSeed.self, database: .psql)
    
//    services.register(migrations)
    
    //TODO: APNS Configuration
//    if
//        let configuration = configuration.apns,
//        let environment = configuration.getEnvironment()
//    {
//        app.apns.configuration = try .init(
//            authenticationMethod: <#T##APNSwiftConfiguration.AuthenticationMethod#>,
//            topic: configuration.bundleId,
//            environment:  environment)
//    }
    
    app.migrations.add(UserUniquePhoneNumberMigration())
//    app.migrations.add(DirectChatUniqueUserIdAndContactIdMigration())
    app.migrations.add(RatingResultUniqueReviewedIdMigration())
    app.migrations.add(ReportGiftMigration())
    app.migrations.add(ReportCharityMigration())
    app.migrations.add(ReportUserMigration())
    app.migrations.add(GiftRequestUniqueFieldsMigration())
    app.migrations.add(GiftRequestStatusMigration())
    app.migrations.add(GiftRequestStatusEnumMigration())
    app.migrations.add(GiftRequestDateMigration())
    app.migrations.add(GiftIsDeliveredMigration())
    app.migrations.add(CharityLicenseIdAndMoreFieldsMigration())
    app.migrations.add(CharityDeletingRegisterIdAndMoreFieldsMigration())
    app.migrations.add(PhoneNumberActivationCodeUniquePhoneNumberMigration())
    
    //Firebase
    let path = CertificatesPath.path(of: .firebase)
    app.fcm.configuration = .init(pathToServiceAccountKey: path)
    
    app.gatekeeper.config = .init(maxRequests: 3, per: .minute)
}
