//
//  Utils.swift
//  Scoops
//
//  Created by Izabela on 4/3/16.
//  Copyright © 2016 Izabela. All rights reserved.
//

import Foundation

func saveAuthInfo (currentUser : MSUser?){    
    NSUserDefaults.standardUserDefaults().setObject(currentUser?.userId, forKey: "userId")
    NSUserDefaults.standardUserDefaults().setObject(currentUser?.mobileServiceAuthenticationToken, forKey: "tokenId")
    
}


func loadUserAuth() -> (usr : String, tok : String)? {
    
    let user = NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String
    let token = NSUserDefaults.standardUserDefaults().objectForKey("tokenId") as? String
    
    return (user!, token!)
}

func isUserLoged() -> Bool {
    var result = false
    let userID = NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String
    if let _ = userID {
        result = true
    }
    return result
    
}
