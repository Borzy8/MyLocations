//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Borzy on 25.08.18.
//  Copyright © 2018 Borzy. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

private let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter();
    formatter.dateStyle = .MediumStyle;
    formatter.timeStyle = .ShortStyle;
    print("Formatter created")
    return formatter;
}()

class LocationDetailsViewController: UITableViewController {
    var placemark: CLPlacemark?;
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0);
    
    var categoryName = "No Category";
    
    var managedObjectContext: NSManagedObjectContext!;
    
    var date = NSDate();
    
    var locationToEdit: Location? {
        didSet {
        
            if let location = locationToEdit {
                descriptionText = location.locationDescription;
                categoryName = location.category;
                date = location.date;
                coordinate = CLLocationCoordinate2D(latitude: Double(location.latitude!), longitude: Double(location.longitude!));
                placemark = location.placemark;
            }
        }
    }
    var descriptionText = "";
    
    var image: UIImage?;
    
    var observer: AnyObject!;
    
    deinit {
        print("*** deinit \(self)");
        NSNotificationCenter.defaultCenter().removeObserver(observer);
        
    }
    
    @IBOutlet weak var descriptionTextView: UITextView!;
    @IBOutlet weak var categoryLabel: UILabel!;
    @IBOutlet weak var latitudeLabel: UILabel!;
    @IBOutlet weak var longitudeLabel: UILabel!;
    @IBOutlet weak var adressLabel: UILabel!;
    @IBOutlet weak var dateLabel: UILabel!;
    
    @IBOutlet weak var imageView: UIImageView!;
    @IBOutlet weak var addPhotoLabel: UILabel!;
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func done() {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true);
    
        let location: Location;
        if let temp = locationToEdit {
            hudView.text = "Updated";
            location = temp;
        } else {
            hudView.text = "Tagged";
            let entityDescription = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext);
            location = NSManagedObject(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext) as! Location;
            location.photoID = nil;
        }
        
        location.locationDescription = descriptionTextView.text;
        
        //1
        
        
        //2
        location.category = categoryName;
        location.date = date;
        location.latitude = coordinate.latitude;
        location.longitude = coordinate.longitude;
        location.placemark = placemark;
        
        
        
        if let image = image {
            //1
           
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID();
                print(location.photoID);
            }
            //2
            if let data = UIImageJPEGRepresentation(image, 0.5) {
                //3
                do {
                    try data.writeToURL(location.photoURL, options: .DataWritingAtomic);
                } catch {
                    print("Error writing file: \(error)");
                }
            }
        }
        //3
        
        do {
            try managedObjectContext.save();
            
            afterDelay(0.6){
                self.dismissViewControllerAnimated(true, completion: nil);
            }
        } catch {
            
            fatalCoreDataError(error as! NSError);
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //table view customization
        tableView.backgroundColor = UIColor.blackColor();
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2);
        tableView.indicatorStyle = .White;
        
        descriptionTextView.textColor = UIColor.whiteColor();
        descriptionTextView.backgroundColor = UIColor.blackColor();
        
        addPhotoLabel.textColor = UIColor.whiteColor();
        addPhotoLabel.highlightedTextColor = addPhotoLabel.textColor;
        
        adressLabel.textColor = UIColor(white: 1.0, alpha: 0.4);
        adressLabel.highlightedTextColor = adressLabel.textColor;
        
        
        
        
        listenForBackgroundNotification();
        
        if let locationToEdit = locationToEdit {
            title = "Edit Location";
            if locationToEdit.hasPhoto {
                if let imageToShow = locationToEdit.photoImage {
                    show(imageToShow);
                }
            }
        }

        descriptionTextView.text = descriptionText;
        categoryLabel.text = categoryName;
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude);
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude);
        
        if let placemark = placemark {

            adressLabel.text = string(from: placemark);
        } else {
            adressLabel.text = "No Address Found"
        }
        dateLabel.text = format(date);
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard));
        gestureRecognizer.cancelsTouchesInView = false;
        tableView.addGestureRecognizer(gestureRecognizer);
    }
    
    func listenForBackgroundNotification() {
       observer =  NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue()){[weak self] _ in
        
        if let strongSelf = self {
            if strongSelf.presentedViewController != nil {
                strongSelf.dismissViewControllerAnimated(true, completion: nil);
            }
            strongSelf.descriptionTextView.resignFirstResponder();
        
        }
        }
    }
    
    func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.locationInView(tableView);
        let indexPath = tableView.indexPathForRowAtPoint(point);
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return;
        }
        
        descriptionTextView.resignFirstResponder();
    }
    
    func string(from placemark: CLPlacemark) -> String {
        var text = "";
        
        text.add(placemark.subThoroughfare, separatedBy: "");
        text.add(placemark.thoroughfare, separatedBy: ", ");
        text.add(placemark.locality, separatedBy: ", ");
        text.add(placemark.administrativeArea, separatedBy: " ");
        text.add(placemark.postalCode, separatedBy: ", ");
        text.add(placemark.country, separatedBy: ", ");
        return text;
    }
    
    func format(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date);
    }
    
    func show(image: UIImage) {
        
        imageView.hidden = false;
        imageView.image = image;
    //    imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260);
        addPhotoLabel.hidden = true;
        print(imageView.image?.size);
    }
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch (indexPath.section, indexPath.row) {
            case (0,0): return 88;
            case (1,_): return imageView.hidden ? 44 : 280;
            case (2,2):
            adressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000);
            adressLabel.sizeToFit();
            adressLabel.bounds.origin.x = view.bounds.size.width - adressLabel.frame.size.width - 15;
            
            return 85;
            default: return 44;
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController as! CategoryPickerViewController
            
            
            controller.selectedCategoryName = categoryName;
        }
    }
    
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue){
        let controller = segue.sourceViewController as! CategoryPickerViewController;
        categoryName = controller.selectedCategoryName;
        categoryLabel.text = categoryName;
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath;
        } else {
            return nil;
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder();
        } else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true);
            pickPhoto();
            print("Press")
        }
    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
       cell.backgroundColor = UIColor.blackColor();
        
        if let textLabel = cell.textLabel {
            textLabel.textColor = UIColor.whiteColor()
            textLabel.highlightedTextColor = textLabel.textColor;
        }
        
        if let detailLabel = cell.detailTextLabel {
            detailLabel.textColor = UIColor(white: 1.0, alpha: 0.4);
            detailLabel.highlightedTextColor = detailLabel.textColor;
        }
        
        //customize selection color
        let selectionView = UIView(frame: CGRect.zero);
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2);
        cell.selectedBackgroundView = selectionView;
        
        //customize address label
        if indexPath.row == 2 {
            let addressLabel = cell.viewWithTag(100) as! UILabel
            addressLabel.textColor = UIColor.whiteColor();
            addressLabel.highlightedTextColor = addressLabel.textColor;
        }
    }
}

