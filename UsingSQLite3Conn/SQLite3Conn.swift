//
//  SQLite3Conn.swift
//  ContactList
//
//  Created by Mac33 on 29/12/16.
//  Copyright © JadavMehul. All rights reserved.
//

import Foundation


enum SQLite3Error : Error {
    case connectionError(String)
    case queryError(String)
    case valueError(String)
    case otherError(String)
}

//let sharedInstance = SQLite3Conn()

class SQLite3Conn : NSObject {
    
    
   
    var stmt    : OpaquePointer? = nil
    var db      : OpaquePointer? = nil
    var path    : String!
    
    public func CheckandCreateDatabse() {
        var needsSetup = false
        path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .last!.appendingPathComponent("contact.db").path
        print("Database Path : \(path)")
        if !FileManager.default.fileExists(atPath: path) {
            print("no database file. setup.")
            needsSetup = true
        }
        /*
         func sqlite3_open(_ filename: UnsafePointer<Int8>!, _ ppDb: UnsafeMutablePointer<OpaquePointer?>!) -> Int32
         */
        if sqlite3_open(path, &db) != SQLITE_OK {
            print("Error")
            //return nil
        }
        if needsSetup {
            let query = "CREATE TABLE IF NOT EXISTS \(Constant.TableName.Contact) ( user_id integer primary key autoincrement, FirstName TEXT, LastName TEXT, MobileNumber TEXT, PhoneNumber TEXT, Address TEXT, DOB text, Image TEXT );"
            do {
                try prepare(query: query){ () -> Void in
                    if sqlite3_step(stmt) != SQLITE_DONE {
                        throw SQLite3Error.valueError("Fail to create table")
                    }
                }
            } catch {
                print("Error")
                //return nil
            }
        }
    }
    deinit {
        if let db = db {
            sqlite3_close(db)
        }
    }
    
    func prepare<ResultType>(query: String, _ body: () throws -> ResultType) throws -> ResultType {
        /*
         func sqlite3_prepare_v2(
         _ db: OpaquePointer!,
         _ zSql: UnsafePointer<Int8>!,
         _ nByte: Int32,
         _ ppStmt: UnsafeMutablePointer<OpaquePointer?>!,
         _ pzTail: UnsafeMutablePointer<UnsafePointer<Int8>?>!
         ) -> Int32
         */
        
        guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK
            else { throw SQLite3Error.queryError("Fail to compile Query:\n\(query)")}
        defer {sqlite3_finalize(stmt)}
        let r = try body()
        return r
    }
    
    func DatabasePath() -> String {
        path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .last!.appendingPathComponent("contact.db").path
        return path
    }
}

extension SQLite3Conn {
    //MARK: Insertion Contact
    func insertContact(contactM: ContactModel) -> Bool {

        let query = "INSERT INTO \(Constant.TableName.Contact) (FirstName, LastName, MobileNumber, PhoneNumber, Address, DOB, Image) VALUES (?, ?, ?, ?, ?, ?, ?);"

        if (sqlite3_open(path, &db) == SQLITE_OK) {
            do {
                try prepare(query: query){ () -> Void in
                    guard sqlite3_bind_text(stmt, 1, contactM.FirstName, -1, nil) == SQLITE_OK else {throw SQLite3Error.valueError("can't bind text")}
                    guard sqlite3_bind_text(stmt, 2, contactM.LastName, -1, nil) == SQLITE_OK else {throw SQLite3Error.valueError("can't bind text")}
                    guard sqlite3_bind_text(stmt, 3, contactM.MobileNumber, -1, nil) == SQLITE_OK else {throw SQLite3Error.valueError("can't bind text")}
                    guard sqlite3_bind_text(stmt, 4, contactM.PhoneNumber, -1, nil) == SQLITE_OK else {throw SQLite3Error.valueError("can't bind text")}
                    guard sqlite3_bind_text(stmt, 5, contactM.Address, -1, nil) == SQLITE_OK else {throw SQLite3Error.valueError("can't bind text")}
                    guard sqlite3_bind_text(stmt, 6, contactM.DOB, -1, nil) == SQLITE_OK else {throw SQLite3Error.valueError("can't bind text")}
                    guard sqlite3_bind_text(stmt, 7, contactM.Image, -1, nil) == SQLITE_OK else {throw SQLite3Error.valueError("can't bind text")}

                    guard sqlite3_step(stmt) == SQLITE_DONE else {throw SQLite3Error.otherError("Fail to insert")}
                    print("ok")
                }
            } catch {
                print("fail")
            }
        
        }
        return true
        
        
        //Second
        
        var errMsg:UnsafeMutablePointer<Int8>? = nil
        path = DatabasePath()
        let dbpath = path.cString(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            stmt = nil
            let insertStatement: NSString = "INSERT INTO \(Constant.TableName.Contact) (FirstName, LastName, MobileNumber, PhoneNumber, Address, DOB, Image) VALUES ('\(contactM.FirstName!)', '\(contactM.LastName!)', '\(contactM.MobileNumber!)', '\(contactM.PhoneNumber!)', '\(contactM.Address!)', '\(contactM.DOB!)', '\(contactM.Image!)')" as NSString
            let cSql = insertStatement.cString(using: String.Encoding.utf8.rawValue)
            
            
            sqlite3_exec(db, cSql, nil, nil, &errMsg)
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
            
            sqlite3_reset(stmt);
            sqlite3_finalize(stmt)
            sqlite3_close(stmt)
            return true
        }
        return false
        
        //Third
        
        insert(contactM: contactM)
        return true
        
    }
    
