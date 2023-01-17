//
//  Router.swift
//  YaToDo
//
//  Created by Vladimir Lesnykh on 17.01.2023.
//

import UIKit

protocol Routable {
    
    var navigation: UINavigationController? { get }
    var builder: ModuleBuildable? { get }
    
    init(navigation: UINavigationController, builder: ModuleBuildable)
    
    func home()
    func popToRoot(animated: Bool) 
}


final class Router: Routable {
    
    var navigation: UINavigationController?
    var builder: ModuleBuildable?
    
    init(navigation: UINavigationController, builder: ModuleBuildable) {
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
    
    func popToRoot(animated: Bool) {
        navigation?.popToRootViewController(animated: animated)
    }
}
