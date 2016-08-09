//
//  NoteAnnotation.swift
//  notefy
//
//  Created by Chad on 8/7/16.
//  Copyright © 2016 Richard Dean D. All rights reserved.
//

import Foundation

let typeNotes = [
    "Love"
]

class NoteAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var noteNumber: Int
    var noteType: String
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, noteNumber: Int){
        self.coordinate = coordinate
        self.noteNumber = noteNumber
        self.noteType = typeNotes[noteNumber-1]
        self.title = self.noteType
    }
}