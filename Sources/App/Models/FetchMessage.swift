//
//  FetchMessage.swift
//  App
//
//  Created by Amir Hossein on 1/29/19.
//

import Foundation

class FetchMessage: Codable {
    var afterId:Int?
    
    init(afterId:Int?) {
        self.afterId=afterId
    }
}
