//
//  MapNotes.swift
//  notefy
//
//
//
//
//
//  Created by Chad on 8/7/16.
//  Copyright © 2016 Richard Dean D. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class MapNotes: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var spotNotes: UIImageView!
    
    let locationManager = CLLocationManager()   // Class manager that holdes location datas
    var mapHasCentered = false; // For centering our the map to the user's position once
    var geoFire: GeoFire!   // Fore Firebase Geolocation
    
    var geoFireRef: FIRDatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.Follow
        
        // Firebase Database reference to the actual database
        geoFireRef = FIRDatabase.database().reference()
        geoFire = GeoFire(firebaseRef: geoFireRef)
        locationAuthStatus()
        
    }
    
    // Function pass the location to the database with the notes to be created there.
    func createNoteLocation(forLocation location: CLLocation, hasNote noteId: Int){
        geoFire.setLocation(location, forKey: "\(noteId)")
    }
    
    
    func locationAuthStatus() {
        // Ask for the authorization for Google Location
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        } else { //else if they dont, then request it otherwise again.
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // Trigger gets the userlocation on map when permits.
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    // Centers the map where the user is currently standing
    func centerMapOnLocation(location: CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    // Updates the user's location and center the map once!
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            if !mapHasCentered {
                centerMapOnLocation(loc)
                mapHasCentered = true
            }
        }
    }
    
    // Replace the user in the map with a picture or icon :)
    // Also create a pin with the notes.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView : MKAnnotationView?
        let annoIdentifier = "note"
        
        if annotation.isKindOfClass(MKUserLocation.self){
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage(named: "emoji_btn") // Person currently
            
        } else if let deqAnno = mapView.dequeueReusableAnnotationViewWithIdentifier(annoIdentifier) {
            annotationView = deqAnno
            annotationView?.annotation = annotation
            
        }else { // default annotation and to make sure there is an annotation
            
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            annotationView = av
        
        }
        
        if let annotationView = annotationView, let anno = annotation as? NoteAnnotation {
            annotationView.canShowCallout = true;
            annotationView.image = UIImage(named: "\(anno.noteNumber)")
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn.setImage(UIImage(named: "map"), forState: UIControlState.Normal)
            annotationView.rightCalloutAccessoryView = btn
            
            
        }
        
        return annotationView
    }
    
    // Whenever the user go, show the notes on the map in the place <3
    func showNotesOnMap(location: CLLocation){
        let circleQuery = geoFire!.queryAtLocation(location, withRadius: 0.5)
        _ = circleQuery?.observeEventType(GFEventType.KeyEntered, withBlock: {(key, location) in
            if let key = key, let location = location {
                let anno = NoteAnnotation(coordinate: location.coordinate, noteNumber: Int(key)!)
                self.mapView.addAnnotation(anno)
            }
        
        })
    }

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        showNotesOnMap(loc)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let anno = view.annotation as? NoteAnnotation {
            var addressDictionary: [String:String]?
            let place = MKPlacemark(coordinate: anno.coordinate, addressDictionary: addressDictionary)
            let destination = MKMapItem(placemark: place)
            destination.name = "Note Sighted"
            let regionDistance: CLLocationDistance = 1000
            let regionSpan = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
            let options = [MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan:regionSpan.span),MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving ]
            MKMapItem.openMapsWithItems([destination], launchOptions: options)
            
        }
    }
    @IBAction func addRandomNotes(sender: AnyObject) {
        
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        let rand = arc4random_uniform(3) + 1
        createNoteLocation(forLocation: loc, hasNote: Int(rand))
        
    }

}

