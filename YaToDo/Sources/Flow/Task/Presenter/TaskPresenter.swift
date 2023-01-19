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
    func dismiss(_ item: ToDoItem?)
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
    
    func dismiss(_ item: ToDoItem? = nil) {
        task = item
        callback?(task)
        vc?.finish(animated: true, completion: nil)
    }
}