    func insert(contactM: ContactModel) {
        
        //var insertStatement: OpaquePointer? = nil
        //var errMsg:UnsafeMutablePointer<Int8>? = nil
        path = DatabasePath()
        //var database: OpaquePointer? = nil
        //let dbpath = path.cString(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
//        let insertStatementString = "INSERT INTO Contact (Id, Name) VALUES (?, ?);"

        let insertStatementString = "INSERT INTO \(Constant.TableName.Contact) (FirstName, LastName, MobileNumber, PhoneNumber, Address, DOB, Image) VALUES (?, ?, ?, ?, ?, ?, ?)"
        if (sqlite3_open(path, &db) == SQLITE_OK) {
            
            if sqlite3_prepare_v2(db, insertStatementString, -1, &stmt, nil) == SQLITE_OK {
                //let id: Int32 = 1
                let name: NSString = "\(contactM.FirstName)" as NSString
                
                //            sqlite3_bind_int(insertStatement, 1, id)
                sqlite3_bind_text(stmt, 2, name.utf8String, -1, nil)
                
                
//                let insertStatement: NSString = "INSERT INTO \(lookUpParameter.Table!) (Key, Value) VALUES ('\(lookUpParameter.Key!)', '\(lookUpParameter.Value!)')"
//                
//                let cSql = insertStatement.cStringUsingEncoding(NSUTF8StringEncoding)
//                
//                sqlite3_exec(db, cSql, nil, nil, &errMsg);
                if sqlite3_step(stmt) == SQLITE_DONE {
                    print("Successfully inserted row.")
                } else {
                    print("Could not insert row.")
                }
            } else {
                print("INSERT statement could not be prepared.")
            }
            // 5
            sqlite3_finalize(stmt)
            sqlite3_close(stmt)
        }
        
    }
    
    /*
    func addContactData(_ contactM: ContactModel) -> Bool {
        sharedInstance.database!.open()
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO \(Constant.TableName.Contact) (FirstName, LastName, MobileNumber, PhoneNumber, Address, DOB, Image) VALUES (?, ?, ?, ?, ?, ?, ?)", withArgumentsIn: [contactM.FirstName, contactM.LastName,contactM.MobileNumber, contactM.PhoneNumber, contactM.Address,contactM.DOB, contactM.Image])
        sharedInstance.database!.close()
        return isInserted
    }
    */
    
    
    //MARK: Deletion Contact
    func deleteContact(user_id:String) -> Bool{
        
        var errMsg:UnsafeMutablePointer<Int8>? = nil
        path = DatabasePath()
        var database: OpaquePointer? = nil
        let dbpath = path.cString(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            stmt = nil
            let insertStatement: NSString = "DELETE FROM \(Constant.TableName.Contact) WHERE user_id = \(user_id);" as NSString
            let cSql = insertStatement.cString(using: String.Encoding.utf8.rawValue)
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
            sqlite3_exec(database, cSql, nil, nil, &errMsg);
            sqlite3_reset(stmt);
            sqlite3_finalize(stmt)
            sqlite3_close(stmt)
            return true
        }
        return false
    }
    
    //MARK: Update Contact
    func updateContact(contactM: ContactModel) -> Bool {

        var errMsg:UnsafeMutablePointer<Int8>? = nil
        path = DatabasePath()
        var database: OpaquePointer? = nil
        let dbpath = path.cString(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            stmt = nil
            let insertStatement: NSString = "UPDATE \(Constant.TableName.Contact) SET FirstName = '\(contactM.FirstName!)',LastName = '\(contactM.LastName!)',MobileNumber = '\(contactM.MobileNumber!)',PhoneNumber = '\(contactM.PhoneNumber!)',Address = '\(contactM.Address!)',DOB = '\(contactM.DOB!)',Image = '\(contactM.Image!)' WHERE user_id = \(contactM.UserID!);" as NSString
            let cSql = insertStatement.cString(using: String.Encoding.utf8.rawValue)
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Successfully update row.")
            } else {
                print("Could not update row.")
            }
            sqlite3_exec(database, cSql, nil, nil, &errMsg);
            sqlite3_reset(stmt);
            sqlite3_finalize(stmt)
            sqlite3_close(stmt)
            return true
        }
        return false
    }
    
    //MARK: Selection Contact
    func getContactList(strQuery: String) -> NSMutableArray{
        
        path = DatabasePath()
        let arrayList: NSMutableArray = NSMutableArray()
        var database: OpaquePointer? = nil
        let dbpath = path.cString(using: String.Encoding.utf8)
        
        var statement:OpaquePointer? = nil
        let cSql = strQuery.cString(using: String.Encoding.utf8)
        if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
            if (sqlite3_prepare_v2(database, cSql!, -1, &statement, nil) == SQLITE_OK) {
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    var i: CInt = 0;
                    var iColumnCount:CInt = 0
                    iColumnCount = sqlite3_column_count(statement)
                    let dict: NSMutableDictionary = NSMutableDictionary()
                    while i < iColumnCount {
                        let str = sqlite3_column_text(statement, i)
//                      let str = String(cString: name!)
//                      print("name = \(str)")
                        let strFieldName = String(cString:sqlite3_column_name(statement, i), encoding:String.Encoding.utf8)
                        dict.setValue(String(cString: str!), forKey: strFieldName!);
                        i += 1;
                    }
                    arrayList.add(dict);
                }
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(database);
        return arrayList;
    }
}
