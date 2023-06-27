//
//  TaskComponentsView.swift
//  YaToDo
//
//  Created by Владимир on 23.11.2022.
//

import UIKit

class TaskComponentsView: UIView {
    
    private var priorityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        label.textColor = .label
        label.text = NSLocalizedString("TaskView.Label.Priority", comment: "Priority")
        return label
    }()
    
    private(set) var segment: UISegmentedControl = {
        let selectedTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.systemRed,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        ]
        
        let segment = UISegmentedControl()
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        segment.insertSegment(withTitle: "!", at: 0, animated: false)
        segment.insertSegment(withTitle: "!!", at: 1, animated: false)
        segment.insertSegment(withTitle: "!!!", at: 2, animated: false)
        segment.selectedSegmentIndex = 1
        return segment
    }()
    
    private var firstSeparator: UIView = {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .separator
        separator.isHidden = false
        return separator
    }()
    
    private var deadlineStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .leading
        stack.spacing = 0
        return stack
    }()
    
    private var deadlineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        label.textColor = .label
        label.text = NSLocalizedString("TaskView.Label.Deadline", comment: "Deadline")
        return label
    }()
    
    private(set) var deadlineInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)
        label.textColor = .systemBlue
        label.text = ""
        label.isHidden = true
        return label
    }()
    
    private(set) var toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.setOn(false, animated: false)
        return toggle
    }()
    
    private(set) var secondSeparator: UIView = {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .separator
        separator.isHidden = true
        return separator
    }()
    
    private(set) var calendar: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .inline
        datePicker.minimumDate = Date()
        datePicker.timeZone = .current
        datePicker.locale = .current
        datePicker.isHidden = true
        return datePicker
    }()
    

    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }

    required init?(coder: NSCoder) {
        fatalError("⚠️ TaskComponentsView init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureConstraints()
    }
}
   

extension TaskComponentsView {
    
    private func buildUI() {
        clipsToBounds = true
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 10
        
        addSubview(priorityLabel)
        addSubview(segment)
        
        deadlineStack.addArrangedSubview(deadlineLabel)
        deadlineStack.addArrangedSubview(deadlineInfoLabel)
        addSubview(deadlineStack)

        addSubview(toggle)
        
        addSubview(firstSeparator)
        addSubview(secondSeparator)
    }
    
    private func configureConstraints() {
        let padding = Design.shared.padding
        let heightСell = Design.shared.simpleСellHeight
        let heightSmallFont = Design.shared.fontHeight.small
        let heightLabelFont = Design.shared.fontHeight.label
        
        NSLayoutConstraint.activate([
            priorityLabel.topAnchor.constraint(equalTo: topAnchor),
            priorityLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding.medium),
            priorityLabel.trailingAnchor.constraint(equalTo: segment.leadingAnchor, constant: -padding.small),
            priorityLabel.heightAnchor.constraint(equalToConstant: heightСell),
            
            segment.leadingAnchor.constraint(equalTo: centerXAnchor),
            segment.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding.small),
            segment.centerYAnchor.constraint(equalTo: priorityLabel.centerYAnchor),
            segment.heightAnchor.constraint(equalToConstant: heightСell - 2 * padding.small),

            firstSeparator.topAnchor.constraint(equalTo: topAnchor, constant: heightСell),
            firstSeparator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding.medium),
            firstSeparator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding.small),
            firstSeparator.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
            
            toggle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding.small),
            toggle.centerYAnchor.constraint(equalTo: segment.centerYAnchor, constant: heightСell),
            
            deadlineStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding.medium),
            deadlineStack.trailingAnchor.constraint(equalTo: toggle.leadingAnchor, constant: -padding.small),
            deadlineStack.heightAnchor.constraint(equalToConstant: heightLabelFont + heightSmallFont),
            deadlineStack.centerYAnchor.constraint(equalTo: toggle.centerYAnchor),
            
            secondSeparator.topAnchor.constraint(equalTo: topAnchor, constant: heightСell * 2),
            secondSeparator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding.medium),
            secondSeparator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding.small),
            secondSeparator.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale)
        ])
    }
    
    func addCalendar() -> CGSize {
        let heightСell = Design.shared.simpleСellHeight
        let minimalWidthDatePicker: CGFloat = 280
        var width: CGFloat = minimalWidthDatePicker
        
        if bounds.width > (minimalWidthDatePicker + 2 * Design.shared.padding.small) {
            width = bounds.width - 2 * Design.shared.padding.small
        }
        
        addSubview(calendar)
        NSLayoutConstraint.activate([
            calendar.widthAnchor.constraint(equalToConstant: width),
            calendar.centerXAnchor.constraint(equalTo: centerXAnchor),
            calendar.topAnchor.constraint(equalTo: topAnchor, constant: heightСell * 2)
        ])
        layoutIfNeeded()
        
        let sizeFitting = CGSize(width: width, height: .zero)
        return calendar.systemLayoutSizeFitting(sizeFitting)
    }
    
    func removeCalendar() {
        calendar.isHidden = true
        calendar.removeFromSuperview()
    }
}
