//
//  UserPhoneNumberLog.swift
//  App
//
//  Created by Amir Hossein on 9/20/19.
//

import Vapor
import Fluent

final class UserPhoneNumberLog: Model {
    
    static let schema = "UserPhoneNumberLog"
    
    @ID(key: .id)
    var id:Int?
    
    @Field(key: "userId")
    var userId:Int
    
    @Field(key: "fromPhoneNumber")
    var fromPhoneNumber:String
    
    @Field(key: "toPhoneNumber")
    var toPhoneNumber:String
    
    @Field(key: "status")
    var status:String
    
    @OptionalField(key: "activationCode_from")
    var activationCode_from:String?
    
    @OptionalField(key: "activationCode_to")
    var activationCode_to:String?
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deletedAt", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    init(userId: Int, fromPhoneNumber: String, toPhoneNumber: String, status: ChangeStatus) {
        
        self.userId = userId
        self.fromPhoneNumber = fromPhoneNumber
        self.toPhoneNumber = toPhoneNumber
        self.status = status.rawValue
        
    }
    
    func setStatus(status: ChangeStatus) {
        self.status = status.rawValue
    }
    
    enum ChangeStatus: String {
        case requested
        case completed
    }
    
    func complete(on conn: Database) -> EventLoopFuture<HTTPStatus> {
        activationCode_from = nil
        activationCode_to = nil
        setStatus(status: .completed)
        return save(on: conn).transform(to: .ok)
    }
    
    func check(activationCode: ActivationCode) -> Bool {
        guard activationCode_from == activationCode.from,
            activationCode_to == activationCode.to
        else {
            return false
        }
        return true
    }
    
    func set(activationCode: ActivationCode, on conn: Database) -> EventLoopFuture<HTTPStatus> {
        activationCode_from = activationCode.from
        activationCode_to = activationCode.to
        return save(on: conn).transform(to: .ok)
    }
    
    struct ActivationCode {
        var from: String
        var to: String
        
        init(from: String, to: String) {
            self.from = from
            self.to = to
        }
        
        init?(from: String?, to: String?) {
            guard let from = from else { return nil }
            guard let to = to else { return nil }
            self.init(from: from, to: to)
        }
        
        static func generate() -> ActivationCode {
            let from = User.generateActivationCode()
            let to = User.generateActivationCode()
            return ActivationCode(from: from, to: to)
        }
    }
}

extension UserPhoneNumberLog {
    
    static func setActivationCode(req: Request, auth: User, toPhoneNumber: String, activationCode: ActivationCode) throws -> EventLoopFuture<HTTPStatus> {
        
        let futureItem = try findOrCreate(req: req, auth: auth, toPhoneNumber: toPhoneNumber)
        
        return futureItem.flatMap { item in
            return item.set(activationCode: activationCode, on: req.db)
        }
    }
    
    static func findOrCreate(req: Request, auth: User, toPhoneNumber: String) throws -> EventLoopFuture<UserPhoneNumberLog> {
        
        let requested = UserPhoneNumberLog(userId: try auth.getId(), fromPhoneNumber: auth.phoneNumber, toPhoneNumber: toPhoneNumber, status: .requested)
        
        return getLatest(phoneNumberLog: requested, conn: req.db).map { found in
            let phoneNumberLog = found ?? requested
            return phoneNumberLog
        }
        
    }
    
    static func check(req: Request, auth: User, toPhoneNumber: String, activationCode: ActivationCode) throws ->  EventLoopFuture<UserPhoneNumberLog> {
        
        let requested = UserPhoneNumberLog(userId: try auth.getId(), fromPhoneNumber: auth.phoneNumber, toPhoneNumber: toPhoneNumber, status: .requested)
        
        return getLatest(phoneNumberLog: requested, conn: req.db).map { item in
            
            guard let item = item else {
                throw Abort(.invalidPhoneNumber)
            }
            
            guard item.check(activationCode: activationCode) else {
                throw Abort(.invalidActivationCode)
            }
            
            return item
        }
        
    }
    
    
    static func getLatest(phoneNumberLog: UserPhoneNumberLog, conn:Database) -> EventLoopFuture<UserPhoneNumberLog?> {
        return query(on: conn)
            .filter(\.$userId == phoneNumberLog.userId)
            .filter(\.$fromPhoneNumber == phoneNumberLog.fromPhoneNumber)
            .filter(\.$toPhoneNumber == phoneNumberLog.toPhoneNumber)
            .filter(\.$status == phoneNumberLog.status)
        .sort(\.$createdAt, .descending).first()
    }
}

//extension UserPhoneNumberLog : Migration {}

extension UserPhoneNumberLog : Content {}


