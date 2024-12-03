import Foundation

struct Budget: Codable {
    let date: Date
    var amount: Double
    var spent: Double
    var carryOver: Double // 전날에서 이월된 금액
    
    var remaining: Double {
        return amount + carryOver - spent
    }
    
    var nextDayCarryOver: Double {
        return remaining // 남은 금액이 다음 날로 이월됨
    }
    
    init(date: Date, amount: Double, spent: Double = 0, carryOver: Double = 0) {
        self.date = date
        self.amount = amount
        self.spent = spent
        self.carryOver = carryOver
    }
}
