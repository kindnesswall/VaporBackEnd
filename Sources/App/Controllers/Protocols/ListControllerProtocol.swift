//
//  ListControllerProtocol.swift
//  
//
//  Created by AmirHossein on 3/10/23.
//

import Vapor
import Fluent

protocol ListControllerProtocol {
    associatedtype T: ResponseEncodable
    associatedtype PT: ResponseEncodable
    func index(_ req: Request) throws -> EventLoopFuture<T>
    func paginatedIndex(_ req: Request) throws -> EventLoopFuture<Page<PT>>
}
