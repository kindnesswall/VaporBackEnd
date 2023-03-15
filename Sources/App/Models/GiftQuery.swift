//
//  GiftQuery.swift
//  
//
//  Created by AmirHossein on 3/14/23.
//

import Vapor
import Fluent

class GiftQuery {
    let query: QueryBuilder<Gift>
    let requestInput: RequestInput
    let onlyReviewerAcceptedGifts: Bool
    
    init(query: QueryBuilder<Gift>,
         requestInput: RequestInput,
         onlyReviewerAcceptedGifts: Bool
    ){
        self.query = query
        self.requestInput = requestInput
        self.onlyReviewerAcceptedGifts = onlyReviewerAcceptedGifts
    }
}
