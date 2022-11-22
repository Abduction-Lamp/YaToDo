//
//  HomeViewController.swift
//  YaToDo
//
//  Created by Владимир on 21.11.2022.
//

import UIKit

class HomeViewController: UIViewController {
    
    public var homeView: HomeView {
        guard let view = self.view as? HomeView else {
            return HomeView(frame: self.view.frame)
        }
        return view
    }
    
    override func loadView() {
        super.loadView()
        view = HomeView(frame: view.frame)
        homeView.addTaskButton.addTarget(self, action: #selector(addTaskButtonClicked(_:)), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}


extension HomeViewController {
    
    @objc
    func addTaskButtonClicked(_ sender: UIButton) {
        let navigation = UINavigationController(rootViewController: TaskViewController())
        present(navigation, animated: true, completion: nil)
    }
}
