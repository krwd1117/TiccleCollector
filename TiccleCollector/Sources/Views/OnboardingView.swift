import SwiftUI
import SwiftData

// 앱의 온보딩 화면을 담당하는 뷰
// 사용자가 처음 앱을 실행할 때 월간 예산을 설정하도록 안내
struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: BudgetViewModel
    @State private var monthlyIncomeText: String = ""
    @Binding var isOnboarding: Bool
    
    // ContentView의 budgetViewModel을 받아옴
    let parentViewModel: BudgetViewModel
    
    init(isOnboarding: Binding<Bool>, modelContext: ModelContext, parentViewModel: BudgetViewModel) {
        self._isOnboarding = isOnboarding
        self.parentViewModel = parentViewModel
        let viewModel = BudgetViewModel(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("티끌모아티끌")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("매일의 지출을 체계적으로 관리해보세요")
                .font(.headline)
                .foregroundColor(.gray)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("월 수입을 입력해주세요")
                    .font(.headline)
                
                TextField("예: 3,000,000", text: $monthlyIncomeText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: monthlyIncomeText) { newValue in
                        // 숫자만 입력되도록 필터링
                        monthlyIncomeText = newValue.filter { "0123456789".contains($0) }
                    }
            }
            .padding()
            
            Button(action: {
                if let income = Double(monthlyIncomeText) {
                    viewModel.setMonthlyBudget(from: income)
                    // 부모 뷰모델도 업데이트
                    parentViewModel.isOnboardingCompleted = true
                    parentViewModel.monthlyIncome = income
                    parentViewModel.monthlyBudget = income * 0.7
                    parentViewModel.budget = viewModel.budget
                    
                    isOnboarding = false
                }
            }) {
                Text("시작하기")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(monthlyIncomeText.isEmpty)
            
            Spacer()
        }
        .padding()
    }
}

//#Preview {
//    OnboardingView(isOnboarding: .constant(true))
//}
