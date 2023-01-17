//
//  AssemblyViewController.swift
//  YaToDo
//
//  Created by Vladimir Lesnykh on 17.01.2023.
//

import UIKit

protocol ModuleBuildable: AnyObject {
    func makeHomeModule(router: Routable) -> UIViewController & HomeViewControllerProtocol
}


final class AssemblyViewController: ModuleBuildable {
    
    let cache = FileCache()
     
    func makeHomeModule(router: Routable) -> UIViewController & HomeViewControllerProtocol {
        let vc = HomeViewController()
        let presenter = HomePresenter(vc, cache: cache)
        vc.presenter = presenter
        return vc
    }
}
