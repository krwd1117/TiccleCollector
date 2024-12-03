import UIKit

class EditBudgetViewController: UIViewController {
    private let budgetManager = BudgetManager.shared
    
    // MARK: - UI Components
    private let budgetTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "일일 예산 입력"
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "변경된 예산은 다음 날부터 적용됩니다"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
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
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "예산 수정"
        
        view.addSubview(budgetTextField)
        view.addSubview(descriptionLabel)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            budgetTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            budgetTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            budgetTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: budgetTextField.bottomAnchor, constant: 8),
            descriptionLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
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
        if let currentBudget = budgetManager.currentBudget {
            budgetTextField.text = String(format: "%.0f", currentBudget.amount)
        }
    }
    
    // MARK: - Actions
    @objc private func saveButtonTapped() {
        guard let budgetText = budgetTextField.text,
              let amount = Double(budgetText) else {
            let alert = UIAlertController(title: "오류", message: "올바른 금액을 입력해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        budgetManager.setDailyBudget(amount)
        dismiss(animated: true)
    }
    
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
}
