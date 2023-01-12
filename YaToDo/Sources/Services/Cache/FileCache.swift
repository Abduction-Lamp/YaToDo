//
//  FileCache.swift
//  YaToDo
//
//  Created by Владимир on 15.11.2022.
//
//
//
//  Яндекс Академия
//  Школа мобильной разработки 2021: iOS
//
//  02. Swift как язык программирования
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
//
//
//  Яндекс Академия
//  Школа мобильной разработки 2021: iOS
//
//  06. Concurrency
//  https://www.youtube.com/watch?v=PLaR0U493ws&t=2936s
//
//  Операции, которые мы не ходти делать в главном потоке:
//  1.  Ходить в сеть
//  2.  Парсить/сериализовать, запросы/ответы
//  3.  Сохранять/загружать данные
//  4.  На главном потоке мы хотим применять полученные результаты и передавать на обработку запросы
//
//  Можно использовать GCD и/или Operations
//
//      Eсли вы хотите использовать GCD:
//      - В точке вызова (как правило ViewController'ы) не должно быть видно GCD'ных сущностей
//      - Старайтесь избегать большой вложенности callback'os
//
//      Если вы хотите использовать Operations
//      - Делайте операции, которые делают одну задачу (зонтики тоже делают одну задачу - координируют)
//      - Используйте адаптеры
//      - Для изменения UI тоже используйте операции (тут можно BlockOperations)
//      - Там где это надо - используйте AsyncOperation
//

import Foundation

protocol Cacheable {
    var cache: [ToDoItem] { get }
    
    func add(_ item: ToDoItem)
    func remove(id: String) -> ToDoItem?
    func removeAll() -> Bool
}

enum FileCacheError: Error, CustomStringConvertible {
    case createDirectory(Error)
    case getDirectory(Error)
    case getFiles(Error)
    case readFile(Error)
    case writeFile(Error)
    case removeFile(Error)
    case removeAllFile(Error)
    
    var description: String {
        var mesage = "⚠️ "
        switch self {
        case let .createDirectory(error):  mesage += "error create directory: \(error.localizedDescription)"
        case let .getDirectory(error):     mesage += "error get directory: \(error.localizedDescription)"
        case let .getFiles(error):         mesage += "error get files: \(error.localizedDescription)"
        case let .readFile(error):         mesage += "error read file: \(error.localizedDescription)"
        case let .writeFile(error):        mesage += "error write file: \(error.localizedDescription)"
        case let .removeFile(error):       mesage += "error remove file: \(error.localizedDescription)"
        case let .removeAllFile(error):    mesage += "error remove all files: \(error.localizedDescription)"
        }
        return mesage
    }
}


final class FileCache: Cacheable {
    
    private var root: URL? = nil
    private(set) var cache: [ToDoItem] = []
    
    
    init() {
        root = getRootDir()
        fetch()
    }
    
    
    func add(_ item: ToDoItem) {
        if !cache.contains(item) {
            cache.append(item)
            let _ = write(item)
        }
    }
    
    func remove(id: String) -> ToDoItem? {
        if let index = cache.firstIndex(where: { $0.id == id }) {
            let item = cache.remove(at: index)
            let _ = delete(item)
            return item
        }
        return nil
    }
    
    func removeAll() -> Bool {
        var result = false
        if deleteAll() {
            cache.removeAll()
            result = true
        }
        return result
    }
}


extension FileCache {
    
    private func createDirectory(at path: URL, named: String) -> Result<URL, FileCacheError> {
        let dir = path.appendingPathComponent(named)
        if !FileManager.default.fileExists(atPath: dir.path) {
            do {
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                let err: FileCacheError = .createDirectory(error)
                print(err)
                return .failure(err)
            }
        }
        return .success(dir)
    }
    
    private func getRootDir() -> URL? {
        var dir: URL
        do {
            dir = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            switch createDirectory(at: dir, named: AppKeys.shared.homeDirectory) {
            case let .success(url): dir = url
            case let .failure(error): throw error
            }
        } catch {
            print(FileCacheError.getDirectory(error))
            return nil
        }
        return dir
    }
    
    private func getFiles() -> [URL] {
        var contents: [URL] = []
        if let dir = root,
           AppKeys.shared.homeDirectory == FileManager.default.displayName(atPath: dir.path) {
            do {
                contents = try FileManager.default.contentsOfDirectory(at: dir,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            } catch {
                print(FileCacheError.getFiles(error))
            }
        }
        return contents
    }
    
    private func fetch() {
        for file in getFiles() {
            guard
                let resourceValues = try? file.resourceValues(forKeys: [.isDirectoryKey]),
                let isDirectory = resourceValues.isDirectory,
                !isDirectory
            else { continue }
            do {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                if let item = ToDoItem.parse(json) {
                    cache.append(item)
                }
            } catch {
                print(FileCacheError.readFile(error))
                continue
            }
        }
    }
    
    private func write(_ item: ToDoItem) -> Bool {
        var result = false
        if var dir = root,
           AppKeys.shared.homeDirectory == FileManager.default.displayName(atPath: dir.path) {
            dir.appendPathComponent(item.id)
            do {
                let data = try JSONSerialization.data(withJSONObject: item.json, options: [])
                result = FileManager.default.createFile(atPath: dir.path, contents: data, attributes: nil)
            } catch {
                print(FileCacheError.writeFile(error))
            }
        }
        return result
    }
    
    private func delete(_ item: ToDoItem) -> Bool {
        var result = false
        if var dir = root,
           AppKeys.shared.homeDirectory == FileManager.default.displayName(atPath: dir.path) {
            dir.appendPathComponent(item.id)
            do {
                try FileManager.default.removeItem(at: dir)
                result = true
            } catch {
                print(FileCacheError.removeFile(error))
            }
        }
        return result
    }
    
    private func deleteAll() -> Bool {
        var result = false
        if let dir = root,
           AppKeys.shared.homeDirectory == FileManager.default.displayName(atPath: dir.path) {
            do {
                try FileManager.default.removeItem(at: dir)
                root = getRootDir()
                result = (root != nil)
            } catch {
                print(FileCacheError.removeAllFile(error))
            }
        }
        return result
    }
}
