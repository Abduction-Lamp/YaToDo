//
//  TaskViewController.swift
//  YaToDo
//
//  Created by Владимир on 21.11.2022.
//

import UIKit

class TaskViewController: UIViewController {
    
    private var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.clipsToBounds = true
        textView.backgroundColor = .white
        textView.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        textView.textAlignment = .justified
        textView.layer.cornerRadius = 10
        
        textView.textColor = .lightGray
        textView.text = NSLocalizedString("TaskView.TextView.Placeholder", comment: "Placeholder")
        return textView
    }()
    
    
    override func loadView() {
        super.loadView()
        buildUI()
        configureUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        configureNavigationController()
        configureConstraints()
    }
}


extension TaskViewController {
    
    private func buildUI() {
        view.addSubview(textView)
    }
    
    
    private func configureUI() {
        textView.delegate = self
    }
    
    
    private func configureConstraints() {
        
        NSLayoutConstraint.activate([
            textView.widthAnchor.constraint(equalToConstant: view.bounds.width - Design.shared.padding.medium * 2),
            textView.heightAnchor.constraint(equalToConstant: Design.shared.screen.quarter),
            textView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Design.shared.padding.medium)
        ])
    }
    
    private func configureNavigationController() {
        title = NSLocalizedString("TaskView.Navigation.Title", comment: "Task")
        
        let cancelTitle = NSLocalizedString("TaskView.Navigation.CancelButton", comment: "Cancel")
        let saveTitle = NSLocalizedString("TaskView.Navigation.SaveButton", comment: "Save")
        
        let cancelButton = UIBarButtonItem(title: cancelTitle,
                                           style: .plain,
                                           target: self,
                                           action: #selector(cancelButtonClicked(_:)))
        let saveButton = UIBarButtonItem(title: saveTitle,
                                         style: .done,
                                         target: self,
                                         action: #selector(saveButtonClicked(_:)))

        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
        
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
}


extension TaskViewController {
    
    @objc
    func cancelButtonClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func saveButtonClicked(_ sender: UIBarButtonItem) {
        Swift.debugPrint("saveButtonClicked")
    }
}


extension TaskViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.textColor = .black
            textView.text = nil
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = .lightGray
            textView.text = NSLocalizedString("TaskView.TextView.Placeholder", comment: "Placeholder")
        }
    }
}
