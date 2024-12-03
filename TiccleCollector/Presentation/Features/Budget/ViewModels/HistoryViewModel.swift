import Foundation
import Combine

final class HistoryViewModel {
    // MARK: - Properties
    private let budgetRepository: BudgetRepository
    private let expenseRepository: ExpenseRepository
    private let calendar = Calendar.current
    private var cancellables = Set<AnyCancellable>()
    
    private let historiesSubject = CurrentValueSubject<[BudgetHistory], Never>([])
    
    var histories: AnyPublisher<[BudgetHistory], Never> {
        historiesSubject.eraseToAnyPublisher()
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
    func fetchHistories() {
        let today = Date()
        let startDate = calendar.date(byAdding: .month, value: -1, to: today) ?? today
        
        Publishers.CombineLatest(
            budgetRepository.getBudgets(from: startDate, to: today),
            expenseRepository.getExpenses(from: startDate, to: today)
        )
        .map { budgets, expenses -> [BudgetHistory] in
            var histories: [BudgetHistory] = []
            
            // 예산 내역
            histories.append(contentsOf: budgets.map { budget in
                BudgetHistory(
                    dateText: self.formatDate(budget.date),
                    amountText: budget.amount.formattedCurrency,
                    typeText: "예산 설정",
                    isExpense: false
                )
            })
            
            // 지출 내역
            histories.append(contentsOf: expenses.map { expense in
                BudgetHistory(
                    dateText: self.formatDate(expense.date),
                    amountText: expense.amount.formattedCurrency,
                    typeText: "지출",
                    isExpense: true
                )
            })
            
            // 날짜순 정렬
            return histories.sorted { history1, history2 in
                guard let date1 = self.parseDate(history1.dateText),
                      let date2 = self.parseDate(history2.dateText) else {
                    return false
                }
                return date1 > date2
            }
        }
        .catch { _ in Just([]) }
        .sink { [weak self] histories in
            self?.historiesSubject.send(histories)
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Private
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.date(from: dateString)
    }
}

// MARK: - BudgetHistory
struct BudgetHistory {
    let dateText: String
    let amountText: String
    let typeText: String
    let isExpense: Bool
}
