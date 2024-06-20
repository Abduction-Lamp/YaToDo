//
//  HomeViewController.swift
//  YaToDo
//
//  Created by Владимир on 21.11.2022.
//

import UIKit


enum UpgradeDisplayStrategy {
    case reload(animated: Bool)
    case update(animated: Bool)
}


protocol HomeViewControllerDisplayable: AnyObject {
    
    var presenter: HomePresentable? { get set }
    
    func display(_ state: UpgradeDisplayStrategy)
    func reloadHeader()
}



class HomeViewController: UIViewController {
        
    public var homeView: HomeView {
        guard let view = self.view as? HomeView else {
            return HomeView(frame: self.view.frame)
        }
        return view
    }
    
    var presenter: HomePresentable?

    
    
    override func loadView() {
        view = HomeView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("HomeView.Navigation.Title", comment: "My tasks")
        
        homeView.table.delegate = self
        homeView.table.dataSource = dataSource
        
        homeView.addTaskButton.addTarget(self, action: #selector(addTaskButtonAction(_:)), for: .touchUpInside)
        
        updateDataSource(animated: false)
        dataSource.defaultRowAnimation = .middle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    
    // MARK: Diffable Data Source
    private enum Section: Hashable {
        case main
    }
    
    private lazy var dataSource = UITableViewDiffableDataSource<Section, String>(tableView: homeView.table) { tableView, indexPath, itemIdentifier in
        guard
            let item = self.presenter?.getTaskItem(forRowAt: indexPath),
            let cell = tableView.dequeueReusableCell(withIdentifier: CellForTaskList.reuseIdentifier, for: indexPath) as? CellForTaskList
        else { return UITableViewCell() }
        
        cell.accessoryType = .disclosureIndicator
        cell.model = item
        return cell
    }

    private func updateDataSource(animated: Bool) {
        guard let items = presenter?.snapshot else { return }
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: animated)
        }
    }
    
    private func reloadDataSource(animated: Bool) {
        guard let items = presenter?.snapshot else { return }
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections([.main])
        snapshot.reloadItems(items)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: animated)
        }
    }
}


// MARK: - Displayable
//
extension HomeViewController: HomeViewControllerDisplayable {
    
    func display(_ state: UpgradeDisplayStrategy) {
        switch state {
        case .reload(let animated): reloadDataSource(animated: animated)
        case .update(let animated): updateDataSource(animated: animated)
        }
    }
    
    func reloadHeader() {
        guard 
            let model = presenter?.getHeaderItem(),
            let header = homeView.table.headerView(forSection: 0) as? HeaderForTaskList
        else { return }
        header.model = model
    }
    
    
    @objc
    func addTaskButtonAction(_ sender: UIButton) {
        if let navigation = presenter?.presentNewTaskVC() {
            present(navigation, animated: true, completion: nil)
        }
    }
                
    @objc
    func hideCompletedButtonAction(_ sender: UIButton) {
        guard let presenter = presenter else { return }
        presenter.changeModelState()
    }
}


// MARK: - TableView Delegate
//
extension HomeViewController: UITableViewDelegate {

    // MARK: TableView Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            guard
                let model = presenter?.getHeaderItem(),
                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderForTaskList.reuseIdentifier) as? HeaderForTaskList
            else { return nil }

            header.model = model
            header.hideCompletedButton.addTarget(self, action: #selector(hideCompletedButtonAction(_:)), for: .touchUpInside)
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let presenter = presenter else { return }
        let vc = presenter.presentTaskDetailsVC(indexPath: indexPath)
        present(vc, animated: true, completion: nil)
    }
    
    // MARK: Swipe Actions
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let presenter = presenter else { return nil }
        
        // MARK: Check Task
        let checkSwipeAction = UIContextualAction(style: .normal, title: "") { (action, sourceView, completionHandler) in
            presenter.changeTaskCompletionStatus(forRowAt: indexPath)
            completionHandler(true)
        }
        if presenter.getTaskItem(forRowAt: indexPath)?.completed == nil {
            checkSwipeAction.backgroundColor = .systemGreen
            checkSwipeAction.image = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.white)
        } else {
            checkSwipeAction.backgroundColor = .placeholderText
            checkSwipeAction.image = UIImage(systemName: "circle")?.withTintColor(.white)
        }
        return UISwipeActionsConfiguration(actions: [checkSwipeAction])
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let presenter = presenter else { return nil }
        
        // MARK: Present Details Task
        let infoSwipeAction = UIContextualAction(style: .normal, title: "") { (action, sourceView, completionHandler) in
            let vc = presenter.presentTaskDetailsVC(indexPath: indexPath)
            self.present(vc, animated: true, completion: nil)
            completionHandler(true)
        }
        infoSwipeAction.backgroundColor = .placeholderText
        infoSwipeAction.image = UIImage(systemName: "info.circle.fill")?.withTintColor(.white)
        
        // MARK: Delete Task
        let deleteSwipeAction = UIContextualAction(style: .normal, title: "") { (action, sourceView, completionHandler) in
            let message = self.presenter?.getTaskItem(forRowAt: indexPath)?.text
            self.deletionWarningAlert(message: message) { _ in
                self.presenter?.removeTask(forRowAt: indexPath)
            }
            completionHandler(true)
        }
        deleteSwipeAction.backgroundColor = .systemRed
        deleteSwipeAction.image = UIImage(systemName: "trash")?.withTintColor(.white)

        return UISwipeActionsConfiguration(actions: [deleteSwipeAction, infoSwipeAction])
    }
    
    private func deletionWarningAlert(message: String?, handler: ((UIAlertAction) -> Void)?) {
        let title  = NSLocalizedString("General.Alert.Titel.DeleteTask", comment: "Titel")
        let cancel = NSLocalizedString("General.Alert.Cancel", comment: "Cancel")
        let delete = NSLocalizedString("General.Alert.Delete", comment: "Delete")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: delete, style: .destructive, handler: handler))
        
        present(alert, animated: true, completion: nil)
    }
}
