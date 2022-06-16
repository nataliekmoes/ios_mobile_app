//
//  MapViewController.swift
//  CSE335_Project
//

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchItem: UITextField!
    @IBOutlet weak var map: MKMapView!
    var myLocationManager : CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        myLocationManager.requestWhenInUseAuthorization()
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) {
            myLocationManager.startUpdatingLocation()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let coordinates = myLocationManager.location?.coordinate {
            print(coordinates)
            // let coordinates = CLLocationCoordinate2D(latitude: 33.448376, longitude: -112.074036)
            let span = MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion.init(center: coordinates, span: span)
            self.map.mapType = MKMapType.standard
            self.map.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
            self.map.addAnnotation(annotation)
            
        }
    }
    
    
    @IBAction func search(_ sender: Any) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = self.searchItem.text
        request.region = self.map.region
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            guard let response = response else { return }
            print( response.mapItems )
            var matchingItems:[MKMapItem] = []
            matchingItems = response.mapItems
            for i in 1...matchingItems.count - 1 {
                let place = matchingItems[i].placemark
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = place.coordinate
                annotation.title = place.name
                annotation.subtitle = place.title
                self.map.addAnnotation(annotation)
            }
        }
    }
    
    
}
