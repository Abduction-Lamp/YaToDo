//
//  TaskPresenter.swift
//  YaToDo
//
//  Created by Vladimir Lesnykh on 17.01.2023.
//

import Foundation

protocol TaskViewControllerProtocol: AnyObject {
    
    var presenter: TaskPresenterProtocol? { get set }
    
    func finish(animated flag: Bool, completion: (() -> Void)?)
}

protocol TaskPresenterProtocol: AnyObject {
    var task: ToDoItem? { get }
    
    init(_ viewController: TaskViewControllerProtocol, item: ToDoItem?, callback: ((ToDoItem?) -> Void)?)
    func save(text: String, priority: Priority, deadline: Date?)
    func remove()
}


final class TaskPresenter: TaskPresenterProtocol {
    
    private weak var vc: TaskViewControllerProtocol?
    var task: ToDoItem?
    
    private var callback: ((ToDoItem?) -> Void?)?
    
    
    init(_ viewController: TaskViewControllerProtocol, item: ToDoItem? = nil, callback: ((ToDoItem?) -> Void)?) {
        vc = viewController
        task = item
        self.callback = callback
    }
    
    func save(text: String, priority: Priority, deadline: Date?) {
        var id: String = UUID().uuidString
        var date: Date = Date()
        
        if let task = task {
            id = task.id
            date = task.date
        }
        let new = ToDoItem(id: id, text: text, priority: priority, date: date, deadline: deadline, completed: task?.completed)
        callback?(new)
        vc?.finish(animated: true, completion: nil)
    }
    
    func remove() {
        callback?(nil)
        vc?.finish(animated: true, completion: nil)
    }
}
