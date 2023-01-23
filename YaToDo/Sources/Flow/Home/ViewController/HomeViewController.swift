//
//  HomeViewController.swift
//  YaToDo
//
//  Created by Владимир on 21.11.2022.
//

import UIKit

class HomeViewController: UIViewController {
    
    public var homeView: HomeView {
        guard let view = self.view as? HomeView else {
            return HomeView(frame: self.view.frame)
        }
        return view
    }
    
    var presenter: HomePresenterProtocol?
    
    
    override func loadView() {
        view = HomeView()
        
        homeView.table.delegate = self
        homeView.table.dataSource = self
        
        homeView.addTaskButton.addTarget(self, action: #selector(addTaskButtonClicked(_:)), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("HomeView.Navigation.Title", comment: "My tasks")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
}


extension HomeViewController: HomeViewControllerProtocol {
    
    func update() {
        homeView.table.reloadData()
    }
    
    func update(index: Int) {
        homeView.table.reloadData()
    }
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let presenter = presenter else { return 1 }
        return presenter.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let presenter = presenter else { return 0 }
        return presenter.numberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = presenter?.getTaskItem(forRowAt: indexPath),
              let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)")
        else { return UITableViewCell() }

        cell.accessoryType = .disclosureIndicator
        cell.contentConfiguration = makeContentConfiguration(for: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? TaskListHeader.height : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            guard
                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TaskListHeader.reuseIdentifier) as? TaskListHeader
            else { return nil }
            header.setup(7)
            return header
        }
        return nil
    }
    
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
 

extension HomeViewController {
    
    private func makeContentConfiguration(for item: ToDoItem) -> UIListContentConfiguration{
        let padding = Design.shared.padding
        var content = UIListContentConfiguration.subtitleCell()
        
        content.directionalLayoutMargins.top = padding.medium
        content.directionalLayoutMargins.bottom = padding.medium
        
        content.attributedText = getTextAttributedString(for: item)
        content.textProperties.numberOfLines = 3
        content.textToSecondaryTextVerticalPadding = padding.small
        
        if item.completed == nil {
            content.secondaryAttributedText = getDeadlineAttributedString(for: item)
            content.secondaryTextProperties.numberOfLines = 1
            
            content.image = UIImage(systemName: "circle")
            if item.priority == .high {
                content.imageProperties.tintColor = .systemRed
            } else {
                content.imageProperties.tintColor = .placeholderText
            }
        } else {
            content.image = UIImage(systemName: "checkmark.circle.fill")
            content.imageProperties.tintColor = .systemGreen
        }
        return content
    }
    
    private func getTextAttributedString(for item: ToDoItem) -> NSAttributedString? {
        var attributes: [NSAttributedString.Key: Any] = [:]
        if item.completed == nil {
            attributes[.foregroundColor] = UIColor.label
            attributes[.strikethroughStyle] = NSUnderlineStyle.byWord.rawValue
        } else {
            attributes[.foregroundColor] = UIColor.placeholderText
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        }
        return NSAttributedString(string: item.text, attributes: attributes)
    }
    
    private func getDeadlineAttributedString(for item: ToDoItem) -> NSAttributedString? {
        guard let deadline = item.deadline else { return nil }
        
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.placeholderText]
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "calendar")?.withTintColor(.placeholderText)
        if let imageWidth = imageAttachment.image?.size.width,
           let imageHeight = imageAttachment.image?.size.height,
           let baselineOffset = imageAttachment.image?.baselineOffsetFromBottom {
            imageAttachment.bounds = CGRect(x: 0, y: -baselineOffset, width: imageWidth, height: imageHeight)
        }
        
        let imageToString = NSAttributedString(attachment: imageAttachment)
        let text = NSAttributedString(string: " " + deadline.toString(), attributes: attributes)
        
        let completeText = NSMutableAttributedString(string: "")
        completeText.append(imageToString)
        completeText.append(text)
        
        return completeText
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

extension HomeViewController {
    
    @objc
    func addTaskButtonClicked(_ sender: UIButton) {
        if let navigation = presenter?.showNewTask() {
            present(navigation, animated: true, completion: nil)
        }
    }
}
