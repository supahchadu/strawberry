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
    
    var notes = [Note]()
    var imagePicker: UIImagePickerController!
    
    // Global Cache in phones image
    static var imageCache: NSCache = NSCache()
    
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
    
    @IBAction func signOutButton(sender: AnyObject) {
        // remove keychain
        // logout firebase
        let keychain = KeychainWrapper.removeObjectForKey(KEY_UID)
        try! FIRAuth.auth()?.signOut()
        print("Keychain successfully removed \(keychain)")
        performSegueWithIdentifier("goToSignIn", sender: nil)
    }
}
