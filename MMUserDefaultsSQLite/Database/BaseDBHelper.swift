import UIKit

class BaseDBHelper: NSObject {
    
    var dbHelper: FMDBHelper
    
    init(withDBHelper dbHelper: FMDBHelper) {
        self.dbHelper = dbHelper
    }

    func beginTransaction() -> Bool {
        return self.dbHelper.beginTransaction()
    }
    
    func commitTransaction() -> Bool {
        return self.dbHelper.commitTransaction()
    }
    
    func rollback() -> Bool {
        return self.dbHelper.rollback()
    }
    
    func isInTransaction() -> Bool {
        return self.dbHelper.isInTransaction()
    }
    
}
