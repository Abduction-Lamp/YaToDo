//
//  FileCache.swift
//  YaToDo
//
//  Created by Владимир on 15.11.2022.
//
//
//  Яндекс Академия
//  Школа мобильной разработки 2021: iOS
//  https://www.youtube.com/watch?v=ik3Jw-GCzUY
//
//  3.    Реализовать класс FileCache
//      - Содержит закрытую для внешнего изменения, но открытую для получения коллекции TodoItem
//      - Содержит функцию добовления новой задачи
//      - Содержит функцию удаления задачи (на основе id)
//      - Содержит функцию загрузки всех дел из файла
//      - Может иметь несколько разных файлов
//
//  4.    Реализовать сохранение и загрузку FileCache в файл и из файла
//

import Foundation

protocol Cacheable {
    var cache: [ToDoItem] { get }
    
    func add(_ item: ToDoItem)
    func remove(id: String) -> ToDoItem?
}


class FileCache: Cacheable {
    
    private(set) var cache: [ToDoItem] = []
    
    func add(_ item: ToDoItem) {
        if !cache.contains(item) {
            cache.append(item)
        }
    }
    
    func remove(id: String) -> ToDoItem? {
        if let index = cache.firstIndex(where: { $0.id == id }) {
            return cache.remove(at: index)
        }
        return nil
    }
}
