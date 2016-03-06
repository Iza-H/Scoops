//
//  NewViewController.swift
//  Scoops
//
//  Created by Izabela on 04/03/16.
//  Copyright © 2016 Izabela. All rights reserved.
//

import CoreLocation


class NewViewController: UIViewController, CLLocationManagerDelegate {

    var client : MSClient?
    var photoName : String = ""
    var bufferPhoto : NSData?
    
  
    @IBOutlet weak var newsText: UITextView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var publishSwitch: UISwitch!
    @IBOutlet weak var photo: UIImageView!
    @IBAction func addButton(sender: AnyObject) {
         captureFotoBlogFromViewController(self, withDelegate: self)
    }
    @IBAction func addNewNews(sender: AnyObject) {
        //Validate values:
        //Save in MS

        if isUserLoged(){
            if let usrlogin = loadUserAuth(){
                
                client!.currentUser = MSUser(userId: usrlogin.usr)
                client!.currentUser.mobileServiceAuthenticationToken = usrlogin.tok

                
                let tabla = client?.tableWithName("news")
                var publishValue = false
                if publishSwitch.on{
                    publishValue = true
                }
                
                
                tabla?.insert(["title": titleText.text!, "news": newsText.text! , "photo": photoName, "longitud": latitudeLabel.text!, "latitude" : latitudeLabel.text!, "published" : publishValue], completion: { (inserted, error:NSError?) -> Void in
                //tablaVideos?.insert(["title": titleText.text!], completion: { (inserted, error:NSError? ) -> Void in
                    
                    if error != nil{
                        print ("Error: \(error?.userInfo["NSLocalizedDescription"]!)")
                        let alert = UIAlertView(title: "Error",
                            message: "\(error?.userInfo["NSLocalizedDescription"]!)",
                            delegate: nil,
                            cancelButtonTitle: "Ok")
                        alert.show()
                    } else {
                        print( " Register saved in the DB")
                        if (self.photoName != ""){
                            self.uploadToStorage(self.bufferPhoto!, blobName: self.photoName)
                        }
                        
                        
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
    
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    

    
    func captureFotoBlogFromViewController(ViewController:UIViewController, withDelegate delegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)->Bool{
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)==true){
            let camaraController = UIImagePickerController()
            camaraController.sourceType = .Camera
            camaraController.allowsEditing=false
            camaraController.delegate = delegate
            presentViewController(camaraController, animated: true, completion: nil)
            return true
        }else if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            let camaraController = UIImagePickerController()
            camaraController.delegate = self
            camaraController.sourceType = .PhotoLibrary;
            camaraController.allowsEditing = false
            self.presentViewController(camaraController, animated: true, completion: nil)
            return true
        } else {
            print("No camera / PhotoLibrary")
            let alert = UIAlertView(title: "Camera acces",
                message: "Camera not available",
                delegate: nil,
                cancelButtonTitle: "Ok")
            alert.show()
            return false
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let loc = locations.last! as CLLocation
        self.longitudeLabel.text = "\(loc.coordinate.longitude)"
        self.latitudeLabel.text = " \(loc.coordinate.latitude)"
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError: \(error.description)")
        let errorAlert = UIAlertView(title: "Error", message: "Failed to Get Your Location", delegate: nil, cancelButtonTitle: "Ok")
        errorAlert.show()
        
    }
    
    
    func uploadToStorage (data:NSData, blobName: String){
        client?.invokeAPI("urlsastoblobandcontainer",
            body:nil,
            HTTPMethod: "GET",
            parameters: ["photoName":photoName, "ContainerName" :"photos"],
            headers : nil,
            completion:{(result: AnyObject?,response :  NSHTTPURLResponse?, error:NSError?) -> Void in
                if error == nil {
                    let sasURL = result!["sasURL"] as? String
                    var endPoint = "https://scoopsizabela.blob.core.windows.net"
                    endPoint += sasURL!
                    let container = AZSCloudBlobContainer ( url: NSURL(string: endPoint)!)
                    let blobLocal = container.blockBlobReferenceFromName(blobName)
                    
                    //upload del blob local + NSData
                    blobLocal.uploadFromData( data, completionHandler : {(error : NSError?) -> Void in
                        if error != nil{
                           /* dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.saveInAzureButton.enabled = false
                            })*/
                        }else {
                            print("Error")
                        }
                        
                    })
                    
                }
        })
    }
    
  
  

}

extension NewViewController:UINavigationControllerDelegate{}

extension NewViewController:UIImagePickerControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage:UIImage = (info[UIImagePickerControllerOriginalImage]) as? UIImage {
            photo.image = pickedImage
            photoName = "photo-\(NSUUID().UUIDString).jpg"
            bufferPhoto = UIImageJPEGRepresentation(pickedImage, 0.8)
            //let selectorToCall = Selector("imageWasSavedSuccessfully:didFinishSavingWithError:context:")
            //UIImageWriteToSavedPhotosAlbum(pickedImage, self, selectorToCall, nil)
            
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.startUpdatingLocation()
                    
           
        }
        
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("User canceled image")
        dismissViewControllerAnimated(true, completion: {
            // Anything you want to happen when the user selects cancel
        })
    }
}
