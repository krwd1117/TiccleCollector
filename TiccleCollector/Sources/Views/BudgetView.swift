import SwiftUI
import SwiftData

struct BudgetView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: BudgetViewModel
    @State private var showingExpenseSheet = false
    
    init(modelContext: ModelContext) {
        let viewModel = BudgetViewModel(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 오늘의 예산 카드
                    DailyBudgetCard(
                        dailyBudget: viewModel.dailyBudget,
                        todaySpent: viewModel.todaySpent,
                        remainingBudget: viewModel.remainingBudget
                    )
                    .padding(.horizontal)
                    
                    // 오늘의 지출 내역
                    TodayExpensesList(expenses: viewModel.todayExpenses)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("티끌모아티끌")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingExpenseSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: CalendarView(viewModel: viewModel)) {
                        Image(systemName: "calendar")
                            .font(.title2)
                    }
                }
            }
        }
        .sheet(isPresented: $showingExpenseSheet) {
            ExpenseInputSheet(isPresented: $showingExpenseSheet, viewModel: viewModel)
        }
    }
}

// 일일 예산 카드 뷰
struct DailyBudgetCard: View {
    let dailyBudget: Double
    let todaySpent: Double
    let remainingBudget: Double
    
    var body: some View {
        VStack(spacing: 15) {
            Text("오늘의 예산")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text(remainingBudget.formatted(.currency(code: "KRW")))
                .font(.system(size: 40, weight: .bold))
            
            HStack {
                VStack(alignment: .leading) {
                    Text("일일 예산")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(dailyBudget.formatted(.currency(code: "KRW")))
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("지출")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(todaySpent.formatted(.currency(code: "KRW")))
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
            
            // 프로그레스 바
            ProgressView(value: todaySpent, total: dailyBudget)
                .tint(todaySpent > dailyBudget ? .red : .blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// 오늘의 지출 내역 리스트
struct TodayExpensesList: View {
    let expenses: [Expense]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("오늘의 지출")
                .font(.headline)
            
            if expenses.isEmpty {
                Text("아직 기록된 지출이 없습니다")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(expenses) { expense in
                    ExpenseRow(expense: expense)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// 지출 항목 행
struct ExpenseRow: View {
    let expense: Expense
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(expense.category)
                    .font(.headline)
                Text(expense.memo ?? "")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(expense.amount.formatted(.currency(code: "KRW")))
                .font(.headline)
        }
        .padding(.vertical, 8)
    }
}
