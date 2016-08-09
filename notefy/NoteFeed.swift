//
//  NoteFeed.swift
//  notefy
//
//  Created by Chad-Mac on 8/8/16.
//  Copyright © 2016 Chad-Mac. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class NoteFeed: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addImage: cameraDesignViewSmoothRect!
    @IBOutlet weak var noteMessageField: PasswordDesignView!
    
    var notes = [Note]()
    var imagePicker: UIImagePickerController!
    
    // Global Cache in phones image
    static var imageCache: NSCache = NSCache()
    
    // Preventing to upload the icon image placeholder to the storage.
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // initializing our image pick and edit photo
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        // Observe a live changing data from the database
        DatabaseService.databaseService.REF_NOTES.observeEventType(.Value, withBlock: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    
                    if let noteDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let note = Note(noteKey: key, noteData: noteDict)
                        self.notes.append(note)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
        
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let note = notes[indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier("NoteCell") as? NoteCell {
            
            if let imgs = NoteFeed.imageCache.objectForKey(note.imageUrl) {
                cell.configureCell(note, img: imgs as? UIImage)
                return cell
            }else {
                cell.configureCell(note, img: nil)
                return cell
            }
        } else {
    
            return NoteCell()
        }
    }

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
            return
        }
        
        // We need at least an image!
        guard let img = addImage.image where imageSelected == true else {
            print("No Immage is selected")
            return
        }
        
        // Uploading image via JPEG format and tone it down for fast cache
        // and fast storage and upload! No Massive data please~
        if let imgData = UIImageJPEGRepresentation(img, 0.2){
            
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
