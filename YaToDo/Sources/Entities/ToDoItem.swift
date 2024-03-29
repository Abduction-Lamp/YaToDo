//
//  ToDoItem.swift
//  YaToDo
//
//  Created by Владимир on 15.11.2022.
//
//
//  Яндекс Академия
//  Школа мобильной разработки 2021: iOS
//  https://www.youtube.com/watch?v=ik3Jw-GCzUY
//
//  1.    Реализовать структуру(!) TodoItem
//  - Иммутабельная структура (все поля let)
//  - Содержит уникальный id, если не задан пользователем - генерируется (uuidString)
//  - Обязательное строковое поле text
//  - Содержит обязательное поле важность - enum - неважный, обычный, важный
//  - Содержит дедлайн, может быть не задан, если задан - дата
//
//  2.    Реализовать расширение TodoItem для работы с JSON
//  - Содержит функцию ststic func parse(json: Any)->TodoItem? - для разбора JSON
//  - Содержет вычислимое свойство var json: Any - для формирование JSON
//  - Не сохраняем в JSON важность, если она обычная
//  - Не сохраняем в JSON сложные объекты (Data перевести в UTC)
//  - Сохраняем в JSON deadline только если он задан
//  - Обязательно использовать JSONSerialization
//

import Foundation

struct ToDoItem {
    let id: String
    let text: String
    let priority: Priority
    let date: Date
    let deadline: Date?
    let completed: Date?

    init(id: String = UUID.init().uuidString,
         text: String,
         priority: Priority = .normal,
         date: Date = Date(),
         deadline: Date? = nil,
         completed: Date? = nil
    ) {
        self.date = date
        self.id = id
        self.text = text
        self.priority = priority
        self.deadline = deadline
        self.completed = completed
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
        if let timeDeadline = jsonObj["deadline"] as? TimeInterval {
            deadline = Date(timeIntervalSince1970: timeDeadline)
        }
        
        var completed: Date?
        if let dateCompleted = jsonObj["completed"] as? TimeInterval {
            completed = Date(timeIntervalSince1970: dateCompleted)
        }
        
        return ToDoItem(id: id,
                        text: text,
                        priority: priority,
                        date: Date(timeIntervalSince1970: date),
                        deadline: deadline,
                        completed: completed)
    }
    
    var json: Any {
        var jsonObj = [String: Any]()
        jsonObj["id"] = id
        jsonObj["text"] = text
        jsonObj["date"] = date.timeIntervalSince1970
        jsonObj["deadline"] = deadline?.timeIntervalSince1970
        jsonObj["completed"] = completed?.timeIntervalSince1970
        if priority != .normal {
            jsonObj["priority"] = priority.rawValue
        }
        return jsonObj
    }
}


extension ToDoItem: Equatable {
    
    static func == (lhs: ToDoItem, rhs: ToDoItem) -> Bool {
        return  lhs.id == rhs.id &&
                lhs.text == rhs.text &&
                lhs.priority == rhs.priority &&
                lhs.date == rhs.date &&
                lhs.deadline == rhs.deadline &&
                lhs.completed == rhs.completed
    }
}


extension ToDoItem: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


extension ToDoItem: CustomStringConvertible {
    
    var description: String {
        return  """
                id:\t\t\t\(id)
                text:\t\t\(text)
                priority:\t\(priority)
                date:\t\t\(date)
                deadline:\t\(deadline?.description ?? "-")
                completed:\t\(completed == nil ? "No" : "YES")
                
                """
    }
}
