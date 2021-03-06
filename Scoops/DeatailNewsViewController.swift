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
    var nameFile : String = ""
    var id : String = ""
    var delegate : NewsTableDelegate? = nil
    
    @IBOutlet weak var titleField: UITextField!

    @IBOutlet weak var indicator: UIActivityIndicatorView!

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
    @IBAction func saveChanges(sender: AnyObject) {
        
        if isUserLoged(){
            if let usrlogin = loadUserAuth(){
                
                client!.currentUser = MSUser(userId: usrlogin.usr)
                client!.currentUser.mobileServiceAuthenticationToken = usrlogin.tok
                
                
                let tabla = client?.tableWithName("news")
                var publishValue = false
                if pushSwitch.on{
                    publishValue = true
                }
                
                
                tabla?.update(["id": self.id ,"title": titleField.text!, "news": newsField.text! , "photo": nameFile, "longitud": latitudeLabel.text!, "latitude" : latitudeLabel.text!, "published" : publishValue], completion: { (inserted, error:NSError?) -> Void in
                    //tablaVideos?.insert(["title": titleText.text!], completion: { (inserted, error:NSError? ) -> Void in
                    
                    if error != nil{
                        print ("Error: \(error?.userInfo["NSLocalizedDescription"]!)")
                        let alert = UIAlertView(title: "Error",
                            message: "\(error?.userInfo["NSLocalizedDescription"]!)",
                            delegate: nil,
                            cancelButtonTitle: "Ok")
                        alert.show()
                    } else {
                        print( "Register saved in the DB")
                        self.delegate?.addedNewValues()
                        
                        
                    }
                    
                })
            }
        }else {
            //user not logged:
            client!.loginWithProvider("facebook", controller: self, animated: true, completion: { (user: MSUser?, error: NSError?) -> Void in
                
                if (error != nil){
                    print("There is a probelm with user login")
                } else{
                    saveAuthInfo(user)
                    
                }
            })
        }

        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        titleField.text = model!["title"] as? String;
        authorField.text = model!["userName"] as? String;
        self.id = (model!["id"] as? String)!;
        self.indicator.hidden = true
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
                    
                    let blobName = result?.items[0]["photo"] as? String;
                    if (blobName != ""){
                        self.indicator.hidden=false
                        self.indicator.startAnimating()
                         var image : UIImage?
                        
                        //check if saved in dhe caache:
                        let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as String
                        self.nameFile = blobName!
                        let strFilePath = cachePath.stringByAppendingString("/\(self.nameFile)")
                        
                        let manager = NSFileManager.defaultManager()
                        if (manager.fileExistsAtPath(strFilePath)) {
                            //get it from cache
                            let data = NSData(contentsOfFile: strFilePath)
                            image = UIImage(data : data!)
                            self.imageView.image = image
                            self.indicator.stopAnimating()
                            self.indicator.hidden=true
                        }else{
                        //Download and save it:
                        
                            let containerName = "photos"
                            self.client?.invokeAPI("urlsastoblobandcontainer",
                                body: nil,
                                HTTPMethod: "GET",
                                parameters: ["photoName" : blobName!, "ContainerName" : containerName],
                                headers: nil,
                                completion: { (result : AnyObject?, response : NSHTTPURLResponse?, error: NSError?) -> Void in
                                    
                                    if error == nil{
                                        let sasURL = result!["sasURL"] as? String
                                        var endPoint = "https://scoopsizabela.blob.core.windows.net"
                                        endPoint += sasURL!
                                        let url = NSURL(string: endPoint)!
                                        let download = dispatch_queue_create(blobName!, nil);
                                        dispatch_async(download){
                                            let data = NSData(contentsOfURL:url)
                                            //var image : UIImage?
                                            if data != nil{
                                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                    
                                                    image = UIImage(data : data!)
                                                    self.imageView.image = image
                                                    self.indicator.stopAnimating()
                                                    self.indicator.hidden=true
                                                    
                                                    //save it:
                                                    let image = UIImage(data: data!)
                                                    UIImageJPEGRepresentation(image!, 100)!.writeToFile(strFilePath, atomically: true)
                                                    
                                    
                                                    
                                                })
                                            }
                                        }
                                        
                                    }
                                    
                            })
                        
                        }
                    }
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
