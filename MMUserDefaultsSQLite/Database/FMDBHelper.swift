import UIKit
import FMDB
import SwiftyJSON


class FMDBHelper: NSObject {
    var secretKey:String!
    var databasePath:String!
    var dbQueue: FMDatabaseQueue!
    
    override init()  {
       
    }
    
    func initializeDBQueue(withFile file:String, secretKey:String) {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentDirDatabasePath = documentDirectoryPath.appending("/\(file)")
        self.databasePath = documentDirDatabasePath
        self.secretKey = secretKey
        self.dbQueue = FMDatabaseQueue(path: self.databasePath)
    }
    
    func executeQuery(_ query: String, withValues whereValues:[Any]? = nil) -> JSON? {
        var resultJson:JSON? = nil
        self.dbQueue.inDatabase { (database) in
            let resultSet = self.executeQuery(query: query, onDatabase: database, withValues: whereValues)
            resultJson = self.json(fromResultSet: resultSet)
            if let resultSet = resultSet {
                resultSet.close()
            }
        }
        return resultJson
    }
    
    func executeUpdate(_ sql: String, withValues values:[Any]? = nil) -> Bool {
        var success: Bool = false
        self.dbQueue.inDatabase { (database) in
            success = self.executeUpdate(onDatabase: database, withStatement: sql, values: values)
        }
        return success
    }
    
    func create(table tableName: String, withSchema schema:String) -> Bool {
        let createStatement = "CREATE TABLE if not exists ? ?;"
        var success: Bool = false
        self.dbQueue.inDatabase { (database) in
            success = self.executeUpdate(onDatabase: database, withStatement: createStatement, values: [tableName, schema])
        }
        return success
    }
    
    func drop(table tableName: String) -> Bool {
        let dropStatement = "DROP TABLE if exists ? ;"
        var success: Bool = false
        self.dbQueue.inDatabase { (database) in
            success = self.executeUpdate(onDatabase: database, withStatement: dropStatement, values: [tableName])
        }
        return success
    }
    
    func truncate(table tableName:String) -> Bool {
        let truncateStatement = "DELETE FROM \(tableName);"
        var success: Bool = false
        self.dbQueue.inDatabase { (database) in
            success = self.executeUpdate(onDatabase: database, withStatement: truncateStatement, values: nil)
        }
        return success
    }
    
    func select(fromTable table:String, columns:[String]? = nil,
                whereClause: String? = nil, whereValues:[Any]? = nil,
                offset:Int = 0,limit:Int = 1) -> JSON? {
        var projection: String = "*"
        var whereStatement: String = ""
        
        if let columns = columns {
            projection = columns.joined(separator: ",")
        }
        if let whereClause = whereClause {
            whereStatement = whereClause
        }
        let query = String(format: "SELECT %@ from %@ WHERE %@ LIMIT %d OFFSET %d", projection, table, whereStatement, limit, offset)
        var resultJson:JSON? = nil
        self.dbQueue.inDatabase { (database) in
            let resultSet = self.executeQuery(query: query, onDatabase: database, withValues: whereValues)
            resultJson = self.json(fromResultSet: resultSet)
            if let resultSet = resultSet {
                resultSet.close()
            }
        }
        return resultJson
    }

    func insert(intoTable tableName: String, values:[String:Any]) -> Bool {
        var columnNames = [String]()
        var columnValues = [Any]()
        var columnValuePlaceholders = [String]()
        
        for pair in values {
            columnNames.append(pair.key)
            columnValuePlaceholders.append("?")
            columnValues.append(pair.value)
        }
        let columnsQuery =  columnNames.joined(separator: ",")
        let valuesQuery =  columnValuePlaceholders.joined(separator: ",")
        let sqlQuery = "INSERT into \(tableName) (\(columnsQuery)) VALUES (\(valuesQuery));"
        var success: Bool = false
        self.dbQueue.inDatabase { (database) in
            success = self.executeUpdate(onDatabase: database, withStatement: sqlQuery, values: columnValues)
        }
        return success
    }
    
    func update(table tableName:String, set values:[String:Any], whereClause:String? = nil, whereValues:[Any]? = nil) -> Bool {
        var columnNames = [String]()
        var columnValues = [Any]()
        
        for pair in values {
            columnNames.append("\(pair.key) = ?")
            columnValues.append(pair.value)
        }
        let updateString = columnNames.joined(separator: ",")
        var query: String
        if let whereClause = whereClause, let whereValues = whereValues {
            query = "UPDATE \(tableName) set \(updateString) WHERE \(whereClause)"
            columnValues.append(contentsOf: whereValues)
        } else {
            query = "UPDATE \(tableName) set \(updateString)"
        }
        var success: Bool = false
        self.dbQueue.inDatabase { (database) in
            success = self.executeUpdate(onDatabase: database, withStatement: query, values: columnValues)
        }
        return success
    }
    
    func delete(fromtable tableName: String, where whereClause:String, whereValues:[Any]) -> Bool {
        let deleteStatement = "DELETE FROM \(tableName) WHERE \(whereClause) ;"
        var success: Bool = false
        self.dbQueue.inDatabase { (database) in
            success = self.executeUpdate(onDatabase: database, withStatement: deleteStatement, values: whereValues)
        }
        return success
    }

    //MARK:- Transaction
    
    func beginTransaction() -> Bool {
        var success: Bool = false
        self.dbQueue.inDatabase { (database) in
            success = database.beginTransaction()
        }
        return success
    }
    
    func commitTransaction() -> Bool {
        var success: Bool = false
        self.dbQueue.inDatabase { (database) in
            success = database.commit()
        }
        return success
    }
    
    func rollback() -> Bool {
        var success: Bool = false
        self.dbQueue.inDatabase { (database) in
            success = database.rollback()
        }
        return success
    }
    
    func isInTransaction() -> Bool {
        var isInTransaction: Bool = false
        self.dbQueue.inDatabase { (database) in
            isInTransaction = database.isInTransaction
        }
        return isInTransaction
    }
    
    //MARK:- Helpers
    
    fileprivate func executeUpdate(onDatabase database:FMDatabase, withStatement statement:String, values: [Any]?) -> Bool {
        var success:Bool = false
        do {
            database.setKey(self.secretKey)
            try database.executeUpdate(statement, values:values)
            success = true
        }
        catch {
            print("Error in \(#function) with query: \(statement): \(error)")
        }
        return success
    }
    
    fileprivate func executeQuery(query:String, onDatabase database:FMDatabase, withValues values:[Any]?) -> FMResultSet? {
        var resultSet: FMResultSet? = nil
        do  {
            database.setKey(self.secretKey)
            resultSet = try database.executeQuery(query, values: values)
        }
        catch {
            print("Error in \(#function) with query: \(query), error : \(error)")
        }
        return resultSet
    }
    
    fileprivate func json(fromResultSet resultSet:FMResultSet?) -> JSON? {
        guard let resultSet = resultSet else {
            return nil
        }
        var rows = [[AnyHashable: Any?]]()
        while resultSet.next() {
            let row = resultSet.resultDictionary
            if let row = row {
                rows.append(row)
            }
        }
        return JSON(rows)
    }
    
}
