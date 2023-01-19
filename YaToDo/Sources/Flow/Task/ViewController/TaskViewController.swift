//
//  TaskViewController.swift
//  YaToDo
//
//  Created by Владимир on 21.11.2022.
//

import UIKit

class TaskViewController: UIViewController {

    private var scrollView = UIScrollView()
    private var contentSize: CGSize {
        let topPadding = Design.shared.padding.medium
        let subviewPadding = Design.shared.padding.medium
        let bottomPadding = Design.shared.padding.medium
        
        let width = self.view.bounds.width
        var height = topPadding + bodyHeightConstraint.constant
        height += subviewPadding + conponentsHeightConstraint.constant
        height += subviewPadding + Design.shared.simpleСellHeight + bottomPadding
        return CGSize(width: width, height: height)
    }
    
    private var bodyHeightConstraint = NSLayoutConstraint()
    private var body = TaskBodyView()

    private var conponentsHeightConstraint = NSLayoutConstraint()
    private var conponents = TaskComponentsView()
    
    private var removeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .secondarySystemGroupedBackground
        button.setTitleColor(.placeholderText, for: .highlighted)
        button.setTitleColor(.systemRed, for: .normal)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        let title = NSLocalizedString("TaskView.RemoveButton", comment: "Remove")
        button.setTitle(title, for: .normal)
        return button
    }()

    private var keyboardHideTapGesture = UITapGestureRecognizer()
    
    var presenter: TaskPresenterProtocol?
    
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if let task = presenter?.task {
            setup(item: task)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension TaskViewController {
    
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
    
    private func buildUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        body.translatesAutoresizingMaskIntoConstraints = false
        conponents.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(body)
        scrollView.addSubview(conponents)
        scrollView.addSubview(removeButton)
        
        body.textView.delegate = self
        
        conponents.toggle.addTarget(self, action: #selector(toggleSwitched(_:)), for: .valueChanged)
        conponents.calendar.addTarget(self, action: #selector(selectedDate(_:)), for: .valueChanged)
        removeButton.addTarget(self, action: #selector(removeButtonClicked(_:)), for: .touchUpInside)
        
        keyboardHideTapGesture.addTarget(self, action: #selector(keyboardHide(_:)))
        keyboardHideTapGesture.delegate = self
        scrollView.addGestureRecognizer(keyboardHideTapGesture)
    }
    
    private func configureConstraints() {
        let padding = Design.shared.padding
        let width = view.bounds.width - padding.medium * 2
        let cellHeight = Design.shared.simpleСellHeight

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        bodyHeightConstraint = body.heightAnchor.constraint(equalToConstant: Design.shared.screen.quarter)
        NSLayoutConstraint.activate([
            body.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: padding.medium),
            body.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            body.widthAnchor.constraint(equalToConstant: width),
            bodyHeightConstraint
        ])
        
        conponentsHeightConstraint = conponents.heightAnchor.constraint(equalToConstant: cellHeight * 2)
        NSLayoutConstraint.activate([
            conponents.topAnchor.constraint(equalTo: body.bottomAnchor, constant: padding.medium),
            conponents.centerXAnchor.constraint(equalTo: body.centerXAnchor),
            conponents.widthAnchor.constraint(equalToConstant: width),
            conponentsHeightConstraint
        ])
        
        NSLayoutConstraint.activate([
            removeButton.topAnchor.constraint(equalTo: conponents.bottomAnchor, constant: padding.medium),
            removeButton.centerXAnchor.constraint(equalTo: conponents.centerXAnchor),
            removeButton.widthAnchor.constraint(equalToConstant: width),
            removeButton.heightAnchor.constraint(equalToConstant: cellHeight)
        ])
        
        scrollView.contentSize = self.contentSize
    }
    
    private func setup(item: ToDoItem) {
        body.textView.text = item.text
        body.textView.textColor = .label
        
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        var priorityIndex = 1
        switch item.priority {
        case .low: priorityIndex = 0
        case .normal: priorityIndex = 1
        case .high: priorityIndex = 2
        }
        conponents.segment.selectedSegmentIndex = priorityIndex
        
        if let date = item.deadline {
            conponents.calendar.minimumDate = date
            conponents.calendar.date = date
            conponents.toggle.setOn(true, animated: true)
            toggleSwitched(conponents.toggle)
            selectedDate(conponents.calendar)
        }
    }
    
    private func buildToDoItem() -> ToDoItem? {
        let text = body.textView.text
        var priority: Priority = .normal
        switch conponents.segment.selectedSegmentIndex {
        case 0: priority = .low
        case 2: priority = .high
        default: break
        }
        var deadline: Date?
        if conponents.toggle.isOn {
            deadline = conponents.calendar.date
        }
        return ToDoItem(text: text ?? "", priority: priority, deadline: deadline)
    }
}


extension TaskViewController {

    @objc
    private func keyboardWillShow(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else { return }
        var contentInset: UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardRect.size.height
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    @objc
    private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    @objc
    private func keyboardHide(_ sender: UITapGestureRecognizer) {
        scrollView.endEditing(true)
    }

    @objc
    func cancelButtonClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @objc
    private func saveButtonClicked(_ sender: UIBarButtonItem) {
        let new = buildToDoItem()
        presenter?.dismiss(new)
    }
    
    @objc
    private func removeButtonClicked(_ sender: UIButton) {
        Swift.debugPrint("removeButtonClicked")
    }

    @objc
    private func toggleSwitched(_ sender: UISwitch) {
        if sender.isOn {
            let size = conponents.addCalendar()
            conponentsHeightConstraint.constant += size.height
            conponents.secondSeparator.isHidden = false
            conponents.deadlineInfoLabel.isHidden = false
            conponents.calendar.isHidden = false
            scrollView.contentSize = self.contentSize
        } else {
            conponentsHeightConstraint.constant = Design.shared.simpleСellHeight * 2
            conponents.secondSeparator.isHidden = true
            conponents.deadlineInfoLabel.isHidden = true
            conponents.removeCalendar()
            scrollView.contentSize = self.contentSize
        }
    }

    @objc
    private func selectedDate(_ sender: UIDatePicker) {
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
                    scrollView.contentSize = self.contentSize
                } else if bodyHeightConstraint.constant != Design.shared.screen.quarter {
                    bodyHeightConstraint.constant = Design.shared.screen.quarter
                    scrollView.contentSize = self.contentSize
                }
            }
        }
    }
}


extension TaskViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: conponents.calendar) == true {
            conponents.calendar.sendActions(for: .valueChanged)
            return false
        } else {
            return true
        }
    }
}


extension TaskViewController: TaskViewControllerProtocol {
    
    func finish(animated flag: Bool, completion: (() -> Void)? = nil) {
        
        // TODO: Показать анимацию
        dismiss(animated: flag, completion: completion)
    }
}
