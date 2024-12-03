import Foundation
import Combine

class BudgetManager {
    static let shared = BudgetManager()
    private let defaults = UserDefaults.standard
    
    private let budgetKey = "dailyBudget"
    private let spentKey = "spentAmount"
    
    @Published private(set) var currentBudget: Budget?
    
    private init() {
        loadTodayBudget()
    }
    
    func setDailyBudget(_ amount: Double) {
        defaults.set(amount, forKey: budgetKey)
        loadTodayBudget()
    }
    
    func addSpentAmount(_ amount: Double) {
        guard var budget = currentBudget else { return }
        budget.spent += amount
        defaults.set(budget.spent, forKey: spentKey)
        currentBudget = budget
    }
    
    private func loadTodayBudget() {
        let amount = defaults.double(forKey: budgetKey)
        let spent = defaults.double(forKey: spentKey)
        currentBudget = Budget(date: Date(), amount: amount, spent: spent)
    }
    
    func resetDailySpent() {
        defaults.set(0.0, forKey: spentKey)
        loadTodayBudget()
    }
}
