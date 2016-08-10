//
//  Note.swift
//  notefy
//
//  Created by Chad-Mac on 8/8/16.
//  Copyright © 2016 Chad-Mac. All rights reserved.
//

import Foundation
import Firebase

class Note {
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _noteKey: String!
    private var _location: CLLocation!
    private var _postRef: FIRDatabaseReference!
    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var noteKey: String {
        return _noteKey
    }
    
    var location: CLLocation {
        return _location
    }
    
    init(noteKey: String, caption: String, imageUrl: String, likes: Int){
        self._noteKey = noteKey
        self._caption = caption
        self._imageUrl = imageUrl
        self._likes = likes
        _postRef = DatabaseService.databaseService.REF_NOTES.child(_noteKey)
    }
    
    init(noteKey: String, noteData: Dictionary<String, AnyObject>){
        self._noteKey = noteKey
        
        if let caption = noteData["caption"] as? String{
            self._caption = caption
        }
        
        if let imageUrl = noteData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let likes = noteData["likes"] as? Int {
            self._likes = likes
        }
        
        _postRef = DatabaseService.databaseService.REF_NOTES.child(_noteKey)
    }
    
    func adjustLikes(addLike: Bool){
        if addLike {
            _likes = _likes + 1
        }else {
            _likes = _likes - 1
        }
        
        _postRef.child("likes").setValue(_likes)
    }
}