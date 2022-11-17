//
//  ViewController.swift
//  YaToDo
//
//  Created by Владимир on 14.11.2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        
        let file = FileCache()
        print(file.cache)
    }
}

