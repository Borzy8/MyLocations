//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Borzy on 19.08.18.
//  Copyright © 2018 Borzy. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import AVFoundation
import AudioToolbox



class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    var location: CLLocation?;
    let locationManager = CLLocationManager();
    var updatingLocation = false;
    var lastLocationError: NSError?;
    
    var geocoder = CLGeocoder();
    var placemark: CLPlacemark?;
    var performingReverseGeocoding = false;
    var lastGeocodingError: NSError?;
    
    var timer: NSTimer?;
    
    var managedObjectContext: NSManagedObjectContext!;
    
    var logoVisible = false;
    
    var player: AVAudioPlayer?;
    var soundID: SystemSoundID = 0;
    lazy var logoButton: UIButton = {
        let button = UIButton(type: UIButtonType.Custom);
        button.setBackgroundImage(UIImage(named:"Logo"), forState: UIControlState.Normal);
        button.sizeToFit()
        button.addTarget(self, action: #selector(getLocation), forControlEvents: .TouchUpInside)
        button.center.x = self.view.bounds.midX;
        button.center.y = 220;
        return button
        
    }()
    
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    @IBOutlet weak var latitudeTextLabel: UILabel!
    @IBOutlet weak var longitudeTextLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBAction func getLocation() {
         // Permission to get coordinates
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == CLAuthorizationStatus.NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if  authStatus == CLAuthorizationStatus.Restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        if logoVisible {
            logoButton.removeFromSuperview();
            logoVisible = false
          
            containerView.hidden = false;
        }
        
        
        // Press "Stop"
        if updatingLocation {
            stopLocationManager();

        } else {
            
            location = nil;
            lastLocationError = nil;
            placemark = nil;
            lastGeocodingError = nil;
            startLocationManager();
   
        }
        updateLabels();
        configureGetButton();
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location services disabled", message: "Please enable location services for this App in Settings", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alert.addAction(okAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error)");
        
        if (error as NSError).code == CLError.LocationUnknown.rawValue {
            return
        }
        
        lastLocationError = error;
        stopLocationManager();
        updateLabels();
        configureGetButton();
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
       
        let newLocation = locations.last!;
        print("didUpdateLocations \(newLocation)");
        
        //1
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        //2
        if newLocation.horizontalAccuracy < 0 {
            return;
        }
        
        //Distance from old location
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = newLocation.distanceFromLocation(location);
        }
        
        //3 
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            
            //4
            lastLocationError = nil;
            location = newLocation;
            updateLabels();
            
            //5
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("We are done");
                stopLocationManager();
                configureGetButton();
                
                // Check distance from old location
                if distance > 0 {
                    self.performingReverseGeocoding = false;
                }
            }
        
            // Reverse geocoding
            
            if !performingReverseGeocoding {
                print("Going to geocode");
                
                performingReverseGeocoding = true;
                
                geocoder.reverseGeocodeLocation(newLocation, completionHandler: {placemarks, error in
                    
                    print("*** Found placemarks: \(placemarks), error: \(error)");
                    
                    self.lastGeocodingError = error;
                    
                    if error == nil, let p = placemarks where !p.isEmpty {
                        // Play sound
                       // print("FIRST TIME!");
                       // self.playSoundEffect();
                        self.placemark = p.last;
                    } else {
                        self.placemark = nil;
                    }
                    
                    self.performingReverseGeocoding = false;
                    self.updateLabels();
                })
            }
        
        } else if distance < 1 {
        
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp);
            
            if timeInterval > 10 {
                print("***Force done");
                stopLocationManager();
                updateLabels();
                configureGetButton();
            }
        }
        
        
        
        
    }
    
    func updateLabels() {
        
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.hidden = false
            messageLabel.text = ""
            
            // Show labels
            latitudeTextLabel.hidden = false;
            longitudeTextLabel.hidden = false;
            adressLabel.hidden = false;
            
            // Reverse geocoding info (adress)
            if let placemark = placemark {
                adressLabel.text = string(from: placemark);
            } else if performingReverseGeocoding {
                adressLabel.text = "Searching for adress..."
            } else if lastGeocodingError != nil {
                adressLabel.text = "Error finding adress"
            } else {
                adressLabel.text = "No adress found"
            }
            
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            tagButton.hidden = true
            messageLabel.text = ""
            
            showLogoView();
            
            // Hide labels
            longitudeTextLabel.hidden = true;
            latitudeTextLabel.hidden = true;
            adressLabel.hidden = true;
            
            let statusMessage: String;
            
            if let error = lastLocationError {
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
                    statusMessage = "Location services disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled(){
                    statusMessage = "Location services disabled"
            } else if updatingLocation {
                    statusMessage = "Searching ...";
                    hideLogoView();
            } else {
                statusMessage = "Tap 'Get my location' to start"
            }
            messageLabel.text = statusMessage;
        }
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            locationManager.startUpdatingLocation();
            
            updatingLocation = true
            
            timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false);
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation();
            locationManager.delegate = nil;
            updatingLocation = false;
            
            if let timer = timer {
                timer.invalidate();
            }
        }
    }
    
    func configureGetButton() {
        
        let spinnerTag = 1000;
        
        if updatingLocation {
            getButton.setTitle("Stop", forState: .Normal);
            
            if view.viewWithTag(spinnerTag) == nil {
                let activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .White);
                activitySpinner.center = messageLabel.center;
                activitySpinner.center.y += activitySpinner.bounds.height/2 + 15;
                activitySpinner.startAnimating();
                activitySpinner.tag = spinnerTag;
                view.addSubview(activitySpinner);
                
            }
        } else {
            getButton.setTitle("Get my location", forState: .Normal);
            if let spinner = view.viewWithTag(spinnerTag) {
            spinner.removeFromSuperview();
            }
        }
    }
    
    func string(from placemark: CLPlacemark) -> String {
        //1
        var line1 = ""
        
        //2
        line1.add(placemark.subThoroughfare);
        //3
        line1.add(placemark.thoroughfare, separatedBy: " ");
        
        
        //4
        var line2 = ""
        
        line2.add(placemark.locality, separatedBy: "");
        line2.add(placemark.administrativeArea, separatedBy: " ");
        line2.add(placemark.postalCode, separatedBy: " ");
        
        line1.add(line2, separatedBy: "\n");
//        "\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? "")\n\(placemark.locality ?? "") \(placemark.administrativeArea ?? "") \(placemark.postalCode ?? "")"
        //5
        
        return line1;
        
    }
    
    func didTimeOut() {
        print("***Time out");
        
        if location == nil {
            stopLocationManager();
            
            lastLocationError = NSError(domain: "MyLocationErrorDomain", code: 1, userInfo: nil);
        }
        
        updateLabels();
        configureGetButton();
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TagLocation" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            
            controller.coordinate = location!.coordinate;
            controller.placemark = placemark;
            controller.managedObjectContext = managedObjectContext;
         }
    }
    override func viewDidLoad() {
        super.viewDidLoad();
        configureGetButton();
        updateLabels();
      //  loadSoundEffect("Sound.caf");
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//MARK: - Logo view
    func showLogoView() {
        if !logoVisible {
            logoVisible = true;
            containerView.hidden = true;
            view.addSubview(logoButton);
        }
    }
    
    func hideLogoView() {
        if !logoVisible {return };
            logoVisible = false;
            containerView.hidden = false;
        containerView.center.x = view.bounds.width * 2;
        containerView.center.y = containerView.bounds.height/2;
        
        let centerX = view.bounds.midX;
        //1
        let panelMover = CABasicAnimation(keyPath: "position");
        panelMover.removedOnCompletion = false;
        panelMover.fillMode = kCAFillModeForwards;
        panelMover.duration = 0.6;
        panelMover.fromValue = NSValue(CGPoint: containerView.center);
        panelMover.toValue = NSValue(CGPoint: CGPoint(x: centerX, y: containerView.center.y));
        panelMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn);
        panelMover.delegate = self;
        containerView.layer.addAnimation(panelMover, forKey: "panelMover");
        //2
        let logoMover = CABasicAnimation(keyPath: "position");
        logoMover.removedOnCompletion = false;
        logoMover.fillMode = kCAFillModeForwards;
        logoMover.duration = 0.6;
        logoMover.fromValue = NSValue(CGPoint: logoButton.center)
        logoMover.toValue = NSValue(CGPoint: CGPoint(x: -centerX, y: logoButton.center.y));
        logoMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn);
        logoButton.layer.addAnimation(logoMover, forKey: "logoMover");
        
        //3
        
        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z");
        logoRotator.removedOnCompletion = false;
        logoRotator.fillMode = kCAFillModeForwards;
        logoRotator.duration = 0.5;
        logoRotator.fromValue = 0.0;
        logoRotator.toValue = -2 * M_PI;
        logoRotator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn);
        logoButton.layer.addAnimation(logoRotator, forKey: "logoRotator");
        
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        containerView.layer.removeAllAnimations();
        containerView.center.x = view.bounds.size.width / 2;
        containerView.center.y = containerView.bounds.size.height / 2;
        
        logoButton.layer.removeAllAnimations();
        logoButton.removeFromSuperview()
    }
    
    //Alternative
    /*
    func play() {
        
        let path = NSBundle.mainBundle().pathForResource("Sound.caf", ofType: nil)
        print(path);
            let fileURL = NSURL(fileURLWithPath: path!, isDirectory: false)
       
        do {
            player = try AVAudioPlayer(contentsOfURL: fileURL);
            guard let player = player else {return}
            
            player.prepareToPlay();
            player.play();
        } catch let error as NSError {
            print(error.description);
        }
    
    }
    */
    // Non-working sound
    /*
    func loadSoundEffect(_ name: String) {
        
        if let path = NSBundle.mainBundle().pathForResource(name, ofType: nil) {
            print(path);
            let fileURL = NSURL(fileURLWithPath: path, isDirectory: false);
            let error = AudioServicesCreateSystemSoundID(fileURL as! CFURL, &soundID)
            
            if error != kAudioServicesNoError {
                print("Error code \(error) loading sound in path: \(path)");
            }
        }
    }
    
    func unloadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundID);
    }
    
    func playSoundEffect() {
        AudioServicesPlaySystemSound(soundID);
    }
 */
}

