import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var budgetViewModel: BudgetViewModel
    @State private var isOnboarding = true
    
    init(modelContext: ModelContext) {
        let viewModel = BudgetViewModel(modelContext: modelContext)
        _budgetViewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            if !budgetViewModel.isOnboardingCompleted {
                OnboardingView(
                    isOnboarding: $isOnboarding, 
                    modelContext: modelContext,
                    parentViewModel: budgetViewModel
                )
            } else {
                BudgetView(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Budget.self, configurations: config)
    
    return ContentView(modelContext: container.mainContext)
        .modelContainer(container)
}
