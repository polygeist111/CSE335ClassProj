//
//  CustomerLocationView.swift
//  CSE335ClassProject
//
//  Created by Tucker Wood on 11/30/24.
//

import SwiftUI
import SwiftData
import Foundation
import MapKit

struct CustomerLocationView: View {
    private var modelContext:ModelContext;
    @ObservedObject private var viewManager = ViewManager.shared;
    @State var screenName: String;
    @State private var position:MapCameraPosition = .region(MKCoordinateRegion(center: Locations.defaultCenter, span: Locations.defaultSpan));
    init(context:ModelContext, screenName:String) {
        self.modelContext = context;
        self.screenName = screenName;
    }
    
    var body: some View {
        ZStack {
            VStack {
                //HEADER
                header(title: screenName);
                
                //BODY CONTENT HERE
                Spacer();
                VStack {
                    Map(position: $position) {
                        //ForEach(viewManager.locations.markers.sorted(by: {$0.key < $1.key}), id: \.self) { key, value in
                        ForEach(viewManager.c7Data.locations.markers.sorted(by: {$0.key < $1.key}), id: \.key) { marker in
                            //Marker("\(marker.value.count)", coordinate: marker.value.coords);
                            Annotation(marker.value.name, coordinate: marker.value.coords) {
                                ZStack {
                                    Circle()
                                        .fill(CommonColors.ArchBlue())
                                        .frame(width: 32, height: 32)
                                    Text("\(marker.value.count)")
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                    /*
                    .onMapCameraChange { cameraContext in
                        print("Camera Changed")
                        /*
                        let n = cameraContext.region.center.latitude + cameraContext.region.span.latitudeDelta * 0.5;
                        let s = cameraContext.region.center.latitude - cameraContext.region.span.latitudeDelta * 0.5;
                        let e = cameraContext.region.center.longitude + cameraContext.region.span.longitudeDelta * 0.5;
                        let w = cameraContext.region.center.longitude - cameraContext.region.span.longitudeDelta * 0.5;
                        locations.getPlaces(n: n, e: e, s: s, w: w);
                         */
                    }
                     */
                }
                Spacer();
                
                //FOOTER
                bottomBar();
            }
            
            
            //TOP LEFT DOMAIN SELECTOR
            //domainSelector();
             
        }
        .ignoresSafeArea()
    }
}


