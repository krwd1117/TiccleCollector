import UIKit
import Combine

class SetupViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "매일 사용할 예산을 입력해주세요"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let budgetTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "예산 입력"
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("시작하기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(budgetTextField)
        view.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            
            budgetTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            budgetTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            budgetTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.topAnchor.constraint(equalTo: budgetTextField.bottomAnchor, constant: 30),
            startButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupActions() {
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }
    
    @objc private func startButtonTapped() {
        guard let budgetText = budgetTextField.text,
              let budget = Double(budgetText) else {
            let alert = UIAlertController(title: "오류", message: "올바른 금액을 입력해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        BudgetManager.shared.setDailyBudget(budget)
        
        let mainViewController = MainViewController()
        let navigationController = UINavigationController(rootViewController: mainViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}