extension LocationDetailsViewController:UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    func choosePhotoFromLibrary() {
        let imagePicker = MyImagePickerController();
        imagePicker.sourceType = .PhotoLibrary;
        imagePicker.delegate = self;
        imagePicker.allowsEditing = true;
        imagePicker.view.tintColor = view.tintColor;
        
        presentViewController(imagePicker, animated: true, completion: nil);
    }
    
    func takePhotoFromCamera() {
        let imagePicker = MyImagePickerController();
        imagePicker.sourceType = .Camera;
        imagePicker.delegate = self;
        imagePicker.allowsEditing = true;
        imagePicker.view.tintColor = view.tintColor;
        
        presentViewController(imagePicker, animated: true, completion: nil);
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        image = info[UIImagePickerControllerEditedImage] as? UIImage;
        if let editedImage = image {
            show(editedImage);
        }
        tableView.reloadData();
        dismissViewControllerAnimated(true, completion: nil);
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil);
    }
    
    func pickPhoto() {
        if true || MyImagePickerController.isSourceTypeAvailable(.Camera) {
            showPhotoMenu();
        } else {
            choosePhotoFromLibrary();
        }
    }
    
    func showPhotoMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil);
        alert.addAction(cancelAction);
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: {_ in self.takePhotoFromCamera()});
        alert.addAction(takePhotoAction);
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .Default, handler: {_ in self.choosePhotoFromLibrary()});
        alert.addAction(chooseFromLibraryAction);
        
        presentViewController(alert, animated: true, completion: nil);
    }

    
    
}
