//
//  MMUserDefaultsSQLiteTests.swift
//  MMUserDefaultsSQLiteTests
//
//  Created by Mahendra Memane on 30/09/18.
//  Copyright © 2018 Mahendra Memane. All rights reserved.
//

import XCTest
@testable import MMUserDefaultsSQLite

struct Employee: Codable {
    let name:String
    let age: Int
}

extension Employee: Equatable {
    
    static func ==(lhs: Employee, rhs: Employee) -> Bool {
        return (lhs.name == rhs.name && lhs.age == rhs.age)
    }
}

class MMUserDefaultsSQLiteTests: XCTestCase {
    var standardUserDefaults: UserDefaults!
    var customUserDefaults:CustomUserDefaults!
    
    override func setUp() {
        super.setUp()
        
        standardUserDefaults = UserDefaults.standard
        customUserDefaults = CustomUserDefaults.standard
    }
    
    override func tearDown() {
        let bundleIdentifier = Bundle.main.bundleIdentifier!
        standardUserDefaults.removePersistentDomain(forName: bundleIdentifier)
        customUserDefaults.removeAllUserDefaults()

        super.tearDown()
    }
    
    func testSaveValueType() {
        let numberToSave = 5
        customUserDefaults.setValue(numberToSave, for: Key<Int>("number"))
        let numberThatSaved = customUserDefaults.value(for: Key<Int>("number"))!
        
        XCTAssert(numberToSave == numberThatSaved, "Failed to save correct value")
    }
    
    func testSaveCustomType() {
        let employeeToSave = Employee(name: "Mahendra", age: 26)
        customUserDefaults.setValue(employeeToSave, for: Key<Employee>("employee"))
        let employeeThatSaved = customUserDefaults.value(for: Key<Employee>("employee"))!
        
        XCTAssert(employeeToSave == employeeThatSaved, "Failed to save correct employee")
    }
    
    func testRemoveType() {
        let numberToSave = 5
        customUserDefaults.setValue(numberToSave, for: Key<Int>("number"))
        let numberThatSaved = customUserDefaults.value(for: Key<Int>("number"))!
        XCTAssert(numberToSave == numberThatSaved, "Failed to save correct value")
        
        customUserDefaults.removeUserDefault(for: Key<Int>("number"))
        let numberThatPresent = customUserDefaults.value(for: Key<Int>("number"))!
        XCTAssert(numberThatSaved != numberThatPresent, "Failed to remove value")
    }
    
    func testUpdateType() {
        let numberToSave = 5
        customUserDefaults.setValue(numberToSave, for: Key<Int>("number"))
        let numberThatSaved = customUserDefaults.value(for: Key<Int>("number"))!
        XCTAssert(numberToSave == numberThatSaved, "Failed to save correct value")
        
        let numberToUpdate = 10
        customUserDefaults.setValue(numberToUpdate, for: Key<Int>("number"))
        let numberThatUpdated = customUserDefaults.value(for: Key<Int>("number"))!
        XCTAssert(numberToUpdate == numberThatUpdated, "Failed to save correct value")
    }
    
    func testSaveArray() {
        let numbersToSave = [5, 4, 3, 2, 1]
        customUserDefaults.setArray(numbersToSave, for: Key<Int>("numbers"))
        let numbersThatSaved = customUserDefaults.array(for: Key<Int>("numbers"))!
        
        XCTAssert(numbersToSave == numbersThatSaved, "Failed to save correct value")
    }
    
    func testSaveDictionary() {
        let dictionaryToSave = ["fname": "Mahdendra", "lname" : "Memane"]
        customUserDefaults.setDictionary(dictionaryToSave, for: Key<String>("numbers"))
        let dictionaryToSaved = customUserDefaults.dictionary(for: Key<String>("numbers"))!
        
        XCTAssert(dictionaryToSave == dictionaryToSaved, "Failed to save correct value")
    }
    
    func testSuite() {
        let suiteUserDefaults = CustomUserDefaults(secretKey: "SecretSanta", suite: "Santa")
        let numberToSave = 5
        suiteUserDefaults.setValue(numberToSave, for: Key<Int>("number"))
        let numberThatSaved = suiteUserDefaults.value(for: Key<Int>("number"))!
        XCTAssert(numberToSave == numberThatSaved, "Failed to save correct value")
        
        //Try retrieving from shared
        let numberThatSavedInShared = customUserDefaults.value(for: Key<Int>("number"))!
        suiteUserDefaults.removeAllUserDefaults()
        XCTAssert(numberThatSaved != numberThatSavedInShared, "Failed to save in suite only")
    }

}
