import Foundation
import Combine

final class MainViewModel {
    // MARK: - Properties
    private let budgetRepository: BudgetRepository
    private let expenseRepository: ExpenseRepository
    private var cancellables = Set<AnyCancellable>()
    
    private let budgetInfoSubject = CurrentValueSubject<BudgetInfo, Never>(BudgetInfo())
    
    var budgetInfo: AnyPublisher<BudgetInfo, Never> {
        budgetInfoSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    init(
        budgetRepository: BudgetRepository = DefaultBudgetRepository(),
        expenseRepository: ExpenseRepository = DefaultExpenseRepository()
    ) {
        self.budgetRepository = budgetRepository
        self.expenseRepository = expenseRepository
    }
    
    // MARK: - Public
    func fetchBudgetInfo() {
        let today = Date()
        
        Publishers.CombineLatest(
            budgetRepository.getBudget(for: today),
            budgetRepository.getBudgetStatus(for: today)
        )
        .map { budget, status -> BudgetInfo in
            BudgetInfo(
                budgetText: budget?.amount.formattedCurrency ?? "예산 미설정",
                remainingText: status.remainingAmount.formattedCurrency,
                isOverSpent: status.isOverSpent
            )
        }
        .catch { _ in Just(BudgetInfo()) }
        .sink { [weak self] info in
            self?.budgetInfoSubject.send(info)
        }
        .store(in: &cancellables)
    }
}

// MARK: - BudgetInfo
struct BudgetInfo {
    let budgetText: String
    let remainingText: String
    let isOverSpent: Bool
    
    init(
        budgetText: String = "예산 미설정",
        remainingText: String = "₩0",
        isOverSpent: Bool = false
    ) {
        self.budgetText = budgetText
        self.remainingText = remainingText
        self.isOverSpent = isOverSpent
    }
}
