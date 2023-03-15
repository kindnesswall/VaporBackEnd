//
//  RequestInput.swift
//  App
//
//  Created by Amir Hossein on 1/29/19.
//

import Vapor

class RequestInput: Codable, FetchCountProtocol {
    let beforeId: Int?
    let page: Int?
    let count: Int?
    let categoryIds: [Int]?
    let countryId: Int?
    let provinceId: Int?
    let cityId: Int?
    let regionIds: [Int]?
    let searchWord: String?
    let isDonated: Bool?
    let isDelivered: Bool?
}

class PaginationRequestInput: Codable, FetchCountProtocol {
    let page: Int?
    let count: Int?
}
