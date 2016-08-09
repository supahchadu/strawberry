//
//  Note.swift
//  notefy
//
//  Created by Chad-Mac on 8/8/16.
//  Copyright © 2016 Chad-Mac. All rights reserved.
//

import Foundation

class Note {
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _noteKey: String!
    private var _location: CLLocation!
    
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
    
    init(caption: String, imageUrl: String, likes: Int, location: CLLocation){
        
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
    }
}