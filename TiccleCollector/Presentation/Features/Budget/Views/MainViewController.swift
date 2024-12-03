import UIKit
import Combine

class MainViewController: UIViewController {
    // MARK: - UI Components
    private let budgetLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private let remainingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let addExpenseButton: UIButton = {
        let button = UIButton()
        button.setTitle("지출 추가", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        return button
    }()
    
    private let setBudgetButton: UIButton = {
        let button = UIButton()
        button.setTitle("예산 설정", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 25
        return button
    }()
    
    private let historyButton: UIButton = {
        let button = UIButton()
        button.setTitle("내역 보기", for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 25
        return button
    }()
    
    // MARK: - Properties
    private let viewModel: MainViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(viewModel: MainViewModel = MainViewModel()) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchBudgetInfo()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "예산 관리"
        
        [budgetLabel, remainingLabel, addExpenseButton, setBudgetButton, historyButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            budgetLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            budgetLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            budgetLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            remainingLabel.topAnchor.constraint(equalTo: budgetLabel.bottomAnchor, constant: 8),
            remainingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            remainingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            addExpenseButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            addExpenseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addExpenseButton.widthAnchor.constraint(equalToConstant: 200),
            addExpenseButton.heightAnchor.constraint(equalToConstant: 50),
            
            setBudgetButton.topAnchor.constraint(equalTo: addExpenseButton.bottomAnchor, constant: 20),
            setBudgetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            setBudgetButton.widthAnchor.constraint(equalToConstant: 200),
            setBudgetButton.heightAnchor.constraint(equalToConstant: 50),
            
            historyButton.topAnchor.constraint(equalTo: setBudgetButton.bottomAnchor, constant: 20),
            historyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            historyButton.widthAnchor.constraint(equalToConstant: 200),
            historyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        addExpenseButton.addTarget(self, action: #selector(addExpenseButtonTapped), for: .touchUpInside)
        setBudgetButton.addTarget(self, action: #selector(setBudgetButtonTapped), for: .touchUpInside)
        historyButton.addTarget(self, action: #selector(historyButtonTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.budgetInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] info in
                self?.updateUI(with: info)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with info: BudgetInfo) {
        budgetLabel.text = info.budgetText
        remainingLabel.text = info.remainingText
        
        if info.isOverSpent {
            remainingLabel.textColor = .systemRed
        } else {
            remainingLabel.textColor = .secondaryLabel
        }
    }
    
    // MARK: - Actions
    @objc private func addExpenseButtonTapped() {
        let viewController = AddExpenseViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
    
    @objc private func setBudgetButtonTapped() {
        let viewController = SetBudgetViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
    
    @objc private func historyButtonTapped() {
        let viewController = HistoryViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
