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
    let deadline: Date?
    let creation: Date
    
    init(id: String = UUID.init().uuidString,
         text: String,
         priority: Priority = .normal,
         deadline: Date? = nil
    ) {
        let now = Date.init().timeIntervalSince1970
        creation = Date(timeIntervalSince1970: now)
        self.id = id
        self.text = text
        self.priority = priority
        self.deadline = deadline
    }
}


extension ToDoItem {
    
    static func parse(_ json: Any) -> ToDoItem? {
        
        return nil
    }
    
    static func parse(_ data: Data) -> ToDoItem? {
        
        return nil
    }
    
    var json: Any {
        var jsonObj = [String: Any]()
        jsonObj["id"] = id
        jsonObj["text"] = text
        jsonObj["creation"] = creation.timeIntervalSince1970
        jsonObj["deadline"] = deadline?.timeIntervalSince1970
        if priority != .normal {
            jsonObj["priority"] = priority.rawValue
        }
        return jsonObj
    }
}
