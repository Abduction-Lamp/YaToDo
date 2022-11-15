//
//  ToDoItem.swift
//  YaToDo
//
//  Created by Владимир on 15.11.2022.
//

import Foundation

struct ToDoItem {
    let id: String
    let text: String
    let priority: Priority
    let date: Date
    let deadline: Date?

    
    init(id: String = UUID.init().uuidString,
         text: String,
         priority: Priority = .normal,
         date: Date? = nil,
         deadline: Date? = nil
    ) {
        self.date = date ?? Date(timeIntervalSince1970: Date.init().timeIntervalSince1970)
        self.id = id
        self.text = text
        self.priority = priority
        self.deadline = deadline
    }
}


extension ToDoItem {
    
    static func parse(_ json: Any) -> ToDoItem? {
        guard
            let jsonObj = json as? [String: Any],
            let id = jsonObj["id"] as? String,
            let text = jsonObj["text"] as? String,
            let date = jsonObj["date"] as? TimeInterval
        else { return  nil }
        
        var priority: Priority = .normal
        if let rawValuePriority = jsonObj["priority"] as? String {
            priority = Priority(rawValue: rawValuePriority) ?? .normal
        }

        var deadline: Date?
        if let deadlineUTC = jsonObj["deadline"] as? TimeInterval {
            deadline = Date(timeIntervalSince1970: deadlineUTC)
        }
        
        return ToDoItem(id: id, text: text, priority: priority, date: Date(timeIntervalSince1970: date), deadline: deadline)
    }
    
    static func parse(_ data: Data) -> ToDoItem? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            return ToDoItem.parse(json)
        } catch {
            return nil
        }
    }
    
    var json: Any {
        var jsonObj = [String: Any]()
        jsonObj["id"] = id
        jsonObj["text"] = text
        jsonObj["date"] = date.timeIntervalSince1970
        jsonObj["deadline"] = deadline?.timeIntervalSince1970
        if priority != .normal {
            jsonObj["priority"] = priority.rawValue
        }
        return jsonObj
    }
}
