//
//  ComputerClusters.swift
//  TigerTrail
//
//  Created by Will Stevens on 6/26/19.
//  Copyright © 2019 Mwad Saleh SPE. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Contacts
import CoreLocation

class ResidentialColleges: UIViewController {
    
    
    @IBOutlet var mapView: MKMapView!
    // Defines the distance covered by the initial map from the center
    let distFromCenter: CLLocationDistance = 1000
    
    // creates an array of Sites
    var sites: [Site] = []
    
    // location manager reference
    let locationManager = CLLocationManager()
    
    
    // Centers map about given location
    func mapCenter(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: distFromCenter, longitudinalMeters: distFromCenter)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            // setup our location manager then check location authorization
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // throw an alert to tell the user what's wrong
        }
    }
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            // Most relevant one
            mapView.showsUserLocation = true
            centerMapOnUserLocation()
            locationManager.startUpdatingLocation()
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // i.e parental control
            break
        case .authorizedAlways:
            // prob won't use
            break
        @unknown default:
            break
        }
    }
    
    
    func centerMapOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: distFromCenter, longitudinalMeters: distFromCenter)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // helper method
    func loadSavedData() {
        // 1
        guard let fileName = Bundle.main.path(forResource: "ResColleges" ,ofType: "json")
            else { return }
        let optionalData = try? Data(contentsOf: URL(fileURLWithPath: fileName))
        
        guard
            let data = optionalData,
            // 2
            let json = try? JSONSerialization.jsonObject(with: data),
            // 3
            let dictionary = json as? [String: Any],
            // 4
            let works = dictionary["data"] as? [[Any]]
            else { return }
        // 5
        let validWorks = works.compactMap { Site(json: $0) }
        sites.append(contentsOf: validWorks)
    }
    
    
    // main
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        mapView.register(SiteView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        // set initial location in Princeton University
        let initialCenter = CLLocation(latitude: 40.3431, longitude: -74.6551)
        mapCenter(location: initialCenter)
        mapView.delegate = self
        loadSavedData()
        mapView.addAnnotations(sites)
        checkLocationServices()
    }
    
    
    
    
}



extension ResidentialColleges: MKMapViewDelegate {
    //        // 1
    //        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    //            // 2
    //            guard let annotation = annotation as? Site else { return nil }
    //            // 3
    //            let identifier = "marker"
    //            var view: MKMarkerAnnotationView
    //            // 4
    //            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
    //                as? MKMarkerAnnotationView {
    //                dequeuedView.annotation = annotation
    //                view = dequeuedView
    //            } else {
    //                // 5
    //                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
    //                view.canShowCallout = true
    //                view.calloutOffset = CGPoint(x: -5, y: 5)
    //                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    //            }
    //            return view
    //        }
    //
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Site
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
    
}




extension ResidentialColleges: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: distFromCenter, longitudinalMeters: distFromCenter)
        mapView.setRegion(region, animated: true)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}
/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */
