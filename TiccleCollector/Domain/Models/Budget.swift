import Foundation

struct Budget {
    let date: Date
    var amount: Double
    var spent: Double
    
    var remaining: Double {
        return amount - spent
    }
    
    init(date: Date, amount: Double, spent: Double = 0) {
        self.date = date
        self.amount = amount
        self.spent = spent
    }
}
