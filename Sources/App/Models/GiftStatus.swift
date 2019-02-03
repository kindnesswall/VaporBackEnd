//
//  GiftStatus.swift
//  App
//
//  Created by Amir Hossein on 2/3/19.
//

import Vapor
import FluentPostgreSQL

enum GiftStatus : Int,Content {
    
    case secondhand = 0
    case new = 1
    
}
