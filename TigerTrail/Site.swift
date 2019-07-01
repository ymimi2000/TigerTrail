//
//  Site.swift
//  TigerTrail
//
//  Created by Will Stevens on 6/26/19.
//  Copyright © 2019 Mwad Saleh SPE. All rights reserved.
//

import Foundation
import MapKit
import Contacts



class Site: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    let type: Any
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        self.type = ""
        super.init()
    }
    
    init?(json: [Any]) {
        // 1
        self.title = json[2] as? String ?? "No Title"
        self.locationName = json[1] as! String
        self.discipline = json[1] as! String
        self.type = json[0]
        // 2
        if let latitude = Double(json[3] as! String),
            let longitude = Double(json[4] as! String) {
            self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            self.coordinate = CLLocationCoordinate2D()
        }
    }
    
    
    var subtitle: String? {
        return locationName
    }
    
    // Annotation right callout accessory opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
    
    // markerTintColor for location name: Whitman, Wilson, Rocky, Mathey...
    var markerTintColor: UIColor  {
        switch locationName {
        case "Butler College":
            return .blue
        case "Forbes College":
            return .red
        case "Mathey College":
            return .purple
        case "Rockefeller College":
            return .green
        case "Whitman College":
            return .cyan
        case "Wilson College":
            return .orange
        default:
            return .green
        }
    }
    
    func isEqual<T: Equatable>(type: T.Type, a: Any, b: Any) -> Bool {
        guard let a = a as? T, let b = b as? T else { return false }
        
        return a == b
    }
    
    var imageName: String? {
        if locationName == "Butler College" { return "butler" }
        if locationName == "Forbes College" { return "forbes" }
        if locationName == "Mathey College" { return "mathey" }
        if locationName == "Rockefeller College" { return "rocky" }
        if locationName == "Whitman College" { return "whit" }
        if locationName == "Wilson College" { return "wilson" }
        if isEqual(type: String.self, a: type, b: "Hotspot") { return "hotspot" }
        if locationName == "Computer Cluster" { return "cos" }
        if isEqual(type: String.self, a: type, b: "Library") { return "library" }
        if title == "Campus Club" { return "campus" }
        if title == "Cap & Gown Club" { return "cap" }
        if title == "Cloister Inn" { return "cloister" }
        if title == "Tiger Inn" { return "ti" }
        if title == "Cannon Dial Elm Club" { return "cannon" }
        if title == "Charter Club" { return "charter" }
        if title == "Colonial Club" { return "colonial" }
        if title == "Terrace Club" { return "terrace" }
        if title == "Tower Club" { return "tower" }
        if title == "Cottage Club" { return "cottage" }
        if title == "Ivy Club" { return "ivy" }
        if title == "Quadrangle Club" { return "quad" }
        

        
        return "whit"
    }
    
    
}
