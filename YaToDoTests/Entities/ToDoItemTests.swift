//
//  ToDoItemTests.swift
//  ToDoItemTests
//
//  Created by Владимир on 14.11.2022.
//

import XCTest
@testable import YaToDo

class ToDoItemTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    
    func testJsonSimple() throws {
        let text = "String"
        let item = ToDoItem(text: text)
        XCTAssertEqual(item.text, text)
        XCTAssertEqual(item.priority, .normal)
        XCTAssertNil(item.deadline)
        XCTAssertNil(item.completed)
        
        let json = item.json as? [String: Any]
        XCTAssertNotNil(json)
        XCTAssertNotNil(json!["id"] as? String)
        XCTAssertEqual((json!["text"] as? String), text)
        XCTAssertNil(json!["priority"] as? String)
        XCTAssertNotNil(json!["date"] as? TimeInterval)
        XCTAssertNil(json!["deadline"] as? TimeInterval)
        XCTAssertNil(json!["completed"] as? TimeInterval)
    }
    
    func testJsonFull() throws {
        let id = "id"
        let text = "String"
        let date = Date()
        
        let item = ToDoItem(id: id, text: text, priority: .high, date: date, deadline: date, completed: date)
        XCTAssertEqual(item.id, id)
        XCTAssertEqual(item.text, text)
        XCTAssertEqual(item.priority, .high)
        XCTAssertEqual(item.date, date)
        XCTAssertEqual(item.deadline, date)
        XCTAssertEqual(item.completed, date)
        
        let json = item.json as? [String: Any]
        XCTAssertNotNil(json)
        XCTAssertEqual((json!["id"] as? String), id)
        XCTAssertEqual((json!["text"] as? String), text)
        XCTAssertEqual((json!["priority"] as? String), Priority.high.rawValue)
        XCTAssertEqual((json!["date"] as? TimeInterval), date.timeIntervalSince1970)
        XCTAssertEqual((json!["deadline"] as? TimeInterval), date.timeIntervalSince1970)
        XCTAssertEqual((json!["completed"] as? TimeInterval), date.timeIntervalSince1970)
    }
    
    func testParseByJson() throws {
        let id = "id"
        let text = "String"
        let date = Date()
        let deadline = Date()
        let completed = Date()
        
        let item = ToDoItem(id: id, text: text, priority: .high, date: date, deadline: deadline, completed: completed)
        let json = item.json
        
        let todoItem = ToDoItem.parse(json)
        XCTAssertEqual(item.id, todoItem?.id)
        XCTAssertEqual(item.text, todoItem?.text)
        XCTAssertEqual(item.priority, todoItem?.priority)
        XCTAssertEqual(item.date.timeIntervalSince1970, todoItem?.date.timeIntervalSince1970)
        XCTAssertEqual(item.deadline?.timeIntervalSince1970, todoItem?.deadline?.timeIntervalSince1970)
        XCTAssertEqual(item.completed?.timeIntervalSince1970, todoItem?.completed?.timeIntervalSince1970)
        
        XCTAssertEqual(item, todoItem)
    }
    
    func testParseByJson_Nil() throws {
        let todoItem = ToDoItem.parse("json")
        XCTAssertNil(todoItem)
    }
}
