//
//  MapViewController.swift
//  MyLocations
//
//  Created by Borzy on 30.08.18.
//  Copyright © 2018 Borzy. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    var locations = [Location]();

    @IBOutlet weak var mapView: MKMapView!;
    
    var managedObjectContext: NSManagedObjectContext! {
        didSet {
            NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextObjectsDidChangeNotification, object: managedObjectContext, queue: NSOperationQueue.mainQueue(), usingBlock: { notification in
                
                guard self.isViewLoaded() else {return}
                
                if let dictionary = notification.userInfo {
                    if let objectSet = dictionary["inserted"] {
                        let set = objectSet as! NSMutableSet;
                        let array = set.allObjects as! [Location];
                        let object = array[0];
                        
                        self.mapView.removeAnnotations(self.locations);
                        
                        self.locations.append(object);
                        
                        self.mapView.addAnnotations(self.locations);
                    };
                    if let objectSet = dictionary["deleted"] {
                        let set = objectSet as! NSMutableSet;
                        let array = set.allObjects as! [Location];
                        let object = array[0];
                        
                        self.mapView.removeAnnotations(self.locations)
                        
                        let index = self.locations.indexOf(object as! Location)!;
                        self.locations.removeAtIndex(index);
                        
                        self.mapView.addAnnotations(self.locations)
                    }
                    if let object = dictionary["updated"] {
                        self.updateLocations();
                    }
                    
                }
            })
        }
    };
    
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000);
        mapView.setRegion(region, animated: true);
    }
    
    @IBAction func showLocations() {
        let regionToSet = region(_for: locations);
        mapView.setRegion(regionToSet, animated: true);
        
    }
    
    func updateLocations() {
        mapView.removeAnnotations(locations);
        
        let fetchRequest = NSFetchRequest(entityName: "Location");
        locations = try! managedObjectContext.executeFetchRequest(fetchRequest) as! [Location];
        
        mapView.addAnnotations(locations);
    }
    
    func showLocationDetails(_ sender: UIButton) {
        performSegueWithIdentifier("EditLocation", sender: sender);
        }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        updateLocations();
        
        if !locations.isEmpty {
            showLocations();
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func region(_for annotaions: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion;
        
        switch annotaions.count {
        case 0:
            region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000);
        case 1:
            let annotation = annotaions[annotaions.count - 1];
            region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000);
            
        default:
            var topLeftCoor = CLLocationCoordinate2D(latitude: -90, longitude: 180);
            var bottomRightCoor = CLLocationCoordinate2D(latitude: 90, longitude: -180);
            
            for annotation in annotaions {
                topLeftCoor.latitude = max(topLeftCoor.latitude, annotation.coordinate.latitude);
                topLeftCoor.longitude = min(topLeftCoor.longitude, annotation.coordinate.longitude);
                
                bottomRightCoor.latitude = min(bottomRightCoor.latitude, annotation.coordinate.latitude);
                bottomRightCoor.longitude = max(bottomRightCoor.longitude, annotation.coordinate.longitude);
            }
            
            let center = CLLocationCoordinate2D(latitude: topLeftCoor.latitude - (topLeftCoor.latitude - bottomRightCoor.latitude)/2, longitude: topLeftCoor.longitude - (topLeftCoor.longitude - bottomRightCoor.longitude)/2)
            
            let extraSpace = 1.1;
            let span = MKCoordinateSpan(latitudeDelta: abs(topLeftCoor.latitude - bottomRightCoor.latitude)*extraSpace, longitudeDelta: abs(topLeftCoor.longitude - bottomRightCoor.longitude)*extraSpace);
            
            region = MKCoordinateRegion(center: center, span: span);
        }
        return region;
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destinationViewController as! UINavigationController;
            let locationDetailsController = navigationController.topViewController as! LocationDetailsViewController;
            
            locationDetailsController.managedObjectContext = managedObjectContext;
            
            let button = sender as! UIButton;
            let location = locations[button.tag]
            
            locationDetailsController.locationToEdit = location;
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        //1
        guard annotation is Location else {
            return nil;
        }
        
        //2
        let identifier = "Location";
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier);
        
        if annotationView == nil {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier);
            
            //3
            pinView.canShowCallout = true;
            pinView.animatesDrop = false;
            pinView.pinTintColor = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1);
            pinView.tintColor = UIColor(white: 0.0, alpha: 0.5);
            
            //4
            let button = UIButton(type: .DetailDisclosure);
            button.addTarget(self, action: #selector(showLocationDetails), forControlEvents: .TouchUpInside);
            pinView.rightCalloutAccessoryView = button;
            
            annotationView = pinView;
        }
        
        if let annotationView = annotationView {
            annotationView.annotation = annotation
            
            //5
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            if let index = locations.indexOf(annotation as! Location) {
                button.tag = index;
            }
        }
        return annotationView;
    }
}

extension MapViewController: UINavigationBarDelegate {
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached;
    }
}