//
//  HeaderForTaskList.swift
//  YaToDo
//
//  Created by Владимир on 07.12.2022.
//

import UIKit

final class HeaderForTaskList: UITableViewHeaderFooterView {

    private var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .placeholderText
        label.font = .systemFont(ofSize: UIFont.systemFontSize)
        return label
    }()
    
    private(set) var hideCompletedButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .boldSystemFont(ofSize: UIFont.systemFontSize)
        return button
    }()
    
    
    var model: Model? {
        didSet {
            let count = model?.copmletedCount ?? 0
            
            if count != oldValue?.copmletedCount {
                label.text = NSLocalizedString("HomeView.TaskList.Header.CompletedTitle", comment: "Completed") + "\u{2014} \(count)"
                count > 0 ? (hideCompletedButton.isEnabled = true) : (hideCompletedButton.isEnabled = false)
            }
            
            if model?.buttonState != oldValue?.buttonState {
                let title = model?.buttonState.title ?? Model.ButtonState.show.title
                UIView.transition(with: hideCompletedButton, duration: 0.2, options: [.transitionCrossDissolve]) {
                    self.hideCompletedButton.setTitle(title, for: .normal)
                }
            }
        }
    }

    
    // MARK: Initialization
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("\(Self.description()) init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        model = nil
    }

    
    // MARK: BuildUI
    private func buildUI() {
        contentView.addSubview(label)
        contentView.addSubview(hideCompletedButton)
        configureConstraints()
    }
    
    private func configureConstraints() {
        let padding = Design.shared.padding
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding.small),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding.medium),
            label.trailingAnchor.constraint(equalTo: hideCompletedButton.leadingAnchor, constant: -padding.medium),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding.small),
            
            hideCompletedButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding.small),
            hideCompletedButton.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: padding.medium),
            hideCompletedButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding.medium),
            hideCompletedButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding.small)
        ])
        
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        hideCompletedButton.setContentHuggingPriority(.required, for: .horizontal)
    }
}


extension HeaderForTaskList {
    
    struct Model: Equatable {
        
        enum ButtonState {
            case hide
            case show
            
            var title: String {
                switch self {
                case .hide: NSLocalizedString("HomeView.TaskList.Header.Button.Hide", comment: "Hide")
                case .show: NSLocalizedString("HomeView.TaskList.Header.Button.Show", comment: "Show")
                }
            }
        }
        
        let copmletedCount: Int
        let buttonState: ButtonState
        
        init(copmleted: Int, state: CacheModelState) {
            copmletedCount = copmleted
            switch state {
            case .all:
                buttonState = .hide
            default:
                buttonState = .show
            }
        }
        
        static func == (lhs: Model, rhs: Model) -> Bool {
            (lhs.copmletedCount == rhs.copmletedCount) && (lhs.buttonState == rhs.buttonState)
        }
    }
}
