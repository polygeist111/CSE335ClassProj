//
//  ContentView.swift
//  CSE335ClassProject
//
//  Created by tlwood9 on 10/29/24.
//

//this view is essentially just a template for any of the major navigable views
import SwiftUI
import SwiftData
import Foundation

struct ContentView: View {
    private var modelContext:ModelContext;
    @ObservedObject private var viewManager = ViewManager.shared;
    @State var screenName: String;
    
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
                VStack(spacing: 10) {
                    //api call details
                    NavigationSplitView {
                        Text("D2C Customers:    \(viewManager.c7Data.customers.filter({$0.value.domain == "D2C"}).count)");
                        Text("Trade Customers:  \(viewManager.c7Data.customers.filter({$0.value.domain == "Trade"}).count)");
                        Text("D2C Products:    \(viewManager.c7Data.products.filter({$0.value.domain == "D2C"}).count)");
                        Text("Trade Products:  \(viewManager.c7Data.products.filter({$0.value.domain == "Trade"}).count)");
                        Text("D2C Orders:    \(viewManager.c7Data.orders.filter({$0.value.domain == "D2C"}).count)");
                        Text("Trade Orders:  \(viewManager.c7Data.orders.filter({$0.value.domain == "Trade"}).count)");
                    } detail: {
                        Text("Select an item")
                    }
                }
                Spacer();
                
                //FOOTER
                bottomBar();
            }
            
            
            //TOP LEFT DOMAIN SELECTOR
            domainSelector();
             
        }
        .ignoresSafeArea()
    }
}


