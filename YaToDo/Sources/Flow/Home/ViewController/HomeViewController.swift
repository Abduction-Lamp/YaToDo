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
    
    
    var model: [ToDoItem] = [
        ToDoItem(text: "Купить вино", priority: .low, deadline: Date() + 30000),
        ToDoItem(text: "Купить вино Купить вин о Купить вино Купить вино Купить вино UITableViewHeaderFooterView is not supported. Use the background view configuration instead.", deadline: Date() + 30000),
        ToDoItem(text: "2", completed: Date()),
        ToDoItem(text: "Купить вино Купить вин о Купить вино Купить вино Купить вино UITableViewHeaderFooterView is not supported. Use the background view configuration instead.", deadline: Date() + 30000, completed: Date()),
        ToDoItem(text: "5066-553 22", priority: .high)
    ]
    
    
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


extension HomeViewController {
    
    @objc
    func addTaskButtonClicked(_ sender: UIButton) {
        let navigation = UINavigationController(rootViewController: TaskViewController())
        present(navigation, animated: true, completion: nil)
    }
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < model.count,
              let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)")
        else { return UITableViewCell() }
        cell.accessoryType = .disclosureIndicator
        cell.contentConfiguration = makeContentConfiguration(for: model[indexPath.row])
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

        let checkAction = UIContextualAction(style: .normal, title: "") { [weak self] (action, sourceView, completionHandler) in
            if let item = self?.model[indexPath.row] {
                let completedDate: Date? = (item.completed == nil) ? Date() : nil
                self?.model[indexPath.row] = ToDoItem(id: item.id,
                                                      text: item.text,
                                                      priority: item.priority,
                                                      date: item.date,
                                                      deadline: item.deadline,
                                                      completed: completedDate)
//            let cell = tableView.cellForRow(at: indexPath)
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            completionHandler(true)
        }
        
        checkAction.backgroundColor = .systemGreen
        checkAction.image = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.white)

        return  UISwipeActionsConfiguration(actions: [checkAction])
    }
}
 

extension HomeViewController {
    
    private func makeContentConfiguration(for item: ToDoItem) -> UIListContentConfiguration {
        let padding = Design.shared.padding
        var configuration = UIListContentConfiguration.subtitleCell()
        
        configuration.directionalLayoutMargins.top = padding.medium
        configuration.directionalLayoutMargins.bottom = padding.medium
        
        configuration.attributedText = getTextAttributedText(for: item)
        configuration.textProperties.numberOfLines = 3
        configuration.textToSecondaryTextVerticalPadding = padding.small
        
        configuration.secondaryAttributedText = getDeadlineAttributedText(for: item)
        configuration.secondaryTextProperties.numberOfLines = 1
        
        if item.completed == nil {
            configuration.image = UIImage(systemName: "circle")
            if item.priority == .high {
                configuration.imageProperties.tintColor = .systemRed
            } else {
                configuration.imageProperties.tintColor = .placeholderText
            }
        } else {
            configuration.image = UIImage(systemName: "checkmark.circle.fill")
            configuration.imageProperties.tintColor = .systemGreen
        }
        return configuration
    }
    
    private func getTextAttributedText(for item: ToDoItem) -> NSAttributedString? {
        var attributes: [NSAttributedString.Key: Any] = [:]
        if item.completed == nil {
            attributes[.foregroundColor] = UIColor.label
            attributes[.strikethroughStyle] = nil
        } else {
            attributes[.foregroundColor] = UIColor.placeholderText
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        }
        
        let text = NSAttributedString(string: item.text, attributes: attributes)
        return text
    }
    
    private func getDeadlineAttributedText(for item: ToDoItem) -> NSAttributedString? {
        guard let deadline = item.deadline else { return nil }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.placeholderText
        ]
        
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
}
