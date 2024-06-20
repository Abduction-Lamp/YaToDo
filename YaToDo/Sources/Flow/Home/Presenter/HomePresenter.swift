//
//  HomePresenter.swift
//  YaToDo
//
//  Created by Vladimir Lesnykh on 16.01.2023.
//

import UIKit

protocol HomePresentable: AnyObject {
    
    init(_ viewController: HomeViewControllerDisplayable, router: Routable, cache: Cacheable)
    
    var snapshot: [String]? { get }
    
    func getHeaderItem() -> HeaderForTaskList.Model
    func getTaskItem(forRowAt indexPath: IndexPath) -> ToDoItem?
    func changeTaskCompletionStatus(forRowAt indexPath: IndexPath)
    func removeTask(forRowAt indexPath: IndexPath)
        
    func changeModelState()
    
    func presentNewTaskVC() -> UINavigationController
    func presentTaskDetailsVC(indexPath: IndexPath) -> UINavigationController
}


final class HomePresenter: HomePresentable {
    
    private weak var vc: HomeViewControllerDisplayable?
    private weak var router: Routable?
    private weak var list: Cacheable?
    
    private var state: CacheModelState = .all {
        didSet {
            vc?.display(.update(animated: true))
        }
    }
    
    init(_ viewController: HomeViewControllerDisplayable, router: Routable, cache: Cacheable) {
        self.vc = viewController
        self.router = router
        self.list = cache
    }
    

    var snapshot: [String]? {
        guard let list = list else { return nil }
        return list.get(state).map { $0.id }
    }
    
    func getHeaderItem() -> HeaderForTaskList.Model {
        HeaderForTaskList.Model(copmleted: list?.get(.completed).count ?? 0, state: state)
    }
    
    func getTaskItem(forRowAt indexPath: IndexPath) -> ToDoItem? {
        guard
            let tasks = list?.get(state),
            indexPath.row < tasks.count
        else { return nil }
        
        return tasks[indexPath.row]
    }
    
    func changeTaskCompletionStatus(forRowAt indexPath: IndexPath) {
        guard let task = getTaskItem(forRowAt: indexPath) else { return }
        
        let new = ToDoItem(id:        task.id,
                           text:      task.text,
                           priority:  task.priority,
                           date:      task.date,
                           deadline:  task.deadline,
                           completed: task.completed == nil ? Date() : nil)
        
        if let _ = list?.change(id: task.id, new: new) {
            vc?.display((state == .all) ? .reload(animated: false) : .update(animated: true))
        }
    }
    
    func removeTask(forRowAt indexPath: IndexPath) {
        guard let task = getTaskItem(forRowAt: indexPath) else { return }

        if let _ = list?.remove(id: task.id) {
            vc?.display(.update(animated: true))
        }
    }
    
    func changeModelState() {
        state.toggle()
        vc?.reloadHeader()
    }

    
    func presentNewTaskVC() -> UINavigationController {
        guard let router = router else { return UINavigationController() }
        
        return router.task(nil) { [weak self] new in
            if let self = self, let new = new, let list = self.list, list.add(new) {
                self.vc?.display(.update(animated: true))
            }
        }
    }
    
    func presentTaskDetailsVC(indexPath: IndexPath) -> UINavigationController {
        guard
            let router = router,
            let tasks = list?.get(state),
            indexPath.row < tasks.count
        else { return UINavigationController() }
        
        let item = tasks[indexPath.row]
        
        return router.task(item) { [weak self] new in
            guard let self = self else { return }
            if let new = new {
                let _ = self.list?.change(id: item.id, new: new)
                self.vc?.display(.reload(animated: false))
                return
            } else {
                let _ = self.list?.remove(id: item.id)
                self.vc?.display(.update(animated: true))
                return
            }
        }
    }
}
