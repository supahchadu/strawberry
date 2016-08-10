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
            
            let btn2 = FacebookButtonDesignView()
            btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn2.setImage(UIImage(named: "addsnaptostory"), forState: UIControlState.Normal)
            annotationView.leftCalloutAccessoryView = btn2
            
            
        }
        
        return annotationView
    }
    
    // Whenever the user go, show the notes on the map in the place <3
    func showNotesOnMap(location: CLLocation){
        let geoFire = GeoFire(firebaseRef: DatabaseService.databaseService.REF_NOTES)
        
        let circleQuery = geoFire!.queryAtLocation(location, withRadius: 0.5)
        _ = circleQuery?.observeEventType(GFEventType.KeyEntered, withBlock: {(key, location) in
            if let key = key, let location = location {
                let anno = NoteAnnotation(coordinate: location.coordinate, noteNumber: Int("1")!)
                print("\(key)")
                self.mapView.addAnnotation(anno)
                NoteFeed.arrayKeys.append(key)
                
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
       
        if control == view.rightCalloutAccessoryView {
    
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
        } else {
            // Adding the notes to our feed!
            let anno = view.annotation as? NoteAnnotation
            let toastLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - 150, self.view.frame.size.height-100, 300, 35))
            toastLabel.backgroundColor = UIColor.blackColor()
            toastLabel.textColor = UIColor.whiteColor()
            toastLabel.textAlignment = NSTextAlignment.Center;
            self.view.addSubview(toastLabel)
            toastLabel.text = "Succesfully added note!"
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10
            toastLabel.clipsToBounds  =  true
            UIView.animateWithDuration(4.0, delay: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                
                toastLabel.alpha = 0.0
                
            }, completion: nil)
            
            self.mapView.removeAnnotation(anno!)
        
        }
    }
    
    // Function pass the location to the database with the notes to be created there.
    func createNoteLocation(forLocation location: CLLocation, hasNote noteId: Int){
        geoFire.setLocation(location, forKey: "\(noteId)")
    
    }
    
    @IBAction func addRandomNotes(sender: AnyObject) {
        
        //let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        //createNoteLocation(forLocation: loc, hasNote: Int(1))
        performSegueWithIdentifier("gotoNoteFeeds", sender: nil)
    }

}

