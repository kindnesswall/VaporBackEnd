//
//  UserPhoneNumberLog.swift
//  App
//
//  Created by Amir Hossein on 9/20/19.
//

import Vapor
import Fluent
import FluentPostgresDriver

final class UserPhoneNumberLog: PostgreSQLModel {
    var id:Int?
    var userId:Int
    var fromPhoneNumber:String
    var toPhoneNumber:String
    var status:String
    var activationCode_from:String?
    var activationCode_to:String?
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    
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
    
    func complete(on conn: DatabaseConnectable) -> EventLoopFuture<HTTPStatus> {
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
    
    func set(activationCode: ActivationCode, on conn: DatabaseConnectable) -> EventLoopFuture<HTTPStatus> {
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
            return item.set(activationCode: activationCode, on: req)
        }
    }
    
    static func findOrCreate(req: Request, auth: User, toPhoneNumber: String) throws -> EventLoopFuture<UserPhoneNumberLog> {
        
        let requested = UserPhoneNumberLog(userId: try auth.getId(), fromPhoneNumber: auth.phoneNumber, toPhoneNumber: toPhoneNumber, status: .requested)
        
        return getLatest(phoneNumberLog: requested, conn: req).map { found in
            let phoneNumberLog = found ?? requested
            return phoneNumberLog
        }
        
    }
    
    static func check(req: Request, auth: User, toPhoneNumber: String, activationCode: ActivationCode) throws ->  EventLoopFuture<UserPhoneNumberLog> {
        
        let requested = UserPhoneNumberLog(userId: try auth.getId(), fromPhoneNumber: auth.phoneNumber, toPhoneNumber: toPhoneNumber, status: .requested)
        
        return getLatest(phoneNumberLog: requested, conn: req).map { item in
            
            guard let item = item else {
                throw Abort(.invalidPhoneNumber)
            }
            
            guard item.check(activationCode: activationCode) else {
                throw Abort(.invalidActivationCode)
            }
            
            return item
        }
        
    }
    
    
    static func getLatest(phoneNumberLog: UserPhoneNumberLog, conn:DatabaseConnectable) -> EventLoopFuture<UserPhoneNumberLog?> {
        return query(on: conn)
            .filter(\.userId == phoneNumberLog.userId)
            .filter(\.fromPhoneNumber == phoneNumberLog.fromPhoneNumber)
            .filter(\.toPhoneNumber == phoneNumberLog.toPhoneNumber)
            .filter(\.status == phoneNumberLog.status)
        .sort(\.createdAt, .descending).first()
    }
}

extension UserPhoneNumberLog {
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    static let deletedAtKey: TimestampKey? = \.deletedAt
}

extension UserPhoneNumberLog : Migration {}

extension UserPhoneNumberLog : Content {}

extension UserPhoneNumberLog : Parameter {}
