//
//  Assembly.swift
//  YaToDo
//
//  Created by Vladimir Lesnykh on 17.01.2023.
//

import UIKit

protocol Buildable: AnyObject {
    
    init(cache: Cacheable)
    
    func makeHomeModule(router: Routable) -> UIViewController & HomeViewControllerProtocol
    func makeTaskModule(task: ToDoItem?, callback: ((ToDoItem?) -> Void)?) -> UIViewController & TaskViewControllerProtocol
}


final class Assembly: Buildable {
    
    private var cache: Cacheable
     
    init(cache: Cacheable) {
        self.cache = cache
    }
    
    func makeHomeModule(router: Routable) -> UIViewController & HomeViewControllerProtocol {
        let vc = HomeViewController()
        vc.presenter = HomePresenter(vc, router: router, cache: cache)
        return vc
    }
    
    func makeTaskModule(task: ToDoItem? = nil, callback: ((ToDoItem?) -> Void)? = nil) -> UIViewController & TaskViewControllerProtocol {
        let vc = TaskViewController()
        vc.presenter = TaskPresenter(vc, item: task, callback: callback)
        return vc
    }
}
