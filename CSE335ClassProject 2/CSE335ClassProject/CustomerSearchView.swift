//
//  CustomerSearchView.swift
//  CSE335ClassProject
//
//  Created by tlwood9 on 11/27/24.
//

import SwiftUI
import SwiftData
import Foundation

struct CustomerSearchView: View {
    private var modelContext:ModelContext;
    @ObservedObject private var viewManager = ViewManager.shared;
    //@ObservedObject private var c7Data: C7Linker;
    @State var screenName: String;
    @State private var searchText = "";
    @State private var sortedCustomers:[(String, Customer)];
    private let sampleFNames = ["Michelle", "Eric", "David", "Jason", "Linda", "Kim", "William", "Tom", "Nick", "Alexis"];
    private let sampleLNames = ["Brown", "Smith", "Daniels", "Diaz", "Frank", "Glover", "Harris", "Martinez", "Schneider", "Webb"];
    
    init(context:ModelContext, screenName:String, sortedCustomers:[(String, Customer)]) {
        self.modelContext = context;
        self.screenName = screenName;
        self.sortedCustomers = sortedCustomers
        print(self.sortedCustomers.count)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                //HEADER
                VStack {
                    HStack (alignment: .top) {
                        Spacer();
                        Text(screenName)
                            .font(.system(size: 36))
                            .fontWeight(.semibold)
                            .padding(.top, 6)
                            .padding(.leading, 68)
                        
                        Spacer();
                        navButton(icon: "ProfileIcon", targetPage: 4)
                            .padding(.trailing, 20);
                    }
                    .padding(.top, 50)
                    HStack {
                        //Spacer();
                        //navButton(icon: "FilterIcon", targetPage: 1) //placeholder, replace with actual filter
                        HeaderSearchBar(searchText: $searchText);
                        //Spacer();
                    }
                    .padding(.bottom, 10)
                    .padding(.horizontal, 30)
                }
                .background(CommonColors.MenuGray())
                //BODY CONTENT HERE
                
                NavigationStack {
                    List {
                        ForEach(searchResults) { cell in
                            NavigationLink {
                                CustomerDetailView(customer: viewManager.c7Data.customers[cell.customerID]!)
                            } label: {
                                cell
                            }
                        }
                    }
                }

                //FOOTER
                bottomBar();
            }
            
            
            //TOP LEFT DOMAIN SELECTOR
            //domainSelector();
        }
        .ignoresSafeArea()
    }
   
    var searchResults: [customerCell] {
        let targetDomain = viewManager.targetDomain.rawValue;
        var sortedCells = [customerCell]();
        for customer in sortedCustomers {
            let rawName = (customer.1.fName ?? "") + " " + (customer.1.lName ?? "");
            //filter out dummy accounts
            if (![" ", "Test ", "Donation Account ", "Damage Account", "Sample Account"].contains(rawName)) {
                let noAccentsName = rawName.folding(options: .diacriticInsensitive, locale: .current);
                let processedName = noAccentsName.lowercased();
                if (processedName.hasPrefix(searchText.lowercased())) {
                    if (customer.1.domain! == targetDomain || targetDomain == "All") {
                        sortedCells.append(customerCell(
                            customerID: customer.0,
                            fName: customer.1.fName ?? "",
                            lName: customer.1.lName ?? "",
                            state: customer.1.address?.stateCode ?? "",
                            domain: customer.1.domain!
                        ));
                    }
                }
            }
        }
        return sortedCells;
    }
}

struct customerCell: View, Identifiable {
    let id = UUID();
    let customerID:String;
    let fName:String;
    let lName:String
    let state:String;
    let domain:String;
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text("\(fName) \(lName)")
                        .font(Font.headline)
                    Spacer();
                }
                HStack {
                    Text(domain)
                        .font(Font.subheadline)
                    Spacer();
                }
            }
            Spacer();
            Text(state)
        }
        .frame(height: 50);
    }
}


