import UIKit
import Combine

class HistoryViewController: UIViewController {
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(HistoryCell.self, forCellReuseIdentifier: "HistoryCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        return tableView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "내역이 없습니다"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.isHidden = true
        return label
    }()
    
    // MARK: - Properties
    private let viewModel: HistoryViewModel
    private var cancellables = Set<AnyCancellable>()
    private var histories: [BudgetHistory] = []
    
    // MARK: - Initialization
    init(viewModel: HistoryViewModel = HistoryViewModel()) {
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
        viewModel.fetchHistories()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "내역"
        
        [tableView, emptyLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.histories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] histories in
                self?.histories = histories
                self?.emptyLabel.isHidden = !histories.isEmpty
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDataSource
extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        let history = histories[indexPath.row]
        cell.configure(with: history)
        return cell
    }
}

// MARK: - HistoryCell
class HistoryCell: UITableViewCell {
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [dateLabel, amountLabel, typeLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            amountLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            amountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            amountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            typeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            typeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with history: BudgetHistory) {
        dateLabel.text = history.dateText
        amountLabel.text = history.amountText
        typeLabel.text = history.typeText
        
        amountLabel.textColor = history.isExpense ? .systemRed : .systemGreen
    }
}
