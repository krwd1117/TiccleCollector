import SwiftUI

struct ExpenseInputSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: BudgetViewModel
    @State private var amount: String = ""
    @State private var category: String = "식비"
    @State private var memo: String = ""
    
    let categories = ["식비", "교통비", "생활비", "문화/여가", "기타"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("금액")) {
                    TextField("금액을 입력하세요", text: $amount)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("카테고리")) {
                    Picker("카테고리", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
                
                Section(header: Text("메모")) {
                    TextField("메모를 입력하세요", text: $memo)
                }
            }
            .navigationTitle("지출 입력")
            .navigationBarItems(
                leading: Button("취소") { isPresented = false },
                trailing: Button("저장") {
                    if let amountDouble = Double(amount) {
                        viewModel.addExpense(
                            amount: amountDouble,
                            category: category,
                            memo: memo
                        )
                    }
                    isPresented = false
                }
                .disabled(amount.isEmpty)
            )
        }
    }
} 
