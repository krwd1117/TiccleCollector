import Foundation
import SwiftData

// 예산 관리를 위한 뷰모델
// SwiftData를 사용하여 예산 데이터를 관리하고 유효성 검사를 수행
class BudgetViewModel: ObservableObject {
    // SwiftData의 ModelContext 인스턴스
    private var modelContext: ModelContext
    
    // 현재 설정된 예산 정보
    var budget: Budget?
    
    // 유효성 검사 실패 시 표시할 에러 메시지
    var errorMessage: String = ""
    
    @Published var todaySpent: Double = 0.0
    @Published var isLoading: Bool = false
    @Published var isOnboardingCompleted: Bool = false
    @Published var todayExpenses: [Expense] = []
    
    var dailyBudget: Double {
        budget?.dailyAmount ?? 0.0
    }
    
    var remainingBudget: Double {
        dailyBudget - todaySpent
    }
    
    // 초기화: ModelContext를 받아 기존 예산 정보를 불러옴
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.isOnboardingCompleted = UserDefaults.standard.bool(forKey: "isOnboardingCompleted")
        loadBudget()
    }
    
    // 저장된 예산 정보를 불러오는 private 메서드
    private func loadBudget() {
        let descriptor = FetchDescriptor<Budget>()
        if let existingBudget = try? modelContext.fetch(descriptor).first {
            budget = existingBudget
        }
    }
    
    // 예산이 설정되었는지 확인하는 계산 속성
    var hasSetupBudget: Bool {
        budget != nil
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
    
    func setDailyBudget(_ amount: Double) {
        // 일일 예산 설정
        let newBudget = Budget(dailyAmount: amount)
        modelContext.insert(newBudget)
        try? modelContext.save()
        budget = newBudget
        
        // onboarding 완료 상태 저장
        UserDefaults.standard.set(true, forKey: "isOnboardingCompleted")
        isOnboardingCompleted = true
    }
}
