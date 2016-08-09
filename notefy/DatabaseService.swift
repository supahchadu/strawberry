//
//  Singleton-Class
//  DatabaseService.swift
//  notefy
//
//  Created by Chad-Mac on 8/8/16.
//  Copyright © 2016 Chad-Mac. All rights reserved.
//

import Foundation
import Firebase

// Global Referrence that contains the database URL
// Becareful not for stealing or hacking or anything.
let DB_SERVICE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage().reference()

class DatabaseService {
    // Single Instance and only for referrence to be accessed to any class
    static let databaseService = DatabaseService()
    private var _REF_BASE = DB_SERVICE
    private var _REF_NOTES = DB_SERVICE.child("notes")
    private var _REF_USERS = DB_SERVICE.child("users")
    
    // Storage referrences
    private var _REF_NOTES_IMAGES = STORAGE_BASE.child("note-pics")
    
    // Local Accessors for the private referrences.
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_NOTES: FIRDatabaseReference {
        return _REF_NOTES
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_IMAGES: FIRStorageReference {
        return _REF_NOTES_IMAGES
    }
    
    // Handling Users created (equal) to the User being Authenticated
    // Dictionary datastructure to get them.
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        // If the data doesnt exist? then create! if There is! then just updates the data under it...
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    
}