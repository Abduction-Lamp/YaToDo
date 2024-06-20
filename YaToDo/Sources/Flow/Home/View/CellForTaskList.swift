//
//  CellForTaskList.swift
//  YaToDo
//
//  Created by Vladimir Lesnykh on 11.06.2024.
//

import UIKit

final class CellForTaskList: UITableViewCell {
    
    var model: ToDoItem?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        automaticallyUpdatesContentConfiguration = false
        automaticallyUpdatesBackgroundConfiguration = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("\(Self.description()): init(coder:) has not been implemented")
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        
        guard let model = model else { return }
        
        let padding = Design.shared.padding
        var configuration = defaultContentConfiguration().updated(for: state)
        
        configuration.directionalLayoutMargins.top = padding.medium
        configuration.directionalLayoutMargins.bottom = padding.medium
        
        configuration.attributedText = makeBodyAttributedString(for: model)
        configuration.textProperties.numberOfLines = 3
        configuration.textToSecondaryTextVerticalPadding = padding.small
        
        if model.completed == nil {
            configuration.secondaryAttributedText = makeDeadlineAttributedString(for: model)
            configuration.secondaryTextProperties.numberOfLines = 1
            configuration.image = UIImage(systemName: "circle")
            configuration.imageProperties.tintColor = (model.priority == .high) ? .systemRed : .placeholderText
        } else {
            configuration.image = UIImage(systemName: "checkmark.circle.fill")
            configuration.imageProperties.tintColor = .systemGreen
        }
        contentConfiguration = configuration
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        model = nil
    }
    
    
    
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
