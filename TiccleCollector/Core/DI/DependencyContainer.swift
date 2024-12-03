import Foundation

final class DependencyContainer {
    static let shared = DependencyContainer()
    
    private init() {}
    
    // MARK: - Storage
    private lazy var storage: Storage = {
        UserDefaultsStorage()
    }()
    
    // MARK: - Repositories
    private lazy var budgetRepository: BudgetRepository = {
        DefaultBudgetRepository(storage: storage, expenseRepository: expenseRepository)
    }()
    
    private lazy var expenseRepository: ExpenseRepository = {
        DefaultExpenseRepository(storage: storage)
    }()
    
    // MARK: - ViewModels
    func makeMainViewModel() -> MainViewModel {
        MainViewModel(budgetRepository: budgetRepository)
    }
    
    func makeHistoryViewModel() -> HistoryViewModel {
        HistoryViewModel(budgetRepository: budgetRepository)
    }
    
    func makeSetBudgetViewModel() -> SetBudgetViewModel {
        SetBudgetViewModel(budgetRepository: budgetRepository)
    }
    
    func makeAddExpenseViewModel() -> AddExpenseViewModel {
        AddExpenseViewModel(expenseRepository: expenseRepository)
    }
}
