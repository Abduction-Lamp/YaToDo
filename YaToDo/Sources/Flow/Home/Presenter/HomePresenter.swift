//
//  HomePresenter.swift
//  YaToDo
//
//  Created by Vladimir Lesnykh on 16.01.2023.
//

import Foundation

protocol HomeViewControllerProtocol: AnyObject {
    
    var presenter: HomePresenterProtocol? { get set }
    
    func update()
    func update(index: Int)
}

protocol HomePresenterProtocol: AnyObject {

    init(_ vc: HomeViewControllerProtocol, cache: Cacheable)
    
    func numberOfSections() -> Int
    func numberOfRowsInSection() -> Int
    
    func getTaskItem(forRowAt indexPath: IndexPath) -> ToDoItem?
    func changeTaskCompletionStatus(forRowAt indexPath: IndexPath)
    func removeTask(forRowAt indexPath: IndexPath)
    
    func isCompleted(forRowAt indexPath: IndexPath) -> Bool
}


final class HomePresenter: HomePresenterProtocol {
    
    private weak var vc: HomeViewControllerProtocol?
    
    private weak var list: Cacheable?   // Список задач пользователя
    
    
    init(_ viewController: HomeViewControllerProtocol, cache: Cacheable) {
        vc = viewController
        list = cache
    }
}


extension HomePresenter {
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRowsInSection() -> Int {
        guard let list = list else { return 0 }
        return list.cache.count
    }
    
    func getTaskItem(forRowAt indexPath: IndexPath) -> ToDoItem? {
        guard
            let list = list,
            indexPath.row < list.cache.count
        else { return nil }
        return list.cache[indexPath.row]
    }
    
    func changeTaskCompletionStatus(forRowAt indexPath: IndexPath) {
        guard
            let list = list,
            indexPath.row < list.cache.count
        else { return }
        
        let current = list.cache[indexPath.row]
        let new = ToDoItem(id: current.id,
                           text: current.text,
                           priority: current.priority,
                           date: current.date,
                           deadline: current.deadline,
                           completed: current.completed == nil ? Date() : nil)
        
        if let _ = list.change(id: current.id, new: new) {
            vc?.update()
        }
    }
    
    func removeTask(forRowAt indexPath: IndexPath) {
        guard
            let list = list,
            indexPath.row < list.cache.count
        else { return }

        if let _ = list.remove(id: list.cache[indexPath.row].id) {
            vc?.update()
        }
    }
    
    func isCompleted(forRowAt indexPath: IndexPath) -> Bool {
        guard
            let list = list,
            indexPath.row < list.cache.count
        else { return false }
        return list.cache[indexPath.row].completed == nil ? false : true
    }
}
