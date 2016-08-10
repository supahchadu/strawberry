//
//  NoteCell.swift
//  notefy
//
//  Created by Chad-Mac on 8/8/16.
//  Copyright © 2016 Chad-Mac. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class NoteCell: UITableViewCell {
   
    @IBOutlet weak var noteImg: UIImageView!
    @IBOutlet weak var noteCaption: UITextView!
    @IBOutlet weak var noteLikes: UILabel!
    @IBOutlet weak var noteLikeImage: UIImageView!
    
    var note: Note!
    var likesRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1;
        noteLikeImage.addGestureRecognizer(tap)
        noteLikeImage.userInteractionEnabled = true
        
    }
    
    func configureCell(notes: Note, img: UIImage? = nil) {
        self.note = notes
        likesRef = DatabaseService.databaseService.REF_USER_CURRENT.child("likes").child(notes.noteKey)
        self.noteCaption.text = note.caption
        self.noteLikes.text = "\(note.likes)"
        
        if img != nil {
            self.noteImg.image = img
        } else {
            let ref = FIRStorage.storage().referenceForURL(note.imageUrl)
            ref.dataWithMaxSize(2 * 1024 * 1024, completion: {(data, error) in
                if error != nil {
                    print("Unable to download image on firebase storage")
                } else {
                    print("Successful download on firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData){
                            self.noteImg.image = img
                            NoteFeed.imageCache.setObject(img, forKey: self.note.imageUrl)
                        }
                    }
                }
            })
            
        }
        // Check if the current user like the post.
        
        likesRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.noteLikeImage.image = UIImage(named: "1")
            } else {
                self.noteLikeImage.image = UIImage(named: "2")
            }
        
        })
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
       
        likesRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.noteLikeImage.image = UIImage(named: "1")
                self.note.adjustLikes(true)
                self.likesRef.setValue(true)
            } else {
                self.noteLikeImage.image = UIImage(named: "2")
                self.note.adjustLikes(false)
                self.likesRef.removeValue()
            }
        })
        
        
    }
    
}
