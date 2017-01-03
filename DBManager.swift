//
//  DBManager.swift
//  ContactList
//
//  Created by Mac33 on 29/12/16.
//  Copyright © JadavMehul. All rights reserved.
//

import Foundation

var sharedInstance  : DBManager? = nil
var database        : OpaquePointer? = nil
var databasePath    : String!

class DBManager : NSObject{
    var isSuccess = true
    
    class func getSharedInstance() -> DBManager {
        if sharedInstance == nil {
            sharedInstance = DBManager()
            sharedInstance!.createDB()
        }
        return sharedInstance!
    }
    
    func createDB() -> Bool {
        var docsDir     : String
        var dirPaths    : [Any]
        // Get the documents directory
        dirPaths    = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        docsDir     = dirPaths[0] as! String
        print("Directory Path: ",docsDir)
        // Build the path to the database file
        databasePath = String(URL(fileURLWithPath: docsDir).appendingPathComponent("\(Constant.DatabaseParameter.DBNameUser).db").absoluteString)
        //BOOL isSuccess = YES;
        let filemgr = FileManager.default
        
        if filemgr.fileExists(atPath: databasePath) == false {
            
            let dbpath = databasePath
            //let data = string.data(using: String.Encoding.utf8)!
            if sqlite3_open(dbpath, &database) == SQLITE_OK {
                //var errMsg: CChar!
                var errMsg:UnsafeMutablePointer<Int8>? = nil
                let sql_stmt = "create table if not exists \(Constant.TableName.User) (userid integer primary key, fname text,lname text, company text, home text, phone text,mobile text, email text,address text, image text, ringtone text, birthday text, note text)"
                if sqlite3_exec(database, sql_stmt, nil, nil, &errMsg) != SQLITE_OK {
                    isSuccess = false
                    print("Failed to create table")
                }
                sqlite3_close(database)
                return isSuccess
            }
            else {
                isSuccess = false
                print("Failed to open/create database")
            }
        }
        return isSuccess
    }
    
    func saveNewUser(objContact: ContactModel) -> Bool {
        
        let fname       : String    = objContact.FirstName!
        let lname       : String    = objContact.LastName!
        let company     : String    = ""
        let home        : String    = ""
        let phone       : String    = objContact.PhoneNumber!
        let mobile      : String    = objContact.MobileNumber!
        let email       : String    = ""
        let address     : String    = ""
        let image       : String    = objContact.Image!
        let ringtone    : String    = ""
        let birthday    : String    = ""
        let note        : String    = ""
        
        var statement: OpaquePointer? = nil
        let dbpath = databasePath
        var success: Bool
        if sqlite3_open(dbpath, &database) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                // Read the data from the result row
            }
            // Release the compiled statement from memory
            sqlite3_finalize(statement)
        }
        let insertSQL = "insert into \(Constant.TableName.User) (fname,lname,company,home,phone,mobile,email,address,image,ringtone,birthday,note) values(\"\(fname)\",\"\(lname)\", \"\(company)\", \"\(home)\",\"\(phone)\",\"\(mobile)\",\"\(email)\", \"\(address)\", \"\(image)\",\"\(ringtone)\",\"\(birthday)\",\"\(note)\")"
        let insert_stmt = insertSQL
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, nil)
        if sqlite3_step(statement) == SQLITE_DONE {
            success = true
        }
        else {
            success = false
        }
        sqlite3_finalize(statement)
        return success
        
    }
    
    func editUser(objContact: ContactModel) -> Bool {

        let userId      : String    = objContact.UserID!
        let fname       : String    = objContact.FirstName!
        let lname       : String    = objContact.LastName!
        let company     : String    = ""
        let home        : String    = ""
        let phone       : String    = objContact.PhoneNumber!
        let mobile      : String    = objContact.MobileNumber!
        let email       : String    = ""
        let address     : String    = ""
        let image       : String    = objContact.Image!
        let ringtone    : String    = ""
        let birthday    : String    = ""
        let note        : String    = ""
        
        var statement: OpaquePointer? = nil
        let dbpath = databasePath
        var success: Bool
        if sqlite3_open(dbpath, &database) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                // Read the data from the result row
            }
            // Release the compiled statement from memory
            sqlite3_finalize(statement)
        }
        let insertSQL = "update \(Constant.TableName.User) set fname = '\(fname)',lname = '\(lname)',company = '\(company)',home = '\(home)',phone = '\(phone)',mobile = '\(mobile)',email = '\(email)',address = '\(address)',image = '\(image)',ringtone = '\(ringtone)',birthday = '\(birthday)',note = '\(note)' where userid = \(userId) "

        let insert_stmt = insertSQL
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, nil)
        if sqlite3_step(statement) == SQLITE_DONE {
            success = true
        }
        else {
            success = false
        }
        sqlite3_finalize(statement)
        return success
    }
    
    func selectAllUsers(strQuery: String) -> NSMutableArray {
        
        var statement: OpaquePointer?   = nil
        let dbpath                      = databasePath
        let arrayList: NSMutableArray   = NSMutableArray()
        
        if sqlite3_open(dbpath, &database) == SQLITE_OK {
            let querySQL = strQuery
            let query_stmt = querySQL
            if sqlite3_prepare_v2(database, query_stmt, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    var i: CInt = 0;
                    var iColumnCount:CInt = 0
                    iColumnCount = sqlite3_column_count(statement)
                    let dict: NSMutableDictionary = NSMutableDictionary()
                    while i < iColumnCount {
                        let str = sqlite3_column_text(statement, i)
                        let strFieldName = String(cString:sqlite3_column_name(statement, i), encoding:String.Encoding.utf8)
                        dict.setValue(String(cString: str!), forKey: strFieldName!);
                        i += 1;
                    }
                    arrayList.add(dict);
                }
                sqlite3_finalize(statement);
            }
        }
        sqlite3_close(database);
        return arrayList;
    }
    
    func deleteUser(_ userid: String) -> Bool {
        
        let dbpath = databasePath
        var statement: OpaquePointer? = nil
        var success: Bool
        let insertSQL = "Delete from \(Constant.TableName.User) where userid = \(userid)"
        let update_stmt = insertSQL
        if (sqlite3_open(dbpath, &database) == SQLITE_OK){
            sqlite3_prepare_v2(database, update_stmt, -1, &statement, nil)
            if sqlite3_step(statement) == SQLITE_DONE {
                success = true
            }
            else {
                success = false
            }
        }else{
            success = false
        }
        return success
    }
}
