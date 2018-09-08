//
//  Location.swift
//  MyLocations
//
//  Created by Borzy on 27.08.18.
//  Copyright © 2018 Borzy. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Location: NSManagedObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude as! Double, longitude: longitude as! Double);
    }
    
    var title: String? {
        if locationDescription.isEmpty {
            return "(No Description)";
        } else {
            return locationDescription;
        }
    }
    
    var subtitle: String? {
        return category;
    }
    
    var hasPhoto: Bool {
        return photoID != nil;
    }
    
    var photoURL: NSURL {
        assert(photoID != nil, "No photo ID set");
        let fileName = "Photo-\(photoID).jpg";
        return applicationDocumentsDirectory.URLByAppendingPathComponent(fileName);
    }
    
    var photoImage: UIImage? {
        return UIImage(data: NSData(contentsOfURL: photoURL)!);
    }
// Insert code here to add functionality to your managed object subclass
    class func nextPhotoID() -> Int {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let currentID = userDefaults.integerForKey("PhotoID");
        userDefaults.setInteger(currentID + 1, forKey: "PhotoID");
        userDefaults.synchronize();
        print(userDefaults.integerForKey("PhotoID"));
        print("Print********")
        return currentID;
    }
    
    func removePhotoFile() {
        do {
            try NSFileManager.defaultManager().removeItemAtURL(photoURL);
        } catch {
            print("Error removing file: \(error)");
        }
    }
}
