//
//  Nearest.swift
//  TigerTrail
//
//  Created by Yazan Mimi on 7/3/19.
//  Copyright © 2019 Yazan Mimi SPE. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Contacts
import CoreLocation


class Nearest: UIViewController {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var controller: UISegmentedControl!
    // Defines the distance covered by the initial map from the center
    @IBAction func ChangeLbl(_ sender: Any) {
        if controller.selectedSegmentIndex == 0 {
            self.mapView.mapType = .standard
        }
        if controller.selectedSegmentIndex == 1 {
            self.mapView.mapType = .hybrid
        }

    }
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
        
        let i = navigationController?.viewControllers.firstIndex(of: self)
        let previousViewController = navigationController?.viewControllers[i!-1]

        guard var fileName = Bundle.main.path(forResource: "Hotspots" ,ofType: "json")
            else { return }

        if previousViewController?.title == "Campus Dining Map" {
            fileName = Bundle.main.path(forResource: "campusdining" ,ofType: "json")!
    }
        if previousViewController?.title == "Computer Clusters Map" {
            fileName = Bundle.main.path(forResource: "ComputerClusters" ,ofType: "json")!
        }
        
        if previousViewController?.title == "Campus Libraries Map" {
            fileName = Bundle.main.path(forResource: "libraries" ,ofType: "json")!
        }

        if previousViewController?.title == "Residential Colleges Map" {
            fileName = Bundle.main.path(forResource: "ResColleges" ,ofType: "json")!
        }
        
        if previousViewController?.title == "Residential Colleges Map" {
            fileName = Bundle.main.path(forResource: "ResColleges" ,ofType: "json")!
        }

        if previousViewController?.title == "Eating Clubs Map" {
            fileName = Bundle.main.path(forResource: "EatingClubs" ,ofType: "json")!
        }

        
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
        
        var minsite = sites[0]
        var minpoint = MKMapPoint(minsite.coordinate)
        var currentLocation: CLLocation!
        
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways){
            
            currentLocation = locationManager.location
        }

        let user = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        
        for i in 1...(sites.count - 1){
            if MKMapPoint(sites[i].coordinate).distance(to: MKMapPoint(user)) < MKMapPoint(minpoint.coordinate).distance(to: MKMapPoint(user)){
                minsite = sites[i]
                minpoint = MKMapPoint(minsite.coordinate)
            }
        }
        sites = [Site](repeating: minsite, count: 1)
//        sites[0] = minsite
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
        
        // automatically selects pin of nearest to display callout
            if mapView.annotations[0].title == "My Location" {
                mapView.selectAnnotation(mapView.annotations[1], animated: false)
            }
            else {
                mapView.selectAnnotation(mapView.annotations[0], animated: false)
            }
        

    }
    
    
    
    
}



extension Nearest: MKMapViewDelegate {
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




extension Nearest: CLLocationManagerDelegate {
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
