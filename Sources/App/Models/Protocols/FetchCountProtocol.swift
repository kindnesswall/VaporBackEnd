//
//  FetchCountProtocol.swift
//  
//
//  Created by AmirHossein on 3/14/23.
//

import Foundation

protocol FetchCountProtocol {
    var count: Int? { get }
    func getCount() -> Int
}

extension FetchCountProtocol {
    func getCount() -> Int {
        return Constants.maxFetchCount(bound: count)
    }
}
