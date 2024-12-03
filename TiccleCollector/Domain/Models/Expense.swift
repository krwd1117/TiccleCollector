import Foundation

struct Expense: Codable, Identifiable {
    let id: UUID
    let amount: Decimal
    let date: Date
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        amount: Decimal,
        date: Date = Date(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.date = date
        self.createdAt = createdAt
    }
}

extension Expense {
    var dateComponents: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: date)
    }
    
    func isSameDay(as date: Date) -> Bool {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return dateComponents.year == components.year &&
               dateComponents.month == components.month &&
               dateComponents.day == components.day
    }
}
