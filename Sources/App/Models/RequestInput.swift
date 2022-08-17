//
//  RequestInput.swift
//  App
//
//  Created by Amir Hossein on 1/29/19.
//

import Vapor

class RequestInput: Codable {
    var beforeId:Int?
    var count:Int?
    var categoryIds:[Int]?
    var countryId: Int?
    var provinceId:Int?
    var cityId:Int?
    var regionIds:[Int]? 
    var searchWord:String?
    var isDonated: Bool?
    var isDelivered: Bool?
}
