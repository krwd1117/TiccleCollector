import Foundation
import Combine

protocol BudgetRepository {
    func save(_ budget: Budget) -> AnyPublisher<Void, Error>
    func getBudget(for date: Date) -> AnyPublisher<Budget?, Error>
    func getBudgets(from startDate: Date, to endDate: Date) -> AnyPublisher<[Budget], Error>
    func getBudgetStatus(for date: Date) -> AnyPublisher<Budget.Status, Error>
    func deleteBudget(id: UUID) -> AnyPublisher<Void, Error>
}

final class DefaultBudgetRepository: BudgetRepository {
    private let storage: Storage
    private let expenseRepository: ExpenseRepository
    
    init(
        storage: Storage = UserDefaultsStorage(),
        expenseRepository: ExpenseRepository = DefaultExpenseRepository()
    ) {
        self.storage = storage
        self.expenseRepository = expenseRepository
    }
    
    func save(_ budget: Budget) -> AnyPublisher<Void, Error> {
        getBudgets()
            .flatMap { [storage] budgets -> AnyPublisher<Void, Error> in
                var updatedBudgets = budgets.filter { !$0.isSameDay(as: budget.date) }
                updatedBudgets.append(budget)
                return storage.save(updatedBudgets, for: .budgets)
            }
            .eraseToAnyPublisher()
    }
    
    func getBudget(for date: Date) -> AnyPublisher<Budget?, Error> {
        getBudgets()
            .map { budgets in
                budgets.first { $0.isSameDay(as: date) }
            }
            .eraseToAnyPublisher()
    }
    
    func getBudgets(from startDate: Date, to endDate: Date) -> AnyPublisher<[Budget], Error> {
        getBudgets()
            .map { budgets in
                budgets.filter { budget in
                    let isAfterStart = budget.date >= startDate
                    let isBeforeEnd = budget.date <= endDate
                    return isAfterStart && isBeforeEnd
                }
            }
            .eraseToAnyPublisher()
    }
    
    func getBudgetStatus(for date: Date) -> AnyPublisher<Budget.Status, Error> {
        Publishers.CombineLatest(
            getBudget(for: date),
            expenseRepository.getExpenses(for: date)
        )
        .flatMap { [weak self] budget, expenses -> AnyPublisher<Budget.Status, Error> in
            guard let self = self else {
                return Fail(error: StorageError.unknown).eraseToAnyPublisher()
            }
            
            let totalExpense = expenses.reduce(Decimal(0)) { $0 + $1.amount }
            
            guard let budget = budget else {
                return Just(Budget.Status())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            
            return self.getBudget(for: Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date)
                .map { previousBudget -> Budget.Status in
                    let carryOver = previousBudget?.amount ?? 0
                    let remainingAmount = budget.amount + carryOver - totalExpense
                    
                    return Budget.Status(
                        isOverSpent: remainingAmount < 0,
                        hasCarryOver: carryOver > 0,
                        remainingAmount: remainingAmount
                    )
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    func deleteBudget(id: UUID) -> AnyPublisher<Void, Error> {
        getBudgets()
            .flatMap { [storage] budgets -> AnyPublisher<Void, Error> in
                let updatedBudgets = budgets.filter { $0.id != id }
                return storage.save(updatedBudgets, for: .budgets)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private
    private func getBudgets() -> AnyPublisher<[Budget], Error> {
        storage.load([Budget].self, for: .budgets)
            .catch { _ in Just([]) }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
