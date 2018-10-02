//
//  CustomUserDefaults.swift
//  CustomUserDefaultsDemo
//
//  Created by Mahendra Memane on 30/09/18.
//  Copyright © 2018 Mahendra Memane. All rights reserved.
//

import Foundation

public class DefaultsKey {
}

public final class Key<ValueType: Codable>: DefaultsKey {
    fileprivate let key: String
    public init(_ key: String) {
        self.key = key
    }
}

public class CustomUserDefaults : NSObject {
    
    //MARK:- Properties
    
    private var suiteName:String?
    private static let sharedDefaults = CustomUserDefaults(secretKey:"Magic")
    private let userDefaultDBHelper:UserDefaultDBHelper
    public class var standard: CustomUserDefaults {
        return CustomUserDefaults.sharedDefaults
    }

    //MARK:- Initialiser
    
    public init(secretKey:String, suite:String? = nil) {
        suiteName = suite
        let fileName = suiteName ?? Bundle.main.bundleIdentifier!
        userDefaultDBHelper = UserDefaultDBHelper(withDBHelper: FMDBHelper(),
                                                  withFile: "\(fileName).sqlite",
                                                    secretKey: secretKey)
        super.init()
    }
    
    //MARK:- Set
    
    public func setValue<ValueType>(_ value: ValueType, for key: Key<ValueType>) {
        if isSwiftCodableType(ValueType.self) || isFoundationCodableType(ValueType.self) {
            let _ = userDefaultDBHelper.saveUserDefault(forKey: key.key, value: value)
        } else {
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let encoded = try encoder.encode(value)
                let _ = userDefaultDBHelper.saveUserDefault(forKey: key.key, value: encoded)
            } catch {
                #if DEBUG
                    print(error)
                #endif
            }
        }
    }
    
    
    public func setArray<ValueType>(_ value: [ValueType], for key: Key<ValueType>) {
        do {
            //TODO: Refactor encoding repetative code
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let encoded = try encoder.encode(value)
            let _ = userDefaultDBHelper.saveUserDefault(forKey: key.key, value: encoded)
        } catch {
            #if DEBUG
                print(error)
            #endif
        }
    }
    
    public func setDictionary<ValueType>(_ value: [String: ValueType], for key: Key<ValueType>) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let encoded = try encoder.encode(value)
            let _ = userDefaultDBHelper.saveUserDefault(forKey: key.key, value: encoded)
        } catch {
            #if DEBUG
                print(error)
            #endif
        }
    }
    
    //MARK:- Get
    
    public func value<ValueType>(for typedKey:Key<ValueType>) -> ValueType? {
        let rawValue = userDefaultDBHelper.loadUserDefault(forKey: typedKey.key)
        if isSwiftCodableType(ValueType.self) || isFoundationCodableType(ValueType.self) {
            guard let rawValue = rawValue else {
                if let defaultValue = getDefaultValue(ValueType.self) {
                    return (defaultValue as! ValueType)
                }
                return nil
            }
            return  (rawValue as! ValueType)
        }
        
        guard let dataValue = rawValue else {
            return nil
        }
        
        let data = try! JSONSerialization.data(withJSONObject: dataValue, options: .prettyPrinted)
        
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(ValueType.self, from: data)
            return decoded
        } catch {
            #if DEBUG
                print(error)
            #endif
        }
        
        return nil
    }
    
    
    public func array<ValueType>(for typedKey:Key<ValueType>) -> [ValueType]? {
        let rawValue = userDefaultDBHelper.loadUserDefault(forKey: typedKey.key)
        guard let dataValue = rawValue else {
            return nil
        }
        
        let data = try! JSONSerialization.data(withJSONObject: dataValue, options: .prettyPrinted)
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode([ValueType].self, from: data)
            return decoded
        } catch {
            #if DEBUG
                print(error)
            #endif
        }
        
        return nil
    }
    
    public func dictionary<ValueType>(for typedKey:Key<ValueType>) -> [String: ValueType]? {
        let rawValue = userDefaultDBHelper.loadUserDefault(forKey: typedKey.key)
        
        guard let dataValue = rawValue else {
            return nil
        }
        
        let data = try! JSONSerialization.data(withJSONObject: dataValue, options: .prettyPrinted)
        
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode([String: ValueType].self, from: data)
            return decoded
        } catch {
            #if DEBUG
                print(error)
            #endif
        }
        
        return nil
    }
    
    //MARK:- Remove
    
    public func removeUserDefault<ValueType>(for typedKey:Key<ValueType>) {
        let _ = userDefaultDBHelper.removeUserDefault(forKey: typedKey.key)
    }
    
    public func removeAllUserDefaults() {
        let _ = userDefaultDBHelper.removeAllUserDefaults()
    }
    
    //MARK:- Private
    
    private func isSwiftCodableType<ValueType>(_ type: ValueType.Type) -> Bool {
        switch type {
        case is String.Type, is Bool.Type, is Int.Type, is Float.Type, is Double.Type:
            return true
        default:
            return false
        }
    }
    
    private func isFoundationCodableType<ValueType>(_ type: ValueType.Type) -> Bool {
        switch type {
        case is Date.Type:
            return true
        default:
            return false
        }
    }
    
    private func getDefaultValue<ValueType>(_ type: ValueType.Type) -> Any? {
        var result: Any?
        switch type {
        case is String.Type:
             result = ""
        case is Bool.Type:
            result = false
        case is Int.Type:
            result = 0
        case is Float.Type:
            result = 0.0 as Float
        case is Double.Type:
            result = 0.0
        default:
            result = nil
        }
        
        return result
    }
    
}
