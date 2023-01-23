//
//  HomePresenter.swift
//  YaToDo
//
//  Created by Vladimir Lesnykh on 16.01.2023.
//

import UIKit

protocol HomeViewControllerProtocol: AnyObject {
    
    var presenter: HomePresenterProtocol? { get set }
    
    func update()
    func update(index: Int)
}

protocol HomePresenterProtocol: AnyObject {
    
    init(_ viewController: HomeViewControllerProtocol, router: Routable, cache: Cacheable)
    
    func numberOfSections() -> Int
    func numberOfRowsInSection() -> Int
    
    func getTaskItem(forRowAt indexPath: IndexPath) -> ToDoItem?
    func changeTaskCompletionStatus(forRowAt indexPath: IndexPath)
    func removeTask(forRowAt indexPath: IndexPath)
    
    func isCompleted(forRowAt indexPath: IndexPath) -> Bool
    
    func showNewTask() -> UINavigationController
    func showTaskDetails(indexPath: IndexPath) -> UINavigationController
}



final class HomePresenter: HomePresenterProtocol {
    
    private weak var vc: HomeViewControllerProtocol?
    private weak var router: Routable?
    private weak var list: Cacheable?   // Список задач пользователя
    
    
    init(_ viewController: HomeViewControllerProtocol, router: Routable, cache: Cacheable) {
        vc = viewController
        self.router = router
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


extension HomePresenter {
    
    func showNewTask() -> UINavigationController {
        guard let router = router else { return UINavigationController() }
        return router.task(nil) { [weak self] new in
            if let self = self, let new = new, let list = self.list, list.add(new) {
                self.vc?.update()
            }
        }
    }
    
    func showTaskDetails(indexPath: IndexPath) -> UINavigationController {
        guard
            let router = router,
            let list = list,
            indexPath.row < list.cache.count
        else { return UINavigationController() }
        
        let item = list.cache[indexPath.row]
        return router.task(item) { [weak self] new in
            guard let self = self else { return }
            if let new = new {
                let _ = self.list?.change(id: item.id, new: new)
            } else {
                let _ = self.list?.remove(id: item.id)
            }
            self.vc?.update()
        }
    }
}
