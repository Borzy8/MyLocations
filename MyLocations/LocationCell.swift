//
//  LocationCell.swift
//  MyLocations
//
//  Created by Borzy on 28.08.18.
//  Copyright © 2018 Borzy. All rights reserved.
//

import UIKit
import CoreLocation

class LocationCell: UITableViewCell {

   
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Cell customization
        backgroundColor = UIColor.blackColor();
        descriptionLabel.textColor = UIColor.whiteColor();
        descriptionLabel.highlightedTextColor = UIColor.whiteColor();
        addressLabel.textColor = UIColor.whiteColor();
        addressLabel.highlightedTextColor = UIColor.whiteColor();
        
        //Selected cell color customization
        
        let selectionView = UIView(frame: CGRect.zero);
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2);
        selectedBackgroundView = selectionView;
        
        //thumbnail customization
        
        photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2;
        photoImageView.clipsToBounds = true;
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 50);
        
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(for location: Location) {
        if location.locationDescription.isEmpty {
            descriptionLabel.text = "(No Description)"
        } else {
            descriptionLabel.text = location.locationDescription
        }
        
        if let placemark = location.placemark {
            var text = "";
            text.add(placemark.subThoroughfare);
            text.add(placemark.thoroughfare, separatedBy: " ");
            text.add(placemark.locality, separatedBy: ", ");
            addressLabel.text = text;
        } else {
            addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude!, location.longitude!);
        }
        photoImageView.image = thumbnail(_for: location);
    }
    
    func thumbnail(_for location: Location) -> UIImage {
        if location.hasPhoto, let image = location.photoImage {
            return image.resizedImage(withBounds: CGSize(width: 52, height: 52));
        }
        return UIImage(named: "No Photo")!;
    }
}
