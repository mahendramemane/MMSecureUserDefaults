import UIKit
import SwiftyJSON

class UserDefaultDBHelper: BaseDBHelper {

    fileprivate struct UserDefautTable {
        static let tableName = "UserDefaults"
        static let schema = " ("
            + UserDefautTable.Columns.key + " TEXT PRIMARY KEY, "
            + UserDefautTable.Columns.value + " BLOB"
            + ") "

        struct Columns {
            static let key = "key"
            static let value = "value"
        }
        
        struct Queries {
            static let loadUserDefaultByKey = "SELECT * FROM " + UserDefautTable.tableName + " WHERE " + UserDefautTable.Columns.key + " = ?"
            
            static let createQuery = "CREATE TABLE IF NOT EXISTS " + UserDefautTable.tableName + UserDefautTable.schema
        }
    }
    
    init(withDBHelper dbHelper: FMDBHelper, withFile file:String, secretKey:String) {
        super.init(withDBHelper: dbHelper)
        dbHelper.initializeDBQueue(withFile: file, secretKey: secretKey)
        createTable()
    }
    
    func createTable() {
        let _ = self.dbHelper.executeUpdate(UserDefautTable.Queries.createQuery, withValues: nil)
    }
    
    func saveUserDefault(forKey key:String, value:Any) -> Bool {
        let values:[String:Any] = [
            UserDefautTable.Columns.key: key,
            UserDefautTable.Columns.value: value
        ]
        
        var success =  self.dbHelper.insert(intoTable: UserDefautTable.tableName, values: values)
        if !success {
            let whereClause = "\(UserDefautTable.Columns.key) = ?"
            let whereValues = [key]
            success = self.dbHelper.update(table: UserDefautTable.tableName, set: values, whereClause:whereClause, whereValues:whereValues)
        }
        
        return success
    }
    
    func loadUserDefault(forKey key:String) -> Any? {
        let results = self.dbHelper.executeQuery(UserDefautTable.Queries.loadUserDefaultByKey, withValues: [key])
        
        if let results = results {
            let first = results.arrayValue.first
            if let first = first {
                let value = first[UserDefautTable.Columns.value].rawValue
                return value
            }
        }
        return nil
    }
    
    func removeUserDefault(forKey key:String) -> Bool {
        let whereClause = "\(UserDefautTable.Columns.key) = ?"
        let whereValues = [key]
        let success = self.dbHelper.delete(fromtable: UserDefautTable.tableName, where: whereClause, whereValues: whereValues)
        return success
    }
    
    func removeAllUserDefaults() -> Bool {
        let success = self.dbHelper.delete(fromtable: UserDefautTable.tableName, where: "1", whereValues: [])
        return success
    }
}
