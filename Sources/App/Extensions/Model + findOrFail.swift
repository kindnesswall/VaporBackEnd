//
//  Model + findOrFail.swift
//  
//
//  Created by Amir Hossein on 6/12/21.
//

import Vapor
import Fluent

extension Model where IDValue == Int {
    static func findOrFail(_ id: Int?, on db: Database) -> EventLoopFuture<Self> {
        return find(id, on: db)
            .unwrap(or: Abort(.notFound))
    }
    
    static func findOrFail(_ id: Int?, withSoftDeleted: Bool, on db: Database) -> EventLoopFuture<Self> {
        return find(id, withSoftDeleted: withSoftDeleted, on: db)
            .unwrap(or: Abort(.notFound))
    }
    
    static func find(_ id: Int?, withSoftDeleted: Bool, on db: Database) -> EventLoopFuture<Self?> {
        
        guard let id = id else {
            return db.makeSucceededFuture(nil)
        }
        
        let qb = query(on: db)
        if withSoftDeleted { qb.withDeleted() }
        return qb
            .filter(\._$id == id)
            .first()
    }
}
