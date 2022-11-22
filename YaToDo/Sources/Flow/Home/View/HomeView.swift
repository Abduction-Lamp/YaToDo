//
//  HomeView.swift
//  YaToDo
//
//  Created by Владимир on 21.11.2022.
//

import UIKit

class HomeView: UIView {
    
    private let addTaskButtonSize = CGSize(width: 56, height: 56)
    
    lazy private(set) var addTaskButton: UIButton = {
        let image = UIImage(systemName: "plus")
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.layer.masksToBounds = false
        button.layer.cornerRadius = addTaskButtonSize.height/2
        button.layer.backgroundColor = UIColor.systemBlue.cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 3
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        return button
    }()
    
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("📛 HomeView init(coder:) has not been implemented")
    }
    
    private func buildUI() {
        backgroundColor = .white
        addSubview(addTaskButton)
        
        configureConstraints()
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            addTaskButton.widthAnchor.constraint(equalToConstant: addTaskButtonSize.width),
            addTaskButton.heightAnchor.constraint(equalToConstant: addTaskButtonSize.height),
            addTaskButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            addTaskButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -(addTaskButtonSize.height/2))
        ])
    }
}