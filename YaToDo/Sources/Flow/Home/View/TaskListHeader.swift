//
//  TaskListHeader.swift
//  YaToDo
//
//  Created by Владимир on 07.12.2022.
//

import UIKit

final class TaskListHeader: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = "TaskListHeader"
    
    static var height: CGFloat {
        return Design.shared.simpleСellHeight
    }
    
    private var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .placeholderText
        label.font = .systemFont(ofSize: UIFont.systemFontSize)
        return label
    }()
    
   
    private(set) var button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .boldSystemFont(ofSize: UIFont.systemFontSize)
        return button
    }()
    
    
    // MARK: Initialization
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        buildUI()
    }

    required init?(coder: NSCoder) {
        fatalError("⚠️ TaskListHeader init(coder:) has not been implemented")
    }

//    override func prepareForReuse() {
//        label.text = NSLocalizedString("HomeView.TaskList.Header.CompletedTitle", comment: "Completed") + "\u{2014}"
//        super.prepareForReuse()
//    }
}


extension TaskListHeader {
    
    private func buildUI() {
        contentView.addSubview(label)
        contentView.addSubview(button)
        configureConstraints()
    }
    
    private func configureConstraints() {
        let padding = Design.shared.padding
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding.small),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding.medium),
            label.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -padding.medium),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding.small),
            
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding.small),
            button.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: padding.medium),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding.medium),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding.small)
        ])
        
        button.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    
    func setup(_ count: Int) {
        label.text = NSLocalizedString("HomeView.TaskList.Header.CompletedTitle", comment: "Completed") + "\u{2014} \(count)"
        count > 0 ? (button.isEnabled = true) : (button.isEnabled = false)
        let showTitle = NSLocalizedString("HomeView.TaskList.Header.Button.Show", comment: "Show")
        let hideTitle = NSLocalizedString("HomeView.TaskList.Header.Button.Hide", comment: "Hide")
    
        count > 0 ? button.setTitle(hideTitle, for: .normal) : button.setTitle(showTitle, for: .normal)
    }
}
