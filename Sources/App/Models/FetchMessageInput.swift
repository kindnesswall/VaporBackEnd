//
//  FetchMessageInput.swift
//  App
//
//  Created by Amir Hossein on 1/29/19.
//

import Foundation

class FetchMessageInput: Codable {
    var beforeId:Int?
    
    init(beforeId:Int?) {
        self.beforeId=beforeId
    }
}
