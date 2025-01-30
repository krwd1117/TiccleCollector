import SwiftUI
import SwiftData

// 앱의 온보딩 화면을 담당하는 뷰
// 사용자가 처음 앱을 실행할 때 월간 예산을 설정하도록 안내
struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: BudgetViewModel
    @State private var dailyBudgetText: String = ""
    @Binding var isOnboarding: Bool
    
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
                Text("하루 최대 지출 금액을 입력해주세요")
                    .font(.headline)
                
                TextField("예: 30000", text: $dailyBudgetText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    if let dailyBudget = Double(dailyBudgetText) {
                        parentViewModel.setDailyBudget(dailyBudget)
                        parentViewModel.isOnboardingCompleted = true
                    }
                }) {
                    Text("시작하기")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(dailyBudgetText.isEmpty)
            }
            .padding()
            
            Spacer()
        }
    }
}

//#Preview {
//    OnboardingView(isOnboarding: .constant(true))
//}
