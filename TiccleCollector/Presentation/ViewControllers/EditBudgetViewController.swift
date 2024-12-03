import UIKit

class EditBudgetViewController: UIViewController {
    // MARK: - Properties
    var date: Date = Date() // 수정할 날짜
    
    private let budgetManager = BudgetManager.shared
    
    // MARK: - UI Components
    private let budgetTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "일일 예산"
        textField.keyboardType = .numberPad
        textField.font = .systemFont(ofSize: 34, weight: .regular)
        textField.textAlignment = .center
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.text = "원"
        label.font = .systemFont(ofSize: 34, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "변경된 예산은 다음 날부터 적용됩니다"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.configuration?.title = "저장"
        button.configuration?.cornerStyle = .large
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        loadCurrentBudget()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        budgetTextField.becomeFirstResponder()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = Calendar.current.isDateInToday(date) ? "예산 수정" : "\(formatDate(date)) 예산 수정"
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        })
        
        let amountStack = UIStackView(arrangedSubviews: [budgetTextField, currencyLabel])
        amountStack.axis = .horizontal
        amountStack.spacing = 8
        amountStack.alignment = .center
        amountStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(amountStack)
        view.addSubview(descriptionLabel)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            amountStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            amountStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            amountStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: amountStack.bottomAnchor, constant: 8),
            descriptionLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16),
            saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add toolbar with Done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton]
        budgetTextField.inputAccessoryView = toolbar
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    private func loadCurrentBudget() {
        if let budget = budgetManager.budget(for: date) {
            budgetTextField.text = String(format: "%.0f", budget.amount)
        }
    }
    
    // MARK: - Actions
    @objc private func saveButtonTapped() {
        guard let budgetText = budgetTextField.text,
              let amount = Double(budgetText) else {
            let alert = UIAlertController(title: "오류", 
                                        message: "올바른 금액을 입력해주세요", 
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        budgetManager.setBudget(amount: amount, for: date)
        dismiss(animated: true)
    }
    
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: date)
    }
}
