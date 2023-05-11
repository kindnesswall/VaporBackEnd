
import Vapor

final class CharityStatus: Content {
    let charity: Charity?
    let isCharity: Bool
    
    init(charity: Charity? = nil, isCharity: Bool) {
        self.charity = charity
        self.isCharity = isCharity
    }
}

final class CharityDetailedStatus: Content {
    
    let charity: Charity?
    let status: DetailedStatus
    
    enum DetailedStatus: String, Content {
        case notRequested
        case pending
        case rejected
        case isCharity
    }
    
    init(charity: Charity?, status: DetailedStatus) {
        self.charity = charity
        self.status = status
    }
    
    convenience init(user: User, charity: Charity?) {
        let status: DetailedStatus
        if let charity = charity {
            if user.isCharity {
                status = .isCharity
            } else {
                if charity.isRejected == true {
                    status = .rejected
                } else {
                    status = .pending
                }
            }
        } else {
            status = .notRequested
        }
        self.init(charity: charity, status: status)
    }
    
}
