import UIKit

class AddExpenseViewController: UIViewController {
    private let budgetManager = BudgetManager.shared
    
    // MARK: - UI Components
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "지출 금액"
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        amountTextField.becomeFirstResponder()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "지출 입력"
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        })
        
        let amountStack = UIStackView(arrangedSubviews: [amountTextField, currencyLabel])
        amountStack.axis = .horizontal
        amountStack.spacing = 8
        amountStack.alignment = .center
        amountStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(amountStack)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            amountStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            amountStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            amountStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
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
        amountTextField.inputAccessoryView = toolbar
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func saveButtonTapped() {
        guard let amountText = amountTextField.text,
              let amount = Double(amountText) else {
            showAlert(message: "올바른 금액을 입력해주세요")
            return
        }
        
        budgetManager.addSpent(amount: amount, for: Date())
        dismiss(animated: true)
    }
    
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "오류", 
                                      message: message, 
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
