//
//  AsyncOperation.swift
//  YaToDo
//
//  Created by Vladimir Lesnykh on 12.01.2023.
//

import Foundation

open class AsyncOperation: Operation {

    private var _isExecuting = false
    private var _isFinished = false

    open override func start() {
        guard !isCancelled else {
            finish()
            return
        }

        willChangeValue(forKey: "isExecuting")
        _isExecuting = true
        main()
        didChangeValue(forKey: "isExecuting")
    }

    open override func main() {
        // NOTE: should be overriden
        finish()
    }

    func finish() {
        willChangeValue(forKey: "isFinished")
        _isFinished = true
        didChangeValue(forKey: "isFinished")
    }

    open override var isAsynchronous: Bool {
        return true
    }

    open override var isExecuting: Bool {
        return _isExecuting
    }

    open override var isFinished: Bool {
        return _isFinished
    }
}
