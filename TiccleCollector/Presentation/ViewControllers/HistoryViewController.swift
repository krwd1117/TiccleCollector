import UIKit
import FSCalendar

class HistoryViewController: UIViewController {
    private let budgetManager = BudgetManager.shared
    private var dates: [Date] = []
    private var budgets: [(date: Date, budget: Budget)] = []
    
    // MARK: - UI Components
    private lazy var calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.appearance.titleDefaultColor = .label
        calendar.appearance.headerTitleColor = .label
        calendar.appearance.weekdayTextColor = .secondaryLabel
        calendar.appearance.todayColor = .systemBlue
        calendar.appearance.selectionColor = .systemBlue
        calendar.appearance.headerDateFormat = "YYYY년 M월"
        calendar.appearance.headerTitleAlignment = .center
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.delegate = self
        calendar.dataSource = self
        return calendar
    }()
    
    private let budgetInfoView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let budgetLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    private let spentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("예산 수정", for: .normal)
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadBudgets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBudgets()
        calendar.reloadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "예산 내역"
        view.backgroundColor = .systemBackground
        
        view.addSubview(calendar)
        view.addSubview(budgetInfoView)
        
        budgetInfoView.addSubview(dateLabel)
        budgetInfoView.addSubview(budgetLabel)
        budgetInfoView.addSubview(spentLabel)
        budgetInfoView.addSubview(editButton)
        
        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            calendar.heightAnchor.constraint(equalToConstant: 300),
            
            budgetInfoView.topAnchor.constraint(equalTo: calendar.bottomAnchor, constant: 24),
            budgetInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            budgetInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            budgetInfoView.heightAnchor.constraint(equalToConstant: 160),
            
            dateLabel.topAnchor.constraint(equalTo: budgetInfoView.topAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: budgetInfoView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: budgetInfoView.trailingAnchor, constant: -16),
            
            budgetLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            budgetLabel.leadingAnchor.constraint(equalTo: budgetInfoView.leadingAnchor, constant: 16),
            budgetLabel.trailingAnchor.constraint(equalTo: budgetInfoView.trailingAnchor, constant: -16),
            
            spentLabel.topAnchor.constraint(equalTo: budgetLabel.bottomAnchor, constant: 8),
            spentLabel.leadingAnchor.constraint(equalTo: budgetInfoView.leadingAnchor, constant: 16),
            spentLabel.trailingAnchor.constraint(equalTo: budgetInfoView.trailingAnchor, constant: -16),
            
            editButton.bottomAnchor.constraint(equalTo: budgetInfoView.bottomAnchor, constant: -16),
            editButton.trailingAnchor.constraint(equalTo: budgetInfoView.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Data
    private func loadBudgets() {
        budgets = budgetManager.loadBudgets()
            .sorted { $0.date > $1.date }
        dates = budgets.map { $0.date }
    }
    
    private func updateBudgetInfo(for date: Date) {
        if let budget = budgetManager.budget(for: date) {
            dateLabel.text = formatDate(date)
            budgetLabel.text = formatCurrency(budget.amount)
            spentLabel.text = "사용: " + formatCurrency(budget.spent)
        } else {
            dateLabel.text = formatDate(date)
            budgetLabel.text = "예산 미설정"
            spentLabel.text = ""
        }
    }
    
    // MARK: - Actions
    @objc private func editButtonTapped() {
        guard let selectedDate = calendar.selectedDate else { return }
        let editBudgetVC = EditBudgetViewController()
        editBudgetVC.date = selectedDate
        let navigationController = UINavigationController(rootViewController: editBudgetVC)
        present(navigationController, animated: true)
    }
    
    // MARK: - Helpers
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: date)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return "₩" + (formatter.string(from: NSNumber(value: amount)) ?? "0")
    }
}

// MARK: - FSCalendarDelegate, FSCalendarDataSource
extension HistoryViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        updateBudgetInfo(for: date)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return budgetManager.budget(for: date) != nil ? 1 : 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        if let budget = budgetManager.budget(for: date) {
            return [budget.spent > budget.amount ? .systemRed : .systemGreen]
        }
        return nil
    }
}
