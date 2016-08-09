//
//  DesignView.swift
//  notefy
//
//  Created by Chad on 8/7/16.
//  Copyright © 2016 Richard Dean D. All rights reserved.
//

import UIKit

class DesignView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // color of the shadow with Constants SHADOW GRAY
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).CGColor
        layer.shadowOpacity = 0.8   // Shadow total transparency
        layer.shadowRadius = 5.0    // Radius or how far of the shadow in the view
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0) // To gradient the shadow or blur out the intensity of the shadow
        layer.cornerRadius = 2.0
    }
    
}
