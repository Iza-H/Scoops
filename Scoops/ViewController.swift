//
//  ViewController.swift
//  Scoops
//
//  Created by Izabela on 4/3/16.
//  Copyright © 2016 Izabela. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let client = MSClient(
        applicationURLString:"https://scoopsizabela.azure-mobile.net/",
        applicationKey:"ICBERVhSOXadedNRgCzUmMrJxbOgGO14"
    
    )


    @IBAction func logUser(sender: AnyObject) {
        if client.currentUser != nil {
            print ("Userlogged")
            
            if let usrlogin = loadUserAuth() {
                client.currentUser = MSUser (userId : usrlogin.usr)
                client.currentUser.mobileServiceAuthenticationToken = usrlogin.tok
                self.showNewsTable(sender)
                
            }
            
            
        } else {
            client.loginWithProvider("facebook", controller:self, animated: true, completion: {(user:MSUser?, error:NSError?) -> Void in
                if error != nil{
                    print("Error")
                }else {
                    //Si tenemos exito ->"facebook:CADENACONTOKEN
                    self.showNewsTable(sender)
                    saveAuthInfo(user);
                    
                }
                
            })
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="My news"
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func showNewsTable(sender: AnyObject){
        
        self.performSegueWithIdentifier("showContent", sender:sender)
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        guard let identifier = segue.identifier else{
            print("We do not have id")
            return
        }
        
        switch identifier{
        case "showContent":
            let nc = segue.destinationViewController as! NewsTableViewController
            // desde aqui podemos pasar alguna property
            nc.client = client
            break
        
        default: break
            
        }
    }


}

