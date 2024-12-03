import UIKit
import Combine

class MainViewController: UIViewController {
    private let budgetManager = BudgetManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let budgetLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let spentLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addExpenseButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.title = "지출 추가"
        config.image = UIImage(systemName: "plus.circle.fill")
        config.imagePadding = 8
        config.buttonSize = .large
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addExpenseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        updateDate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBudgetInfo()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "예산"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "calendar"),
            style: .plain,
            target: self,
            action: #selector(historyButtonTapped)
        )
        
        let stackView = UIStackView(arrangedSubviews: [
            dateLabel,
            budgetLabel,
            spentLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        view.addSubview(addExpenseButton)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            
            addExpenseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addExpenseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            addExpenseButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6)
        ])
    }
    
    private func setupBindings() {
        budgetManager.budgetPublisher
            .sink { [weak self] _ in
                self?.updateBudgetInfo()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func updateDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        dateLabel.text = formatter.string(from: Date())
    }
    
    private func updateBudgetInfo() {
        guard let budget = budgetManager.budget(for: Date()) else {
            budgetLabel.text = "예산 미설정"
            spentLabel.text = ""
            return
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        let remaining = budget.amount - budget.spent
        let remainingText = numberFormatter.string(from: NSNumber(value: abs(remaining))) ?? "0"
        
        // 남은 예산 표시
        budgetLabel.text = "₩\(remainingText)"
        budgetLabel.textColor = remaining < 0 ? .systemRed : .label
        
        // 지출 정보 표시
        let spentText = numberFormatter.string(from: NSNumber(value: budget.spent)) ?? "0"
        spentLabel.text = "지출: ₩\(spentText)"
    }
    
    // MARK: - Actions
    @objc private func addExpenseButtonTapped() {
        let addExpenseVC = AddExpenseViewController()
        let navigationController = UINavigationController(rootViewController: addExpenseVC)
        present(navigationController, animated: true)
    }
    
    @objc private func historyButtonTapped() {
        let historyVC = HistoryViewController()
        navigationController?.pushViewController(historyVC, animated: true)
    }
}
