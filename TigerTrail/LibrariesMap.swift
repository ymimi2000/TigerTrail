//
//  ComputerClusters.swift
//  TigerTrail
//
//  Created by Yazan Mimi on 6/26/19.
//  Copyright © 2019 Yazan Mimi SPE. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Contacts
import CoreLocation

class LibrariesMap: UIViewController {
    
    var selectedPin:MKPlacemark? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var controller: UISegmentedControl!
    
    @IBAction func ChangeLbl(_ sender: Any) {
        if controller.selectedSegmentIndex == 0 {
            self.mapView.mapType = .standard
        }
        if controller.selectedSegmentIndex == 1 {
            self.mapView.mapType = .hybrid
        }

    }
    

    // Defines the distance covered by the initial map from the center
    let distFromCenter: CLLocationDistance = 1000
    
    // creates an array of Sites
    var sites: [Site] = []
    
    var resultSearchController:UISearchController? = nil
    
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
        guard let fileName = Bundle.main.path(forResource: "libraries" ,ofType: "json")
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
    
    @objc func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
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
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        
        locationSearchTable.handleMapSearchDelegate = self
        
        
        
    }
}



extension LibrariesMap: MKMapViewDelegate {
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
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? SiteViews
        //        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        //        pinView?.pinTintColor = UIColor.orange
        //
        //        pinView?.image = UIImage(contentsOfFile: "cap")
        //
        ////        pinView?.image: String? {
        ////
        ////            if annotaion.title == "Campus Club" { return "campus" }
        ////            if title == "Cap & Gown Club" { return "cap" }
        ////            if title == "Cloister Inn" { return "cloister" }
        ////            if title == "Tiger Inn" { return "ti" }
        ////            if title == "Cannon Dial Elm Club" { return "cannon" }
        ////            if title == "Charter Club" { return "charter" }
        ////            if title == "Colonial Club" { return "colonial" }
        ////            if title == "Terrace Club" { return "terrace" }
        ////            if title == "Tower Club" { return "tower" }
        ////            if title == "Cottage Club" { return "cottage" }
        ////            if title == "Ivy Club" { return "ivy" }
        ////            if title == "Quadrangle Club" { return "quad" }
        ////            if isEqual(type: String.self, a: type, b: "Campus Dining") { return "din" }
        ////
        ////
        ////
        ////            return "whit"
        ////        }
        //
        //
        //
        pinView?.canShowCallout = true
        
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "Maps-icon"), for: .normal)
        button.addTarget(self, action: #selector((getDirections)), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
    
}




extension LibrariesMap: CLLocationManagerDelegate {
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

extension LibrariesMap: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        let street = placemark.postalAddress?.street
        let city = placemark.postalAddress?.city
        let state = placemark.administrativeArea
        
        
        
        annotation.subtitle = "\(street ?? ""), \(city ?? "") \(state ?? "")"
        
        
        let ann = Site.init(title: annotation.title!, locationName: annotation.subtitle ?? "", discipline: "", coordinate: CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
        
        
        mapView.addAnnotation(ann)
        if mapView.annotations[0].title == "My Location" {
            mapView.selectAnnotation(mapView.annotations[1], animated: false)
        }
        else {
            mapView.selectAnnotation(mapView.annotations[0], animated: false)
        }
        let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
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
