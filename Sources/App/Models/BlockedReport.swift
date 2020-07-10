//
//  BlockedReport.swift
//  App
//
//  Created by Amir Hossein on 7/9/20.
//

import Vapor

struct BlockedReport: Content {
    var count = 0
    var byUsers = [Int]()
    
    mutating func add(_ chatBlock: ChatBlock) {
        count += 1
        byUsers.append(chatBlock.byUserId)
    }
}

struct User_BlockedReport: Content {
    let user: User
    var blocked = BlockedReport()
    
    init(user: User) {
        self.user = user
    }
}


extension Array where Element == (User,ChatBlock) {
    func getStandard() -> [User_BlockedReport] {
        var list = [User_BlockedReport]()
        for item in self {
            list.add(user: item.0, chatBlock: item.1)
        }
        return list
    }
}

extension Array where Element == User_BlockedReport {
    mutating func add(user: User, chatBlock: ChatBlock) {
        guard let userId = user.id else { return }
        
        //TODO: Performance measurement is necessary
        let index = firstIndex { $0.user.id == userId }
        if let index = index {
            self[index].blocked.add(chatBlock)
        } else {
            var element = User_BlockedReport(user: user)
            element.blocked.add(chatBlock)
            append(element)
        }
    }
}
