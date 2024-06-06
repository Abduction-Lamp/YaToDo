//
//  HomeViewController.swift
//  YaToDo
//
//  Created by Владимир on 21.11.2022.
//

import UIKit

class HomeViewController: UIViewController {
    
    private enum Section: Hashable {
        case main
    }
    
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
        homeView.table.dataSource = dataSource //self
        homeView.addTaskButton.addTarget(self, action: #selector(addTaskButtonClicked(_:)), for: .touchUpInside)
        
        updateDataSource(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    

    private lazy var dataSource = UITableViewDiffableDataSource<Section, String>(tableView: homeView.table) { tableView, indexPath, itemIdentifier in
        guard 
            let item = self.presenter?.getTaskItem(forRowAt: indexPath),
            let cell = tableView.dequeueReusableCell(withIdentifier: TaskInListCell.reuseIdentifier, for: indexPath) as? TaskInListCell
        else { return UITableViewCell() }
        
        cell.item = item
//        if let item = self.presenter?.getTaskItem(forRowAt: indexPath) {
//            cell.accessoryType = .disclosureIndicator
//            cell.contentConfiguration = self.makeContentConfiguration(for: item)
//        }
        return cell
    }
    
    private func updateDataSource(animated: Bool) {
        guard let items = presenter?.snapshot else { return }
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    private func reloadDataSource(animated: Bool) {
        guard let items = presenter?.snapshot else { return }
        var snapshot = dataSource.snapshot() //NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.reloadItems(items)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}



extension HomeViewController: HomeViewControllerDisplayable {
    
    func display(_ state: State) {
        switch state {
        case .reload: reloadDataSource(animated: true)
        case .update: updateDataSource(animated: true)
        }
    }
}


extension HomeViewController: UITableViewDelegate /*UITableViewDataSource*/ {

//    // MARK: - TableView Header
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        section == 0 ? TaskListHeader.height : 0
//    }
//    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 0 {
//            guard
//                let presenter = presenter,
//                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TaskListHeader.reuseIdentifier) as? TaskListHeader
//            else { return nil }
//            
//            let title: TaskListHeader.TitleButton = presenter.isHideCompletedTasks ? .show : .hide
//            header.setup(presenter.numberOfCompletedTask, title: title)
//            header.button.addTarget(self, action: #selector(tapShowHedenButton(_:)), for: .touchUpInside)
//            return header
//        }
//        return nil
//    }
    
//    
//    // MARK: - TableView Cell
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard
//            let item = presenter?.getTaskItem(forRowAt: indexPath),
//            let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)")
//        else { return UITableViewCell() }
//        
//        cell.accessoryType = .disclosureIndicator
//        cell.contentConfiguration = makeContentConfiguration(for: item)
//        return cell
//    }
//
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let presenter = presenter else { return nil }
        
        let checkSwipeAction = UIContextualAction(style: .normal, title: "") { (action, sourceView, completionHandler) in
            presenter.changeTaskCompletionStatus(forRowAt: indexPath)
            completionHandler(true)
        }
        if !presenter.isCompleted(forRowAt: indexPath) {
            checkSwipeAction.backgroundColor = .systemGreen
            checkSwipeAction.image = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.white)
        } else {
            checkSwipeAction.backgroundColor = .placeholderText
            checkSwipeAction.image = UIImage(systemName: "circle")?.withTintColor(.white)
        }
        return  UISwipeActionsConfiguration(actions: [checkSwipeAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let infoSwipeAction = UIContextualAction(style: .normal, title: "") { [weak self] (action, sourceView, completionHandler) in
            if let navigation = self?.presenter?.showTaskDetails(indexPath: indexPath) {
                self?.present(navigation, animated: true, completion: nil)
            }
        }
        infoSwipeAction.backgroundColor = .placeholderText
        infoSwipeAction.image = UIImage(systemName: "info.circle.fill")?.withTintColor(.white)
        
        let deleteSwipeAction = UIContextualAction(style: .normal, title: "") { [weak self] (action, sourceView, completionHandler) in
            let message = self?.presenter?.getTaskItem(forRowAt: indexPath)?.text
            self?.deletionWarningAlert(message: message) { _ in
                self?.presenter?.removeTask(forRowAt: indexPath)
            }
            completionHandler(true)
        }
        deleteSwipeAction.backgroundColor = .systemRed
        deleteSwipeAction.image = UIImage(systemName: "trash")?.withTintColor(.white)

        return  UISwipeActionsConfiguration(actions: [deleteSwipeAction, infoSwipeAction])
    }
}


// MARK: - Actions
extension HomeViewController {
    
    @objc
    func addTaskButtonClicked(_ sender: UIButton) {
        if let navigation = presenter?.showNewTask() {
            present(navigation, animated: true, completion: nil)
        }
    }
                
    @objc
    func tapShowHedenButton(_ sender: UIButton) {
        guard let presenter = presenter else { return }
        presenter.isHideCompletedTasks = !presenter.isHideCompletedTasks
//        display()
    }
                
    private func deletionWarningAlert(message: String?, handler: ((UIAlertAction) -> Void)?) {
        let title = NSLocalizedString("General.Alert.Titel.DeleteTask", comment: "Titel")
        let cancel = NSLocalizedString("General.Alert.Cancel", comment: "Cancel")
        let delete = NSLocalizedString("General.Alert.Delete", comment: "Delete")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: delete, style: .destructive, handler: handler))
        
        present(alert, animated: true, completion: nil)
    }
}
