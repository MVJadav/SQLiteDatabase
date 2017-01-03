//
//  Constant.swift
//  ContactList
//
//  Created by Mac33 on 29/12/16.
//  Copyright © JadavMehul. All rights reserved.
//

import Foundation
import UIKit

let appDelegate = UIApplication.shared.delegate as! AppDelegate

class Constant{
    
    class DatabaseParameter {
        ///MARK: - SqlLiteTable
        static let DBNameUser = "user"
    }
    class TableName{
        static let User = "userDetail"
    }
    class Query{
        static let SelectUser = "select * from \(Constant.TableName.User) ORDER BY fname ASC"
    }
}
