import Foundation
import SwiftData

// 예산 관리를 위한 뷰모델
// SwiftData를 사용하여 예산 데이터를 관리하고 유효성 검사를 수행
class BudgetViewModel: ObservableObject {
    // SwiftData의 ModelContext 인스턴스
    private var modelContext: ModelContext
    // 현재 설정된 예산 정보
    var budget: Budget?
    // 사용자가 입력한 월간 예산 문자열
    var monthlyBudgetInput: String = ""
    // 유효성 검사 실패 시 표시할 에러 메시지
    var errorMessage: String = ""
    
    @Published var monthlyIncome: Double = 0.0
    @Published var monthlyBudget: Double = 0.0
    @Published var todaySpent: Double = 0.0
    @Published var isLoading: Bool = false
    @Published var isOnboardingCompleted: Bool = false
    
    @Published var todayExpenses: [Expense] = []
    
    var dailyBudget: Double {
        budget?.dailyAmount ?? monthlyBudget / 30.0
    }
    
    var remainingBudget: Double {
        dailyBudget - todaySpent
    }
    
    // 초기화: ModelContext를 받아 기존 예산 정보를 불러옴
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchBudget()
    }
    
    // 저장된 예산 정보를 불러오는 private 메서드
    private func fetchBudget() {
        let descriptor = FetchDescriptor<Budget>()
        if let existingBudget = try? modelContext.fetch(descriptor).first {
            budget = existingBudget
        }
    }
    
    // 새로운 예산을 저장하고 유효성을 검사하는 메서드
    // 반환값: 저장 성공 여부
    func saveBudget() -> Bool {
        guard let amount = Double(monthlyBudgetInput) else {
            errorMessage = "Please enter a valid amount"
            return false
        }
        
        if amount <= 0 {
            errorMessage = "Amount must be greater than 0"
            return false
        }
        
        let newBudget = Budget(monthlyAmount: amount)
        modelContext.insert(newBudget)
        try? modelContext.save()
        budget = newBudget
        return true
    }
    
    // 예산이 설정되었는지 확인하는 계산 속성
    var hasSetupBudget: Bool {
        budget != nil
    }
    
    func setMonthlyBudget(from income: Double) {
        monthlyIncome = income
        monthlyBudget = income * 0.7
        
        // SwiftData에 예산 저장
        let newBudget = Budget(monthlyAmount: monthlyBudget)
        modelContext.insert(newBudget)
        try? modelContext.save()
        budget = newBudget
        
        isOnboardingCompleted = true
    }
    
    func addExpense(amount: Double, category: String, memo: String? = nil) {
        let expense = Expense(
            id: UUID(),
            amount: amount,
            category: category,
            memo: memo,
            date: Date()
        )
        todayExpenses.append(expense)
        todaySpent += amount
        saveExpense(expense)
    }
    
    private func saveUserData() {
        // SwiftData 구현 예정
    }
    
    private func saveExpense(_ expense: Expense) {
        // SwiftData 구현 예정
    }
}

struct Expense: Identifiable {
    let id: UUID
    let amount: Double
    let category: String
    let memo: String?
    let date: Date
}
