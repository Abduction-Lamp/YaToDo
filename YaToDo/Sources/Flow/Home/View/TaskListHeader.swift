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
        button.setTitle("Показать", for: .normal)
        return button
    }()
    
    
    // MARK: Initialization
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        buildUI()
    }

    required init?(coder: NSCoder) {
        fatalError("📛 TaskListHeader init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        label.text = NSLocalizedString("HomeView.TaskList.Header", comment: "Completed") + "\u{2014} 0"
        super.prepareForReuse()
    }
}


extension TaskListHeader {
    
    private func buildUI() {
        backgroundColor = .clear
        
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
    }
    
    
    func setup(_ count: Int) {
        label.text = NSLocalizedString("HomeView.TaskList.Header", comment: "Completed") + "\u{2014} \(count)"
        count > 0 ? (button.isEnabled = true) : (button.isEnabled = false)
    }
}
