//
//  Locations.swift
//  CSE335ClassProject
//
//  Created by Tucker Wood on 11/30/24.
//
//  Derived from my work in Lab 8
import Foundation
import SwiftUI
import MapKit

@Observable class Locations {
    //var places:[Place] = [Place]();
    //var inited:Bool = false;

    //static var n:Double?;
    //static var s:Double?;
    //static var e:Double?;
    //static var w:Double?;
    
    public static let defaultLocation = CLLocationCoordinate2D(
        latitude: 45.523064,
        longitude: -122.6784
    )
    
    public static let defaultCenter = CLLocationCoordinate2D(
        latitude: 45.423064,
        longitude: -122.5784
    )
    
    public static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5);
    
    var region = MKCoordinateRegion(
        center: defaultLocation,
        span: defaultSpan
    )
    var markers:[String:Location] = ["Portland, OR": Location(name:"Portland, OR", coords:Locations.defaultLocation, count: 1)];
    
    init() {
    }
    
    func setDefaults() {
        region.center = Locations.defaultLocation;
        region.span = Locations.defaultSpan;
        markers = ["Portland, OR": Location(name:"Portland, OR", coords:Locations.defaultLocation, count: 1)];
    }
    
    func addMarker(cityState:String) {
        if (markers.contains(where: {$0.key == cityState})) {
            markers[cityState]?.count += 1;
        } else {
            markers[cityState] = Location(name: cityState, coords: nil, count: 1)
        }
    }
    
    class Location: Identifiable {
        let id = UUID();
        let name:String;
        var coords:CLLocationCoordinate2D;
        var count:Int;
        
        init(name: String, coords: CLLocationCoordinate2D?, count: Int) {
            self.name = name
            self.count = count
            if (coords != nil) {
                self.coords = coords!
            } else {
                self.coords = Locations.defaultLocation;
                //fixCoords(name: name)
                getCoordinateFrom(address: name) { coordinate, error in
                    guard let coordinate = coordinate, error == nil else { return }
                    // don't forget to update the UI from the main thread
                    DispatchQueue.main.async {
                        self.setCoords(coordsIn: coordinate)
                        //print(address, "Location:", coordinate) // Rio de Janeiro, Brazil Location: CLLocationCoordinate2D(latitude: -22.9108638, longitude: -43.2045436)
                    }

                }
            }
        }
        
        func setCoords(coordsIn: CLLocationCoordinate2D) {
            self.coords = coordsIn;
        }
        
        func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
            CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
        }
    }
    
    //struct Geonames: Codable {
    //    var geonames:[Place];
    //}
}
