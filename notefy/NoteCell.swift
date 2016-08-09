//
//  NoteCell.swift
//  notefy
//
//  Created by Chad-Mac on 8/8/16.
//  Copyright © 2016 Chad-Mac. All rights reserved.
//

import UIKit
import Firebase
class NoteCell: UITableViewCell {
   
    @IBOutlet weak var noteImg: UIImageView!
    @IBOutlet weak var noteCaption: UITextView!
    @IBOutlet weak var noteLikes: UILabel!
    
    var note: Note!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureCell(notes: Note, img: UIImage? = nil) {
        self.note = notes
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
    }
}
