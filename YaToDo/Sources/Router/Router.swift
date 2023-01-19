//
//  Router.swift
//  YaToDo
//
//  Created by Vladimir Lesnykh on 17.01.2023.
//

import UIKit

protocol Routable: AnyObject {
    
    var navigation: UINavigationController? { get }
    
    init(navigation: UINavigationController, builder: Buildable)
    
    func home()
    func popToRoot(animated: Bool)
    
    func task(_ item: ToDoItem?, callback: ((ToDoItem?) -> Void)?) -> UINavigationController
}


final class Router: Routable {
    
    var navigation: UINavigationController?
    private var builder: Buildable?
    
    init(navigation: UINavigationController, builder: Buildable) {
        self.navigation = navigation
        self.builder = builder
    }
    
    
    func home() {
        guard
            let navigation = navigation,
            let vc = builder?.makeHomeModule(router: self)
        else { return }
        
        navigation.viewControllers = [vc]
    }
    
    func task(_ item: ToDoItem? = nil, callback: ((ToDoItem?) -> Void)? = nil) -> UINavigationController {
        guard let vc = builder?.makeTaskModule(task: item, callback: callback) else {
            return UINavigationController()
        }
        return UINavigationController(rootViewController: vc)
    }
    
    func popToRoot(animated: Bool) {
        navigation?.popToRootViewController(animated: animated)
    }
}
