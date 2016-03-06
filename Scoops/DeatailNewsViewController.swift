//
//  DeatailNewsViewController.swift
//  Scoops
//
//  Created by Izabela on 06/03/16.
//  Copyright © 2016 Izabela. All rights reserved.
//

import UIKit

class DeatailNewsViewController: UIViewController {
    
    var model : AnyObject?
    var client : MSClient?
    
    @IBOutlet weak var titleField: UITextField!


    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var pushSwitch: UISwitch!
    @IBOutlet weak var authorField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var newsField: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        titleField.text = model!["title"] as? String;
        authorField.text = model!["userName"] as? String;
        takeRestData()
    }
    
    func takeRestData(){
            let table = client?.tableWithName("news")
            //let usrlogin = loadUserAuth()
            let stringQuery = model!["id"]!
            let predicate = NSPredicate(format: "id = '\(stringQuery!)'", [])
            let query = MSQuery(table: table, predicate:predicate)
            query.readWithCompletion{(result:MSQueryResult?, error:NSError?) -> Void in
                if error == nil {
                    self.newsField.text=result?.items[0]["news"] as? String;
                    self.latitudeLabel.text = result?.items[0]["latitude"] as? String;
                    self.longitudeLabel.text = result?.items[0]["longitud"] as? String;
                    self.pushSwitch.setOn((result?.items[0]["published"] as? Bool)!, animated: false);
                    //self.model = result?.items
                    //self.tableView.reloadData()
                }
            }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
