//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Borzy on 28.08.18.
//  Copyright © 2018 Borzy. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Location");
        
        let sortDescriptor1 = NSSortDescriptor(key: "category", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "date", ascending: true);
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2];
        
        fetchRequest.fetchBatchSize = 20;
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "category", cacheName: "Locations");
        
        fetchedResultsController.delegate = self;
        
        return fetchedResultsController;
    }()
    
    var managedObjectContext: NSManagedObjectContext!;
    
    deinit {
        fetchedResultsController.delegate = nil;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performFetch();
        
        //Customize table view
        
        tableView.backgroundColor = UIColor.blackColor();
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2);
        tableView.indicatorStyle = .White
       
        navigationItem.rightBarButtonItem = editButtonItem();
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func performFetch() {
        do {
            try fetchedResultsController.performFetch();
        } catch {
            fatalCoreDataError(error as! NSError);
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count;
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section];
        return sectionInfo.name.uppercaseString;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects;
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as! LocationCell

        // Configure the cell...
        
        let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location;
        
        cell.configure(for: location);
       

        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditLocation"{
            let navigationController = segue.destinationViewController as! UINavigationController;
            let controller = navigationController.topViewController as! LocationDetailsViewController;
            
            controller.managedObjectContext = managedObjectContext;
            
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location;
                controller.locationToEdit = location;
                            }
        }
        
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 25, width: 300, height: tableView.sectionHeaderHeight);
        let label = UILabel(frame: labelRect);
        
        label.font = UIFont.boldSystemFontOfSize(11);
        label.text = tableView.dataSource!.tableView!(tableView, titleForHeaderInSection: section);
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor(white: 1.0, alpha: 0.4);
        
        let separatorRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 0.5, width: tableView.bounds.size.width - 15, height: 0.5);
        let separatorView = UIView(frame: separatorRect);
        separatorView.backgroundColor = tableView.separatorColor;
        
        let rectForView = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.sectionHeaderHeight);
        let view = UIView(frame: rectForView);
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.85);
        view.addSubview(label);
        view.addSubview(separatorView);
        
        return view;
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension LocationsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("***Controller will change content");
        tableView.beginUpdates();
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Delete:
            print("***NSFetchedResultsControllerDelete (object)");
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade);
        case .Insert:
            print("***NSFetchedResultsControllerInsert (object)");
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade);
        case .Update:
            print("***NSFetchedResultsControllerUpdate (object)");
            if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? LocationCell {
                let location = controller.objectAtIndexPath(indexPath!) as! Location
                cell.configure(for: location);
            }
        case .Move:
            print("***NSFetchedResultsControllerMove (object)");
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade);
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade);
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            print("***NSFetchedResultsControllerInsert (section)");
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade);
        case .Delete:
            print("***NSFetchedResultsControllerDelete (section)");
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade);
        case .Move:
            print("***NSFetchedResultsControllerDelete (section)");
        case .Move:
            print("***NSFetchedResultsControllerUpdate (section)");
        default: break;
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
       print("***Controller did change content");
        tableView.endUpdates();
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location;
            
            location.removePhotoFile();
            managedObjectContext.deleteObject(location);
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error as NSError);
            }
        }
        
    }
}