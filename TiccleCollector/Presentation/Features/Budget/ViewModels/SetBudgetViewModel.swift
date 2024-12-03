import Foundation
import Combine

final class SetBudgetViewModel {
    // MARK: - Properties
    private let budgetRepository: BudgetRepository
    private var cancellables = Set<AnyCancellable>()
    
    private let descriptionTextSubject = CurrentValueSubject<String, Never>("")
    private let isValidInputSubject = CurrentValueSubject<Bool, Never>(false)
    
    private var selectedDates = Set<Date>()
    private var amount: Decimal = 0
    
    var descriptionText: AnyPublisher<String, Never> {
        descriptionTextSubject.eraseToAnyPublisher()
    }
    
    var isValidInput: AnyPublisher<Bool, Never> {
        isValidInputSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    init(budgetRepository: BudgetRepository = DefaultBudgetRepository()) {
        self.budgetRepository = budgetRepository
    }
    
    // MARK: - Public
    func updateSelectedDates(_ dates: Set<Date>) {
        selectedDates = dates
        updateDescription()
        validateInput()
    }
    
    func updateAmount(_ text: String) {
        amount = Decimal(string: text.replacingOccurrences(of: ",", with: "")) ?? 0
        updateDescription()
        validateInput()
    }
    
    func saveBudget() -> AnyPublisher<Void, Error> {
        guard !selectedDates.isEmpty, amount > 0 else {
            return Fail(error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "유효하지 않은 입력입니다."]))
                .eraseToAnyPublisher()
        }
        
        let budgets = selectedDates.map { date in
            Budget(amount: amount, date: date)
        }
        
        return Publishers.MergeMany(
            budgets.map { budget in
                budgetRepository.save(budget)
            }
        )
        .collect()
        .map { _ in }
        .eraseToAnyPublisher()
    }
    
    func getBudgetStatus(for date: Date) -> BudgetStatus {
        let isSelected = selectedDates.contains { $0.isSameDay(as: date) }
        return BudgetStatus(isSelected: isSelected)
    }
    
    // MARK: - Private
    private func updateDescription() {
        let dateText = selectedDates.isEmpty ? "날짜를 선택하세요" : "\(selectedDates.count)일 선택됨"
        let amountText = amount > 0 ? amount.formattedCurrency : "금액을 입력하세요"
        descriptionTextSubject.send("\(dateText)\n\(amountText)")
    }
    
    private func validateInput() {
        isValidInputSubject.send(!selectedDates.isEmpty && amount > 0)
    }
}

// MARK: - BudgetStatus
extension SetBudgetViewModel {
    struct BudgetStatus {
        let isSelected: Bool
        
        init(isSelected: Bool = false) {
            self.isSelected = isSelected
        }
    }
}
