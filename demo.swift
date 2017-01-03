//
//  demo.swift
//  ContactList
//
//  Created by Mac33 on 29/12/16.
//  Copyright © JadavMehul. All rights reserved.
//

import UIKit

class demo: NSObject {

    var serviceResponse = [ContactModel]()
    
    let objloginModel:ContactModel  = ContactModel()
    objloginModel.UserID            = serviceResponse.UserID
    objloginModel.FirstName         = txtFirstname.text
    objloginModel.LastName          = txtLastname.text
    objloginModel.Image             = imageName
    objloginModel.Address           = txtAddress.text
    objloginModel.MobileNumber      = txtMobile.text
    objloginModel.PhoneNumber       = txtPhone.text
    objloginModel.DOB               = txtDOB.text

    //For Insertion
    if(DBManager.getSharedInstance().saveNewUser(objContact: objloginModel)){ }
    //For Updation
    if(DBManager.getSharedInstance().editUser(objContact: objloginModel)){ }
    //For Selection
    setContactList()
    //For Deletion
    if(DBManager.getSharedInstance().deleteUser(user_id)){ }
    
    
    
    func setContactList(){
        //let string = SQLite3Conn().getContactList(strQuery: Constant.Query.SelectContact)
        let string = DBManager.getSharedInstance().selectAllUsers(strQuery: Constant.Query.SelectUser)
        let response = Mapper<ContactModel>().mapArray(JSONObject: string)
        serviceResponse = response!
        tblContact.reloadData()
    }


}
