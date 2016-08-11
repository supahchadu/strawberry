//
//  NoteFeed.swift
//  notefy
//
//  Created by Chad-Mac on 8/8/16.
//  Copyright © 2016 Chad-Mac. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import SwiftKeychainWrapper

class NoteFeed: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addImage: cameraDesignViewSmoothRect!
    @IBOutlet weak var noteMessageField: PasswordDesignView!
    
    var locationManager: CLLocationManager!
    var geoFire: GeoFire!
    var geoFireRef: FIRDatabaseReference!
    static var arrayKeys = [String]()
    var notes = [Note]()
    var imagePicker: UIImagePickerController!
    var caption: String!
    var imageURL: String!
    var likes: Int!
    var noteKey: String!
    // Global Cache in phones image
    static var imageCache: NSCache = NSCache()
    
    // Preventing to upload the icon image placeholder to the storage.
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        noteMessageField.delegate = self
        
        // initializing our image pick and edit photo
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        geoFireRef = FIRDatabase.database().reference()
        //geoFire = GeoFire(firebaseRef: geoFireRef)
        
        // Observe a live changing data from the database
        // Retrieving DATA ACCORDING TO LOCATION -------->
        locationAuthStatus()
        
        DatabaseService.databaseService.REF_NOTES.observeEventType(.Value, withBlock: { (snapshot) in
                
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                self.notes.removeAll()
                for snap in snapshots {
                    print("SNAP: ----------> \(snap)")
                    for childKey in NoteFeed.arrayKeys {
                            if childKey == snap.key {
                            if let noteDict = snap.value as? Dictionary<String, AnyObject> {
                                let key = snap.key
                                let note = Note(noteKey: key, noteData: noteDict)
                                self.notes.append(note)
                                print("INSIDE: -------> \(childKey)")
                            }
                        }
                    }
                    // self.tableView.reloadData()
                }
                //self.tableView.reloadData()
            }
            self.tableView.reloadData()
        })
    }
    

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        noteMessageField.resignFirstResponder()
        return true
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }

    /*func refreshNotesOnFeed() {
        for childKey in NoteFeed.arrayKeys {
            DatabaseService.databaseService.REF_NOTES.child(childKey).observeEventType(.Value, withBlock: { (snapshot) in
                
                
                
                if let noteCaption = snapshot.value?.objectForKey("caption") as? String {
                    self.caption = noteCaption
                }
                if let noteImageUrl = snapshot.value?.objectForKey("imageUrl") as? String {
                    self.imageURL = noteImageUrl
                }
                if let noteLikes = snapshot.value?.objectForKey("likes") as? Int {
                    self.likes = noteLikes
                }
                
                let note = Note(noteKey: childKey, caption: self.caption, imageUrl: self.imageURL,likes: self.likes)
                print("NOTE:----------->\(self.caption)\(self.imageURL)\(self.likes)")
                
                self.notes.append(note)
                print("NOTE CONTENTS: \(self.notes)")
            })
            self.tableView.reloadData()

    }*/
    // ------------- LOCATION -------------
    func locationAuthStatus() {
        // Ask for the authorization for Google Location
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else { //else if they dont, then request it otherwise again.
            locationManager.requestWhenInUseAuthorization()
        }
    }
    

    // ------------- LOCATION ---------------
    // --------------------- TABLE VIEW --------------------------------
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let note = notes[indexPath.row]
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("NoteCell") as! NoteCell
            
            if let imgs = NoteFeed.imageCache.objectForKey(note.imageUrl) {
                cell.configureCell(note, img: imgs as? UIImage)
                
            } else {
                cell.configureCell(note, img: nil)
                
            }
            return cell
        
        
        /*if let cell = tableView.dequeueReusableCellWithIdentifier("NoteCell") as? NoteCell {
            
            if let imgs = NoteFeed.imageCache.objectForKey(note.imageUrl) {
                    cell.configureCell(note, img: imgs as? UIImage)
            
            } else {
                    cell.configureCell(note, img: nil)
            
            }
            return cell
        } else {
            return NoteCell()
        }*/
    }
    //---------------------- TABLE VIEW -----------------------------

    // For choosing image via Galleria in iPhones
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // We need the edited image first before we take it!
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImage.image = image // Set our image button as the image the user chose~
            imageSelected = true
        } else {
            print("Invalid Image selected")
        }
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func postToFirebase(urls: String){
        
        let postUid = NSUUID().UUIDString
        geoFire = GeoFire(firebaseRef: DatabaseService.databaseService.REF_NOTES)
        geoFire.setLocation(locationManager.location, forKey: postUid)
        print("CHAD: LOCATION = \(locationManager.location)")
        
        let post: Dictionary<String, AnyObject> = [
            "caption": noteMessageField.text!,
            "imageUrl": urls,
            "likes": 0,
        ]
    
        let firebasePost = DatabaseService.databaseService.REF_NOTES.child(postUid)
        firebasePost.updateChildValues(post)
        
        // Setting back the defaults after pushing the datas to firebase
        noteMessageField.text = ""
        imageSelected = false
        addImage.image = UIImage(named: "add-image")
        messageToast("Your note has been submitted.", view: self.view)
        //tableView.reloadData()
        
        
    }
    
    func messageToast(message: String, view: UIView){
        // ----------- JUST A HECK OF A LOT OF CODE FOR A TOAST ZZzZzzZz --------
        let toastLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - 150, self.view.frame.size.height-100, 300, 35))
        toastLabel.backgroundColor = UIColor.blackColor()
        toastLabel.textColor = UIColor.whiteColor()
        toastLabel.textAlignment = NSTextAlignment.Center;
        self.view.addSubview(toastLabel)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        
        UIView.animateWithDuration(4.0, delay: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            toastLabel.alpha = 0.0
            
            }, completion: nil)
        // ----------- < END OF TOAST > ---------
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func mapFeedButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("gotoNoteMaps", sender: nil)
    }
    
    @IBAction func addImageNoteTapped(sender: AnyObject) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // uploading the chosen image and then posting the notes on the database and onto the tableView
    @IBAction func postNoteOnMapTapped(sender: AnyObject) {
        // Make sure theres a message on the note message field! if not then errr...
        guard let caption = noteMessageField.text where caption != "" else {
            print("Message must be entered!")
            messageToast("A message must be entered.", view: self.view)
            return
        }
        
        // We need at least an image!
        guard let ig = addImage.image where imageSelected == true else {
            print("No Immage is selected")
            messageToast("Please Select an Image.", view: self.view)
            return
        }
        
        // Uploading image via JPEG format and tone it down for fast cache
        // and fast storage and upload! No Massive data please~
        if let imgData = UIImageJPEGRepresentation(ig, 0.2){
            
            // We create a unique Identifier for the image to be uploaded
            let imgUid = NSUUID().UUIDString
            // Which type of image we want to store
            let metaData = FIRStorageMetadata()
            metaData.contentType = "img/jpeg" // Set the content or type of image
            
            // Now we push the data to the database storage with a Unique Identifier, the image, and the type it is.
            DatabaseService.databaseService.REF_IMAGES.child(imgUid).putData(imgData, metadata: metaData, completion: {(metadata, error) in
                if error != nil {
                    print("Unable to upload image from the database storage = \(error)")
                } else {
                    print("Successfully uploaded image to the database storage")
                    // Now for the posting purposes,  we need the URL to store and post for our feed.
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.postToFirebase(url)
                    }
                }
            })
            
        }
    }
    
    @IBAction func signOutButton(sender: AnyObject) {
        // remove keychain
        // logout firebase
        let keychain = KeychainWrapper.removeObjectForKey(KEY_UID)
        try! FIRAuth.auth()?.signOut()
        print("Keychain successfully removed \(keychain)")
        performSegueWithIdentifier("goToSignIn", sender: nil)
    }
}
