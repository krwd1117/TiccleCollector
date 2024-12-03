import Foundation
import Combine

protocol ExpenseRepository {
    func save(_ expense: Expense) -> AnyPublisher<Void, Error>
    func getExpenses(for date: Date) -> AnyPublisher<[Expense], Error>
    func getExpenses(from startDate: Date, to endDate: Date) -> AnyPublisher<[Expense], Error>
    func deleteExpense(id: UUID) -> AnyPublisher<Void, Error>
}

final class DefaultExpenseRepository: ExpenseRepository {
    private let storage: Storage
    
    init(storage: Storage = UserDefaultsStorage()) {
        self.storage = storage
    }
    
    func save(_ expense: Expense) -> AnyPublisher<Void, Error> {
        getExpenses()
            .flatMap { [storage] expenses -> AnyPublisher<Void, Error> in
                var updatedExpenses = expenses
                updatedExpenses.append(expense)
                return storage.save(updatedExpenses, for: .expenses)
            }
            .eraseToAnyPublisher()
    }
    
    func getExpenses(for date: Date) -> AnyPublisher<[Expense], Error> {
        getExpenses()
            .map { expenses in
                expenses.filter { $0.isSameDay(as: date) }
            }
            .eraseToAnyPublisher()
    }
    
    func getExpenses(from startDate: Date, to endDate: Date) -> AnyPublisher<[Expense], Error> {
        getExpenses()
            .map { expenses in
                expenses.filter { expense in
                    let isAfterStart = expense.date >= startDate
                    let isBeforeEnd = expense.date <= endDate
                    return isAfterStart && isBeforeEnd
                }
            }
            .eraseToAnyPublisher()
    }
    
    func deleteExpense(id: UUID) -> AnyPublisher<Void, Error> {
        getExpenses()
            .flatMap { [storage] expenses -> AnyPublisher<Void, Error> in
                let updatedExpenses = expenses.filter { $0.id != id }
                return storage.save(updatedExpenses, for: .expenses)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private
    private func getExpenses() -> AnyPublisher<[Expense], Error> {
        storage.load([Expense].self, for: .expenses)
            .catch { _ in Just([]) }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
