//
//  FileCacheTests.swift
//  YaToDoTests
//
//  Created by Владимир on 17.11.2022.
//

import XCTest
@testable import YaToDo

class FileCacheTests: XCTestCase {

    var cache: Cacheable!
    
    override func setUpWithError() throws {
        cache = FileCache()
        XCTAssertTrue(cache.removeAll())
        XCTAssertTrue(cache.cache.count == 0)
    }

    override func tearDownWithError() throws {
        cache = nil
    }

    func testInitFileCache() throws {
        XCTAssertNotNil(cache)
        XCTAssertEqual(cache.cache.count, 0)
    }
    
    func testCacheable() throws {
        let item1 = ToDoItem(text: "item 1")
        let item2 = ToDoItem(text: "item 2", priority: .high, deadline: Date())
        let item3 = ToDoItem(id: "item 3", text: "item 3", priority: .low, date: Date(), deadline: Date())
        
        // MARK: Добовление в кэш
        cache.add(item1)
        XCTAssertEqual(cache.cache.count, 1)
        cache.add(item2)
        XCTAssertEqual(cache.cache.count, 2)
        cache.add(item3)
        XCTAssertEqual(cache.cache.count, 3)
        
        // MARK: Добовление в кэш повторных элементов
        cache.add(item1)
        XCTAssertEqual(cache.cache.count, 3)
        cache.add(item2)
        XCTAssertEqual(cache.cache.count, 3)
        cache.add(item3)
        XCTAssertEqual(cache.cache.count, 3)
        
        for (index, item) in cache.cache.enumerated() {
            XCTAssertTrue((0..<3).contains(index))
            if index == 0 {
                XCTAssertEqual(item,            item1)
                XCTAssertEqual(item.id,         item1.id)
                XCTAssertEqual(item.text,       item1.text)
                XCTAssertEqual(item.priority,   item1.priority)
                XCTAssertEqual(item.date,       item1.date)
                XCTAssertEqual(item.deadline,   item1.deadline)
            }
            
            if index == 1 {
                XCTAssertEqual(item,            item2)
                XCTAssertEqual(item.id,         item2.id)
                XCTAssertEqual(item.text,       item2.text)
                XCTAssertEqual(item.priority,   item2.priority)
                XCTAssertEqual(item.date,       item2.date)
                XCTAssertEqual(item.deadline,   item2.deadline)
            }
            
            if index == 2 {
                XCTAssertEqual(item,            item3)
                XCTAssertEqual(item.id,         item3.id)
                XCTAssertEqual(item.text,       item3.text)
                XCTAssertEqual(item.priority,   item3.priority)
                XCTAssertEqual(item.date,       item3.date)
                XCTAssertEqual(item.deadline,   item3.deadline)
            }
        }
        
        // MARK: Удаление из кэша
        let deleted = cache.remove(id: item3.id)
        XCTAssertEqual(deleted,             item3)
        XCTAssertEqual(deleted?.id,         item3.id)
        XCTAssertEqual(deleted?.text,       item3.text)
        XCTAssertEqual(deleted?.priority,   item3.priority)
        XCTAssertEqual(deleted?.date,       item3.date)
        XCTAssertEqual(deleted?.deadline,   item3.deadline)
        XCTAssertEqual(cache.cache.count, 2)

        cache.add(item3)
        XCTAssertEqual(cache.cache.count, 3)
        
        // MARK: Удаление всех элементов из кэша
        XCTAssertTrue(cache.removeAll())
        XCTAssertEqual(cache.cache.count, 0)
    }
    
    func testFileCacheFetchData() throws {
        let item1 = ToDoItem(text: "item 1")
        let item2 = ToDoItem(text: "item 2", priority: .high, deadline: Date())
        let item3 = ToDoItem(id: "item 3", text: "item 3", priority: .low, date: Date(), deadline: Date())
        
        // MARK: Добовление в кэш
        cache.add(item1)
        cache.add(item2)
        cache.add(item3)
        XCTAssertEqual(cache.cache.count, 3)
        
        cache = nil
        cache = FileCache()
        XCTAssertEqual(cache.cache.count, 3)
        XCTAssertTrue(cache.cache.contains(item1))
        XCTAssertTrue(cache.cache.contains(item2))
        XCTAssertTrue(cache.cache.contains(item3))
    }
}
