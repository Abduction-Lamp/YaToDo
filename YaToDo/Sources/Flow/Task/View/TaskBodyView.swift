//
//  TaskBodyView.swift
//  YaToDo
//
//  Created by Владимир on 23.11.2022.
//

import UIKit

class TaskBodyView: UIView {
    
    private(set) var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .secondarySystemGroupedBackground
        textView.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        textView.textAlignment = .natural
        textView.textColor = .placeholderText
        textView.text = NSLocalizedString("TaskView.TextView.Placeholder", comment: "Placeholder")
        return textView
    }()
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("📛 TaskBodyView init(coder:) has not been implemented")
    }
    

    private func configureUI() {
        clipsToBounds = true
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 10
        
        addSubview(textView)
        
        let padding = Design.shared.padding.small
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
    }
}
