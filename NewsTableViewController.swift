//
//  NewsTableViewController.swift
//  Scoops
//
//  Created by Izabela on 4/3/16.
//  Copyright © 2016 Izabela. All rights reserved.
//



class NewsTableViewController: UITableViewController {
    var client : MSClient?
    var model : [AnyObject]?
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateModel()
        
        
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var rows = 0
        if model != nil {
            rows = (model?.count)!
        }
        return rows
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("news", forIndexPath: indexPath)
        cell.textLabel?.text = model![indexPath.row]["title"]as? String
        cell.detailTextLabel?.text = model![indexPath.row]["userName"]as? String
        
        // Configure the cell...
        
        return cell
    }
    
     func populateModel(){
        let table = client?.tableWithName("news")
        let usrlogin = loadUserAuth()
        let predicate = NSPredicate(format: "userId = '\(usrlogin!.usr)'", [])
        let query = MSQuery(table: table, predicate:predicate)
        //let query = MSQuery(table: table)
        //incluir predicados, constraints para filtrar o para limitar el numero de filas o delimitar el numero de columnas
        query.orderByAscending("__createdAt")
        query.selectFields = ["title", "photo", "userName"]
        query.readWithCompletion{(result:MSQueryResult?, error:NSError?) -> Void in
            if error == nil {
                self.model = result?.items
                self.tableView.reloadData()
            }
        }
     }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        guard let identifier = segue.identifier else{
            print("We do not have id")
            return
        }
        
        switch identifier{
        case "addNews":
            let nc = segue.destinationViewController as! NewViewController
            // desde aqui podemos pasar alguna property
            nc.client = client
            break
            
        default: break
            
        }
    }

}
