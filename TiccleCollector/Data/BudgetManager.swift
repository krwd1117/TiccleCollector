import Foundation
import Combine

class BudgetManager {
    static let shared = BudgetManager()
    
    private let budgetSubject = CurrentValueSubject<[String: Budget], Never>([:])
    var budgetPublisher: AnyPublisher<[String: Budget], Never> {
        budgetSubject.eraseToAnyPublisher()
    }
    
    private let defaults = UserDefaults.standard
    private let budgetKey = "budgets"
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private init() {
        loadFromDefaults()
    }
    
    // MARK: - Public Methods
    func setBudget(amount: Double, for date: Date) {
        let dateString = dateFormatter.string(from: date)
        var budgets = budgetSubject.value
        
        if let existingBudget = budgets[dateString] {
            let updatedBudget = Budget(
                date: date,
                amount: amount,
                spent: existingBudget.spent,
                carryOver: existingBudget.carryOver
            )
            budgets[dateString] = updatedBudget
        } else {
            let newBudget = Budget(
                date: date,
                amount: amount,
                spent: 0,
                carryOver: calculateCarryOver(for: date)
            )
            budgets[dateString] = newBudget
        }
        
        budgetSubject.send(budgets)
        saveToDefaults()
    }
    
    func addSpent(amount: Double, for date: Date) {
        let dateString = dateFormatter.string(from: date)
        var budgets = budgetSubject.value
        
        if let existingBudget = budgets[dateString] {
            let updatedBudget = Budget(
                date: date,
                amount: existingBudget.amount,
                spent: existingBudget.spent + amount,
                carryOver: existingBudget.carryOver
            )
            budgets[dateString] = updatedBudget
            
            // 다음 날의 이월금액 업데이트
            if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date) {
                updateCarryOver(for: nextDate)
            }
        }
        
        budgetSubject.send(budgets)
        saveToDefaults()
    }
    
    func budget(for date: Date) -> Budget? {
        let dateString = dateFormatter.string(from: date)
        return budgetSubject.value[dateString]
    }
    
    func loadBudgets() -> [(date: Date, budget: Budget)] {
        return budgetSubject.value.compactMap { (dateString, budget) in
            guard let date = dateFormatter.date(from: dateString) else { return nil }
            return (date: date, budget: budget)
        }
    }
    
    // MARK: - Private Methods
    private func loadFromDefaults() {
        if let data = defaults.data(forKey: budgetKey),
           let budgets = try? JSONDecoder().decode([String: Budget].self, from: data) {
            budgetSubject.send(budgets)
        }
    }
    
    private func saveToDefaults() {
        if let data = try? JSONEncoder().encode(budgetSubject.value) {
            defaults.set(data, forKey: budgetKey)
        }
    }
    
    private func calculateCarryOver(for date: Date) -> Double {
        guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date),
              let previousBudget = budget(for: previousDate) else {
            return 0
        }
        
        return previousBudget.remaining
    }
    
    private func updateCarryOver(for date: Date) {
        let dateString = dateFormatter.string(from: date)
        var budgets = budgetSubject.value
        
        if let existingBudget = budgets[dateString] {
            let carryOver = calculateCarryOver(for: date)
            let updatedBudget = Budget(
                date: date,
                amount: existingBudget.amount,
                spent: existingBudget.spent,
                carryOver: carryOver
            )
            budgets[dateString] = updatedBudget
            budgetSubject.send(budgets)
            saveToDefaults()
        }
    }
    
    // MARK: - Helper Methods
    func getBudgetStatus(for date: Date) -> (isOverSpent: Bool, hasCarryOver: Bool) {
        guard let budget = budget(for: date) else {
            return (false, false)
        }
        
        return (
            isOverSpent: budget.spent > budget.amount,
            hasCarryOver: budget.carryOver != 0
        )
    }
    
    func getMonthlyBudgets(for date: Date) -> [Date: Budget] {
        let calendar = Calendar.current
        guard let monthRange = calendar.range(of: .day, in: .month, for: date) else {
            return [:]
        }
        
        var monthlyBudgets: [Date: Budget] = [:]
        
        for day in monthRange {
            if let currentDate = calendar.date(bySetting: .day, value: day, of: date),
               let budget = self.budget(for: currentDate) {
                monthlyBudgets[currentDate] = budget
            }
        }
        
        return monthlyBudgets
    }
}
