//
//  Functions.swift
//  MyLocations
//
//  Created by Borzy on 27.08.18.
//  Copyright © 2018 Borzy. All rights reserved.
//

import Foundation
import Dispatch

func afterDelay( seconds: Double, closeVCBy closure:   () -> () ) {
    
    let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)));
    
    dispatch_after(dispatchTime, dispatch_get_main_queue(), closure);
}

var applicationDocumentsDirectory: NSURL = {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "void.test" in the application's documents Application Support directory.
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count-1]
}()

let MyManagedObjectContextSaveDidFailNotification = NSNotification(name: "MyManagedObjectContextSaveDidFailNotification", object: nil);

func fatalCoreDataError(error: NSError) {
    print("***Fatal Error: \(error)");
    NSNotificationCenter.defaultCenter().postNotification(MyManagedObjectContextSaveDidFailNotification);
}