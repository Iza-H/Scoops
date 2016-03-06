//
//  AllNewsPublishedTableViewController.swift
//  Scoops
//
//  Created by Izabela on 06/03/16.
//  Copyright © 2016 Izabela. All rights reserved.
//

import UIKit

class AllNewsPublishedTableViewController: UITableViewController {
    var client : MSClient?
    var model : [AnyObject]?

    override func viewDidLoad() {
        super.viewDidLoad()
        populateModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateModel(){
        let table = client?.tableWithName("news")
        let predicate = NSPredicate(format: "published = true", [])
        let query = MSQuery(table: table, predicate:predicate)
        query.orderByDescending("__createdAt")
        query.selectFields = ["title", "photo", "userName", "id"]
        query.readWithCompletion{(result:MSQueryResult?, error:NSError?) -> Void in
            if error == nil {
                self.model = result?.items
                self.tableView.reloadData()
            }
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
        let cell = tableView.dequeueReusableCellWithIdentifier("newsAll", forIndexPath: indexPath)
        cell.textLabel?.text = model![indexPath.row]["title"]as? String
        cell.detailTextLabel?.text = model![indexPath.row]["userName"]as? String
        cell.imageView!.image = UIImage(named: "img_not_avalaible.png")
        let photoName = model![indexPath.row]["photo"] as? String
        if (photoName != ""){
            downloadImage(photoName!, imageView :cell.imageView!, cell: cell)
        }
        
        
        return cell
    }
    
    
    func downloadImage(photoName: String, imageView :UIImageView, cell: AnyObject){
        
        var image : UIImage?
        let blobName = photoName
        let containerName = "photos"
        
        
        //check if saved in dhe caache:
        let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as String
        let strFilePath = cachePath.stringByAppendingString("/\(blobName)")
        
        let manager = NSFileManager.defaultManager()
        if (manager.fileExistsAtPath(strFilePath)) {
            //get it from cache
            let data = NSData(contentsOfFile: strFilePath)
            image = UIImage(data : data!)
            imageView.image = image
            
        }else{
            
            self.client?.invokeAPI("urlsastoblobandcontainer",
                body: nil,
                HTTPMethod: "GET",
                parameters: ["photoName" : blobName, "ContainerName" : containerName],
                headers: nil,
                completion: { (result : AnyObject?, response : NSHTTPURLResponse?, error: NSError?) -> Void in
                    
                    if error == nil{
                        let sasURL = result!["sasURL"] as? String
                        var endPoint = "https://scoopsizabela.blob.core.windows.net"
                        endPoint += sasURL!
                        let url = NSURL(string: endPoint)!
                        let download = dispatch_queue_create(blobName, nil);
                        dispatch_async(download){
                            let data = NSData(contentsOfURL:url)
                            var image : UIImage?
                            if data != nil{
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    
                                    image = UIImage(data : data!)
                                    imageView.image = image
                                    //cell.setNeedsLayout;
                                    //save it:
                                    let image = UIImage(data: data!)
                                    UIImageJPEGRepresentation(image!, 100)!.writeToFile(strFilePath, atomically: true)
                                    
                                    
                                })
                            }
                        }
                        
                    }
                    
            })
            
            
            
            
            
        }
        
        
        
        //}
        
    }

}
