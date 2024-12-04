//
//  OrderSearchView.swift
//  CSE335ClassProject
//
//  Created by tlwood9 on 11/27/24.
//

import SwiftUI
import SwiftData
import Foundation

struct OrderSearchView: View {
    private var modelContext:ModelContext;
    @ObservedObject private var viewManager = ViewManager.shared;
    //@ObservedObject private var c7Data: C7Linker;
    @State var screenName: String;
    @State private var searchText = "";
    @State private var sortedOrders:[(String, Order)];
    
    init(context:ModelContext, screenName:String, sortedOrders:[(String, Order)]) {
        self.modelContext = context;
        self.screenName = screenName;
        self.sortedOrders = sortedOrders
        //print(self.sortedProducts.count)
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
                                OrderDetailView(order: viewManager.c7Data.orders[cell.orderID]!);
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
   
    var searchResults: [orderCell] {
        let targetDomain = viewManager.targetDomain.rawValue;
        var sortedCells = [orderCell]();
        for order in sortedOrders {
            let targetCustomer = viewManager.c7Data.customers[order.1.customerID ?? ""];
            let fName = targetCustomer?.fName ?? "";
            let lName = targetCustomer?.lName ?? "";
            let rawName = fName + " " + lName;
            if (![" ", "Test ", "Donation Account ", "Damage Account", "Sample Account"].contains(rawName)) {
                let noAccentsName = rawName.folding(options: .diacriticInsensitive, locale: .current);
                let processedName = noAccentsName.lowercased();
                if (processedName.hasPrefix(searchText.lowercased())) {
                    if (order.1.domain! == targetDomain || targetDomain == "All") {
                        var totalQuantity = 0;
                        for item in order.1.items {
                            totalQuantity += item.quantity;
                        }
                        sortedCells.append(orderCell(
                            orderID: order.0,
                            customerID: order.1.customerID ?? "",
                            name: rawName,
                            domain: order.1.domain!,
                            price: "$\(Double(order.1.subTotal).formatValue())",
                            quantity: "\(totalQuantity)",
                            date: order.1.formattedDate()
                        ));
                    }
                }
            }
        }
        return sortedCells;
    }
}

struct orderCell: View, Identifiable {
    let id = UUID();
    let orderID:String;
    let customerID:String;
    let name:String;
    let domain:String;
    let price:String;
    let quantity:String;
    let date:String;
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text(name)
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
            VStack {
                HStack {
                    Spacer()
                    Text("\(price) (\(quantity))")
                }
                HStack {
                    Spacer()
                    Text(date)
                }
            }
        }
        .frame(height: 50);
    }
}


