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
import AVFoundation


class CampusDining: UIViewController, UITableViewDelegate, UITableViewDataSource, AVSpeechSynthesizerDelegate {
    
    
    var selectedPin:MKPlacemark? = nil
    
    var directionsArray: [MKDirections] = []
    
    var coordinateto : CLLocationCoordinate2D? = nil
    
    var instructionsArray1: [MKRoute.Step] = []
    var instructionsArray: [String] = []
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instructionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as UITableViewCell
        
        cell.textLabel!.numberOfLines = 0;
        cell.textLabel?.lineBreakMode = .byWordWrapping
        
        cell.textLabel?.text = instructionsArray[indexPath.row]
        
        return cell
        
    }
    
    
    @IBOutlet weak var controller: UISegmentedControl!
    
    @IBAction func ChangeLbl(_ sender: Any) {
        if controller.selectedSegmentIndex == 0 {
            self.mapView.mapType = .standard
        }
        if controller.selectedSegmentIndex == 1 {
            self.mapView.mapType = .hybrid
        }

    }
    
    @IBOutlet weak var toLbl: UILabel!
    
    
    @IBOutlet weak var mode: UISegmentedControl!
    
    
    @IBAction func modea(_ sender: Any) {
        if mode.selectedSegmentIndex == 0 {
            getDirections(to: coordinateto!)
        }
        
        if mode.selectedSegmentIndex == 1 {
            getDirections(to: coordinateto!)
        }

    }
    
    
    @IBOutlet weak var Go: UIButton!
    
    @IBOutlet weak var infoTable: UITableView!
    
    let synth = AVSpeechSynthesizer()
    
    
    @IBAction func GoClicked(_ sender: Any) {
        var stringsi = ""
        for string in instructionsArray {
            let stringa = "\(string). "
            stringsi.append(stringa)
        }
        
        stringsi.removeFirst()
        stringsi.removeFirst()
        
        let utterance = AVSpeechUtterance(string: stringsi)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        //        utterance.rate = 0.4
        
        if String(Go.title(for: .normal)!) == "Go" {
            infoTable.isHidden = false
            infoTable.isUserInteractionEnabled = true
            synth.speak(utterance)
            
            Go.setTitle("End", for: .normal)
            Go.setBackgroundImage(UIImage(named: "red"), for: .normal)
            
        }
        else {
            infoTable.isHidden = true
            infoTable.isUserInteractionEnabled = false
            Go.setTitle("Go", for: .normal)
            Go.setBackgroundImage(UIImage(named: "green"), for: .normal)
            
            synth.stopSpeaking(at: .immediate)
            
        }

    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    
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
        guard let fileName = Bundle.main.path(forResource: "campusdining" ,ofType: "json")
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
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func round(_ num: Double, to places: Int) -> Double {
        let p = log10(abs(num))
        let f = pow(10, p.rounded() - Double(places) + 1)
        let rnum = (num / f).rounded() * f
        
        return rnum
    }
    
    
    struct ReversedGeoLocation {
        let name: String            // eg. Apple Inc.
        let streetName: String      // eg. Infinite Loop
        let streetNumber: String    // eg. 1
        let city: String            // eg. Cupertino
        let state: String           // eg. CA
        let zipCode: String         // eg. 95014
        let country: String         // eg. United States
        let isoCountryCode: String  // eg. US
        
        var formattedAddress: String {
            return """
            \(name),
            \(streetNumber) \(streetName),
            \(city), \(state) \(zipCode)
            \(country)
            """
        }
        
        // Handle optionals as needed
        init(with placemark: CLPlacemark) {
            self.name           = placemark.name ?? ""
            self.streetName     = placemark.thoroughfare ?? ""
            self.streetNumber   = placemark.subThoroughfare ?? ""
            self.city           = placemark.locality ?? ""
            self.state          = placemark.administrativeArea ?? ""
            self.zipCode        = placemark.postalCode ?? ""
            self.country        = placemark.country ?? ""
            self.isoCountryCode = placemark.isoCountryCode ?? ""
        }
    }
    
    
    
    
    @objc func getDirections(to coordinate2: CLLocationCoordinate2D){
        //        if let selectedPin = selectedPin {
        //            let mapItem = MKMapItem(placemark: selectedPin)
        //            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking]
        //            mapItem.openInMaps(launchOptions: launchOptions)
        //        }
        guard let location = locationManager.location?.coordinate else {
            return
        }
        let request = createDirectionsRequest(from: location, to: coordinate2)
        
        coordinateto = coordinate2
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        directions.calculate { [unowned self] (response, error) in
            //TODO: Handle error if needed
            guard let response = response else { return } //TODO: Show response not available in an alert
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                
                let siz = MKMapSize(width: route.polyline.boundingMapRect.width + 1000, height: route.polyline.boundingMapRect.height + 1000)
                let po = MKMapPoint(x: route.polyline.boundingMapRect.origin.x - 200, y: route.polyline.boundingMapRect.origin.y - 200)
                let ret = MKMapRect(origin: po, size: siz)
                self.mapView.setVisibleMapRect(ret, animated: true)
                
                self.toLbl.isHidden = false
                self.mode.isHidden = false
                self.Go.isHidden = false
                self.Go.isEnabled = true
                
                self.instructionsArray1 = route.steps
                
                
                
                if self.instructionsArray1.count > 0 {
                    for i in 0...(self.instructionsArray1.count - 1) {
                        self.instructionsArray.append("")
                        self.instructionsArray[i] = self.instructionsArray1[i].instructions
                    }
                }
                self.infoTable.reloadData()
                
                
                let di = Double(route.distance)*0.000621371
                
                var dis = ""
                
                if String(di).count > 6 {
                    dis = String(String(di).prefix(6))
                }
                else { dis = String(di)
                }
                
                let ti = Double(route.expectedTravelTime)/60.0
                
                var tis = ""
                
                if String(ti).count > 6 {
                    tis = String(String(ti).prefix(6))
                }
                else { tis = String(ti)
                }
                
                
                CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coordinate2.latitude, longitude: coordinate2.longitude)) { placemarks, error in
                    
                    guard let placemark = placemarks?.first else {
                        let errorString = error?.localizedDescription ?? "Unexpected Error"
                        print("Unable to reverse geocode the given location. Error: \(errorString)")
                        return
                    }
                    
                    let reversedGeoLocation = ReversedGeoLocation(with: placemark)
                    // Apple Inc.,
                    // 1 Infinite Loop,
                    // Cupertino, CA 95014
                    // United States
                    self.toLbl.text = "   To: \(reversedGeoLocation.streetNumber) \(reversedGeoLocation.streetName)   \n   Distance: \(dis) miles   \n   Expected Time: \(tis) minutes   "
                    
                }
                
                
                
            }
            
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = UIColor(red: 0.0, green: 122/255.0, blue: 255/255.0, alpha: 0.6)
        
        return renderer
    }
    
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D, to coordinate2: CLLocationCoordinate2D) -> MKDirections.Request {
        let destinationCoordinate       = coordinate2
        let startingLocation            = MKPlacemark(coordinate: coordinate)
        let destination                 = MKPlacemark(coordinate: destinationCoordinate)
        
        let request                     = MKDirections.Request()
        request.source                  = MKMapItem(placemark: startingLocation)
        request.destination             = MKMapItem(placemark: destination)
        
        //        request.transportType           = .walking
        if mode.selectedSegmentIndex == 0 {
            request.transportType = .walking
        }
        
        if mode.selectedSegmentIndex == 1 {
            request.transportType = .automobile
        }
        
        request.requestsAlternateRoutes = false
        
        return request
    }
    
    @objc func addAnnotation(gestureRecognizer:UIGestureRecognizer){
        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        
        
        _ = MKAnnotationView(annotation: annotation, reuseIdentifier: "b")
        
        //        let rev = ReversedGeoLocation(with: CLPlacemark(location: CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), name: "", postalAddress: CNPostalAddress()))
        
        
        let ann = Site(title: "  ", locationName: "", discipline: "", coordinate: newCoordinates)
        
        mapView.addAnnotation(ann)
        mapView.selectAnnotation(ann, animated: false)
        
    }
    
    
    // main
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoTable.delegate = self
        infoTable.dataSource = self
        
        synth.delegate = self
        
        
        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)))
        uilgr.minimumPressDuration = 1.0
        
        //IOS 9
        mapView.addGestureRecognizer(uilgr)
        
        
        
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



extension CampusDining: MKMapViewDelegate {
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
        //        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        //        location.mapItem().openInMaps(launchOptions: launchOptions)
        
        getDirections(to: location.coordinate)
        
        
        
    }
    
    func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
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
        
        button.addTarget(self, action: #selector((getDirections(to:))), for: .touchUpInside)
        
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
    
}




extension CampusDining: CLLocationManagerDelegate {
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

extension CampusDining: HandleMapSearch {
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
