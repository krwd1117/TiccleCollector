import UIKit

class AddExpenseViewController: UIViewController {
    private let budgetManager = BudgetManager.shared
    
    // MARK: - UI Components
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "지출 금액 입력"
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
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
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "지출 입력"
        
        view.addSubview(amountTextField)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            amountTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            amountTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            amountTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 30),
            saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add toolbar with Done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton]
        amountTextField.inputAccessoryView = toolbar
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func saveButtonTapped() {
        guard let amountText = amountTextField.text,
              let amount = Double(amountText) else {
            // Show alert for invalid input
            let alert = UIAlertController(title: "오류", message: "올바른 금액을 입력해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        budgetManager.addSpentAmount(amount)
        dismiss(animated: true)
    }
    
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
}
