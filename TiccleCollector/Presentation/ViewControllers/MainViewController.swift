import UIKit
import Combine

class MainViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    private let budgetManager = BudgetManager.shared
    
    // MARK: - UI Components
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let remainingBudgetLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let spentAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addExpenseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("지출 입력", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let editBudgetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("예산 수정", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupActions()
        updateDateLabel()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "티끌모아티끌"
        
        let stackView = UIStackView(arrangedSubviews: [
            dateLabel,
            remainingBudgetLabel,
            spentAmountLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        view.addSubview(addExpenseButton)
        view.addSubview(editBudgetButton)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            
            addExpenseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addExpenseButton.bottomAnchor.constraint(equalTo: editBudgetButton.topAnchor, constant: -20),
            addExpenseButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            addExpenseButton.heightAnchor.constraint(equalToConstant: 50),
            
            editBudgetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editBudgetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
        ])
    }
    
    private func setupBindings() {
        budgetManager.$currentBudget
            .receive(on: DispatchQueue.main)
            .sink { [weak self] budget in
                self?.updateUI(with: budget)
            }
            .store(in: &cancellables)
    }
    
    private func setupActions() {
        addExpenseButton.addTarget(self, action: #selector(addExpenseButtonTapped), for: .touchUpInside)
        editBudgetButton.addTarget(self, action: #selector(editBudgetButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - UI Updates
    private func updateUI(with budget: Budget?) {
        guard let budget = budget else { return }
        
        remainingBudgetLabel.text = formatCurrency(budget.remaining)
        spentAmountLabel.text = "지출: \(formatCurrency(budget.spent))"
        
        // 예산 초과시 빨간색으로 표시
        remainingBudgetLabel.textColor = budget.remaining < 0 ? .systemRed : .label
    }
    
    private func updateDateLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        dateLabel.text = formatter.string(from: Date())
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return "\(formatter.string(from: NSNumber(value: amount)) ?? "0")원"
    }
    
    // MARK: - Actions
    @objc private func addExpenseButtonTapped() {
        let addExpenseVC = AddExpenseViewController()
        let navigationController = UINavigationController(rootViewController: addExpenseVC)
        present(navigationController, animated: true)
    }
    
    @objc private func editBudgetButtonTapped() {
        let editBudgetVC = EditBudgetViewController()
        let navigationController = UINavigationController(rootViewController: editBudgetVC)
        present(navigationController, animated: true)
    }
}
