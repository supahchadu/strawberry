//
//  Constants.swift
//  notefy
//
//  Created by Chad-Mac on 8/8/16.
//  Copyright © 2016 Chad-Mac. All rights reserved.
//

import UIKit

var SHADOW_GRAY:CGFloat = 120/255.0
let KEY_UID = "uid"

func messageToast(message: String, view: UIView){
    // ----------- JUST A HECK OF A LOT OF CODE FOR A TOAST ZZzZzzZz --------
    let toastLabel = UILabel(frame: CGRectMake(view.frame.size.width/2 - 150, view.frame.size.height-100, 300, 35))
    toastLabel.backgroundColor = UIColor.blackColor()
    toastLabel.textColor = UIColor.whiteColor()
    toastLabel.textAlignment = NSTextAlignment.Center;
    view.addSubview(toastLabel)
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10
    toastLabel.clipsToBounds  =  true
    
    UIView.animateWithDuration(4.0, delay: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
        
        toastLabel.alpha = 0.0
        
        }, completion: nil)
    // ----------- < END OF TOAST > ---------
}