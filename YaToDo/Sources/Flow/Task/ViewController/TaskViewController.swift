//
//  TaskViewController.swift
//  YaToDo
//
//  Created by Владимир on 21.11.2022.
//

import UIKit

class TaskViewController: UIViewController {
    
    private var bodyHeightConstraint = NSLayoutConstraint()
    private var body = TaskBodyView()
    
    private var conponentsHeightConstraint = NSLayoutConstraint()
    private var conponents = TaskComponentsView()

        
    override func loadView() {
        super.loadView()
        buildUI()
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
        body.translatesAutoresizingMaskIntoConstraints = false
        conponents.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(body)
        view.addSubview(conponents)
        
        body.textView.delegate = self
        conponents.toggle.addTarget(self, action: #selector(toggleSwitched(_:)), for: .valueChanged)
        conponents.calendar.addTarget(self, action: #selector(selectedDate(_:)), for: .valueChanged)
    }
    
    private func configureConstraints() {
        let padding = Design.shared.padding
        let width = view.bounds.width - padding.medium * 2
        let cellHeight = Design.shared.simpleСellHeight
                
        bodyHeightConstraint = body.heightAnchor.constraint(equalToConstant: Design.shared.screen.quarter)
        conponentsHeightConstraint = conponents.heightAnchor.constraint(equalToConstant: cellHeight * 2)
        
        NSLayoutConstraint.activate([
            bodyHeightConstraint,
            body.widthAnchor.constraint(equalToConstant: width),
            body.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            body.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding.medium),
            
            conponentsHeightConstraint,
            conponents.widthAnchor.constraint(equalToConstant: width),
            conponents.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            conponents.topAnchor.constraint(equalTo: body.bottomAnchor, constant: padding.medium)
        ])
    }
    
    private func configureNavigationController() {
        title = NSLocalizedString("TaskView.Navigation.Title", comment: "Task")
        
        let cancelTitle = NSLocalizedString("TaskView.Navigation.CancelButton", comment: "Cancel")
        let saveTitle = NSLocalizedString("TaskView.Navigation.SaveButton", comment: "Save")
        
        let cancelButton = UIBarButtonItem(title: cancelTitle, style: .plain, target: self, action: #selector(cancelButtonClicked(_:)))
        let saveButton = UIBarButtonItem(title: saveTitle, style: .done, target: self, action: #selector(saveButtonClicked(_:)))

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
    
    @objc
    func toggleSwitched(_ sender: UISwitch) {
        if sender.isOn {
            let size = conponents.addCalendar()
            conponentsHeightConstraint.constant += size.height
            conponents.secondSeparator.isHidden = false
            conponents.deadlineInfoLabel.isHidden = false
            conponents.calendar.isHidden = false
        } else {
            conponentsHeightConstraint.constant = Design.shared.simpleСellHeight * 2
            conponents.secondSeparator.isHidden = true
            conponents.deadlineInfoLabel.isHidden = true
            conponents.removeCalendar()
        }
    }
    
    @objc
    func selectedDate(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy, HH:mm"
        let strDate = dateFormatter.string(from: sender.date)
        conponents.deadlineInfoLabel.text = strDate
    }
}


extension TaskViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.textColor = .label
            textView.text = nil
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = .placeholderText
            textView.text = NSLocalizedString("TaskView.TextView.Placeholder", comment: "Placeholder")
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
            
            let size = textView.intrinsicContentSize
            if bodyHeightConstraint.constant != size.height {
                if size.height > Design.shared.screen.quarter {
                    bodyHeightConstraint.constant = size.height
                    textView.layoutIfNeeded()
                } else if bodyHeightConstraint.constant != Design.shared.screen.quarter {
                    bodyHeightConstraint.constant = Design.shared.screen.quarter
                    textView.layoutIfNeeded()
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.phase == .began {
            body.textView.resignFirstResponder()
        }
    }
}
