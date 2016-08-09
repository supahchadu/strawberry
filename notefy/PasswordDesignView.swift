//
//  PasswordDesignView.swift
//  notefy
//
//  Created by Chad-Mac on 8/8/16.
//  Copyright © 2016 Chad-Mac. All rights reserved.
//

import UIKit

class PasswordDesignView: UITextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.2).CGColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 2.0
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 5)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 5)
    }
    
    
}
