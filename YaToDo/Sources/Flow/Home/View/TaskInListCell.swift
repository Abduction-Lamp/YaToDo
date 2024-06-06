//
//  TaskInListCell.swift
//  YaToDo
//
//  Created by Vladimir Lesnykh on 06.06.2024.
//

import UIKit

final class TaskInListCell: UITableViewCell {
    
    var item: ToDoItem?
    

    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        
        accessoryType = .disclosureIndicator
        
        guard let item = item else { return }
        
        let padding = Design.shared.padding
        var content = defaultContentConfiguration().updated(for: state)
        
        content.directionalLayoutMargins.top = padding.medium
        content.directionalLayoutMargins.bottom = padding.medium
        
        content.attributedText = makeBodyAttributedString(for: item)
        content.textProperties.numberOfLines = 3
        content.textToSecondaryTextVerticalPadding = padding.small
        
        if item.completed == nil {
            content.secondaryAttributedText = makeDeadlineAttributedString(for: item)
            content.secondaryTextProperties.numberOfLines = 1
            content.image = UIImage(systemName: "circle")
            content.imageProperties.tintColor = (item.priority == .high) ? .systemRed : .placeholderText
        } else {
            content.image = UIImage(systemName: "checkmark.circle.fill")
            content.imageProperties.tintColor = .systemGreen
        }
        contentConfiguration = content
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        item = nil
    }
}

extension TaskInListCell {
    
    private func makeBodyAttributedString(for item: ToDoItem) -> NSAttributedString? {
        var attributes: [NSAttributedString.Key: Any] = [:]
        if item.completed == nil {
            attributes[.foregroundColor] = UIColor.label
            attributes[.strikethroughStyle] = NSUnderlineStyle.byWord.rawValue
        } else {
            attributes[.foregroundColor] = UIColor.placeholderText
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        }
        return NSAttributedString(string: item.text, attributes: attributes)
    }
    
    private func makeDeadlineAttributedString(for item: ToDoItem) -> NSAttributedString? {
        guard let deadline = item.deadline else { return nil }
        
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.placeholderText]
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
