//
//  NewsTableViewController.swift
//  Scoops
//
//  Created by Izabela on 4/3/16.
//  Copyright © 2016 Izabela. All rights reserved.
//



class NewsTableViewController: UITableViewController, NewsTableDelegate {
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
        cell.imageView!.image = UIImage(named: "img_not_avalaible.png")
        let photoName = model![indexPath.row]["photo"] as? String
        if (photoName != ""){
            downloadImage(photoName!, imageView :cell.imageView!, cell: cell)
        }

        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("showDetails", sender:indexPath)
    }
    
     func populateModel(){
        let table = client?.tableWithName("news")
        let usrlogin = loadUserAuth()
        let predicate = NSPredicate(format: "userId = '\(usrlogin!.usr)'", [])
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
    
    func populateModelAllPublished(){
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
            nc.client = client
            nc.delegate = self
            break
        case "showDetails":
            let index = sender as? NSIndexPath
            let dc = segue.destinationViewController as! DeatailNewsViewController
            dc.client = client
            dc.model = model![(index?.row)!]
            break
            
        default: break
            
        }
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
    
    func addedNewValues(){
        populateModel()
    }
    



}

protocol NewsTableDelegate
{
    func addedNewValues()
}
