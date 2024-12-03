import UIKit
import Combine

class AddExpenseViewController: UIViewController {
    // MARK: - UI Components
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "지출 금액을 입력하세요"
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.font = .systemFont(ofSize: 24)
        return textField
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("저장", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Properties
    private let viewModel: AddExpenseViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(viewModel: AddExpenseViewModel = AddExpenseViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "지출 추가"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        [amountTextField, descriptionLabel, saveButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            amountTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            amountTextField.heightAnchor.constraint(equalToConstant: 50),
            
            descriptionLabel.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            saveButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        amountTextField.addTarget(self, action: #selector(amountTextFieldChanged), for: .editingChanged)
    }
    
    private func setupBindings() {
        viewModel.descriptionText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.descriptionLabel.text = text
            }
            .store(in: &cancellables)
        
        viewModel.isValidInput
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: saveButton)
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        viewModel.saveExpense()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.showError(message: error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] in
                    self?.dismiss(animated: true)
                }
            )
            .store(in: &cancellables)
    }
    
    @objc private func amountTextFieldChanged() {
        viewModel.updateAmount(amountTextField.text ?? "")
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
