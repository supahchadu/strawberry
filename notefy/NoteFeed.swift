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

class NoteFeed: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // Observe a live changing data from the database
        DatabaseService.databaseService.REF_NOTES.observeEventType(.Value, withBlock: { (snapshot) in
            print(snapshot.value)
        })
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("NoteCell") as! NoteCell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
