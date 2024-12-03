import Foundation
import Combine

final class AddExpenseViewModel {
    // MARK: - Properties
    private let expenseRepository: ExpenseRepository
    private var cancellables = Set<AnyCancellable>()
    
    private let descriptionTextSubject = CurrentValueSubject<String, Never>("")
    private let isValidInputSubject = CurrentValueSubject<Bool, Never>(false)
    
    private var amount: Decimal = 0
    
    var descriptionText: AnyPublisher<String, Never> {
        descriptionTextSubject.eraseToAnyPublisher()
    }
    
    var isValidInput: AnyPublisher<Bool, Never> {
        isValidInputSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    init(expenseRepository: ExpenseRepository = DefaultExpenseRepository()) {
        self.expenseRepository = expenseRepository
    }
    
    // MARK: - Public
    func updateAmount(_ text: String) {
        amount = Decimal(string: text.replacingOccurrences(of: ",", with: "")) ?? 0
        updateDescription()
        validateInput()
    }
    
    func saveExpense() -> AnyPublisher<Void, Error> {
        guard amount > 0 else {
            return Fail(error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "유효하지 않은 금액입니다."]))
                .eraseToAnyPublisher()
        }
        
        let expense = Expense(amount: amount)
        return expenseRepository.save(expense)
    }
    
    // MARK: - Private
    private func updateDescription() {
        let amountText = amount > 0 ? amount.formattedCurrency : "금액을 입력하세요"
        descriptionTextSubject.send(amountText)
    }
    
    private func validateInput() {
        isValidInputSubject.send(amount > 0)
    }
}
