//
//  SiteViews.swift
//  CampusMaps
//
//  Created by Yazan Mimi on 6/20/19.
//  Copyright © 2019 Yazan Mimi. All rights reserved.
//

import Foundation
import MapKit

class SiteViews: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            // 1
            guard let Site = newValue as? Site else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            // 2
            markerTintColor = Site.markerTintColor
//            glyphText = String(Site.discipline.first!)
            
            if let imageName = Site.imageName {
                glyphImage = UIImage(named: imageName)
                
            } else {
                glyphImage = nil
            }

            
        }
    }
}

class SiteView: MKAnnotationView {
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

    override var annotation: MKAnnotation? {
        willSet {
            guard let Site = newValue as? Site else {return}
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                    size: CGSize(width: 30, height: 30)))
            mapsButton.setBackgroundImage(UIImage(named: "Maps-icon"), for: UIControl.State())
            rightCalloutAccessoryView = mapsButton

            let detailLabel = UILabel()
            detailLabel.numberOfLines = 0
            detailLabel.font = detailLabel.font.withSize(12)
            detailLabel.text = Site.subtitle
            detailCalloutAccessoryView = detailLabel

            if let imageName = Site.imageName {
                image = UIImage(named: imageName)
                image = resizeImage(image: image ?? UIImage(), newWidth: 35)
            } else {
                image = nil
            }
        }
    }
}

