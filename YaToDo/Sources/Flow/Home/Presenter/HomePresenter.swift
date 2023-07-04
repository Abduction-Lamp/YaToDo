//
//  HomePresenter.swift
//  YaToDo
//
//  Created by Vladimir Lesnykh on 16.01.2023.
//

import UIKit


protocol HomeViewControllerDisplayable: AnyObject {
    
    var presenter: HomePresentable? { get set }
    
    func displa()
    func display(index: Int)
}


protocol HomePresentable: AnyObject {
    
    init(_ viewController: HomeViewControllerDisplayable, router: Routable, cache: Cacheable)
    
    var numberOfCompletedTask: Int { get }
    var isHideCompletedTasks: Bool { set get }
    
    func numberOfSections() -> Int
    func numberOfRowsInSection() -> Int
    
    func getTaskItem(forRowAt indexPath: IndexPath) -> ToDoItem?
    func changeTaskCompletionStatus(forRowAt indexPath: IndexPath)
    func removeTask(forRowAt indexPath: IndexPath)
    
    func isCompleted(forRowAt indexPath: IndexPath) -> Bool
    
    func showNewTask() -> UINavigationController
    func showTaskDetails(indexPath: IndexPath) -> UINavigationController
}



final class HomePresenter: HomePresentable {
    
    private weak var vc: HomeViewControllerDisplayable?
    private weak var router: Routable?
    private weak var list: Cacheable?   // Список задач пользователя
    
    var numberOfCompletedTask: Int = 0
    var isHideCompletedTasks = false
    
    
    init(_ viewController: HomeViewControllerDisplayable, router: Routable, cache: Cacheable) {
        vc = viewController
        self.router = router
        list = cache
        
        numberOfCompletedTask = getNumberOfCompletedTask()
        print(numberOfCompletedTask)
    }
}


extension HomePresenter {
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRowsInSection() -> Int {
        guard let list = list else { return 0 }
        return isHideCompletedTasks ? (list.cache.count - numberOfCompletedTask) : list.cache.count
    }
    
    func getTaskItem(forRowAt indexPath: IndexPath) -> ToDoItem? {
        guard
            let list = list,
            indexPath.row < numberOfRowsInSection()
        else { return nil }
        
        let task = isHideCompletedTasks ? (list.cache.filter { $0.completed == nil } [indexPath.row]) : list.cache[indexPath.row]
        return task
    }
    
    func changeTaskCompletionStatus(forRowAt indexPath: IndexPath) {
        guard let task = getTaskItem(forRowAt: indexPath) else { return }
        
        let new = ToDoItem(id: task.id,
                           text: task.text,
                           priority: task.priority,
                           date: task.date,
                           deadline: task.deadline,
                           completed: task.completed == nil ? Date() : nil)
        
        if let _ = list?.change(id: task.id, new: new) {
            numberOfCompletedTask = getNumberOfCompletedTask()
            vc?.displa()
        }
    }
    
    func removeTask(forRowAt indexPath: IndexPath) {
        guard let task = getTaskItem(forRowAt: indexPath) else { return }

        if let _ = list?.remove(id: task.id) {
            numberOfCompletedTask = getNumberOfCompletedTask()
            vc?.displa()
        }
    }
    
    func isCompleted(forRowAt indexPath: IndexPath) -> Bool {
        guard
            let list = list,
            indexPath.row < numberOfRowsInSection()
        else { return false }
        return list.cache[indexPath.row].completed == nil ? false : true
    }
    
    func hideCompletedTasks() {
        isHideCompletedTasks = !isHideCompletedTasks
        vc?.displa()
    }
}


extension HomePresenter {
    
    func showNewTask() -> UINavigationController {
        guard let router = router else { return UINavigationController() }
        return router.task(nil) { [weak self] new in
            if let self = self, let new = new, let list = self.list, list.add(new) {
                self.vc?.displa()
            }
        }
    }
    
    func showTaskDetails(indexPath: IndexPath) -> UINavigationController {
        guard
            let router = router,
            let list = list,
            indexPath.row < numberOfRowsInSection()
        else { return UINavigationController() }
        
        let item = list.cache[indexPath.row]
        return router.task(item) { [weak self] new in
            guard let self = self else { return }
            if let new = new {
                let _ = self.list?.change(id: item.id, new: new)
            } else {
                let _ = self.list?.remove(id: item.id)
            }
            self.vc?.displa()
        }
    }
}


extension HomePresenter {

    private func getNumberOfCompletedTask() -> Int {
        guard let list = list else { return 0 }
        return list.cache.filter { $0.completed != nil }.count
    }
}
