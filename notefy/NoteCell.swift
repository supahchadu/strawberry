//
//  NoteCell.swift
//  notefy
//
//  Created by Chad-Mac on 8/8/16.
//  Copyright © 2016 Chad-Mac. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {
   
    @IBOutlet weak var noteImg: UIImageView!
    @IBOutlet weak var noteCaption: UITextView!
    @IBOutlet weak var noteLikes: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
