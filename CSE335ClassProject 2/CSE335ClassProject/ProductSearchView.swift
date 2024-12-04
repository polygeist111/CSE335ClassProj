//
//  ProductSearchView.swift
//  CSE335ClassProject
//
//  Created by tlwood9 on 11/26/24.
//

import SwiftUI
import SwiftData
import Foundation

struct ProductSearchView: View {
    private var modelContext:ModelContext;
    @ObservedObject private var viewManager = ViewManager.shared;
    @State var screenName: String;
    @State private var searchText = "";
    @State private var sortedProducts:[(String, Product)];
    
    init(context:ModelContext, screenName:String, sortedProducts:[(String, Product)]) {
        self.modelContext = context;
        self.screenName = screenName;
        self.sortedProducts = sortedProducts
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
                                ProductDetailView(product: viewManager.c7Data.products[cell.productID]!)
                            } label: {
                                cell
                            }
                        }
                    }
                }
                .background(CommonColors.ArchBlue())

                //FOOTER
                bottomBar();
            }
            
            
            //TOP LEFT DOMAIN SELECTOR
            //domainSelector();
             
        }
        .ignoresSafeArea()
    }
   
    var searchResults: [productCell] {
        let targetDomain = viewManager.targetDomain.rawValue;
        var sortedCells = [productCell]();
        for product in sortedProducts {
            let rawName = product.1.nameNoVintage();
            let noAccentsName = rawName.folding(options: .diacriticInsensitive, locale: .current);
            let processedName = noAccentsName.lowercased();
            if (processedName.hasPrefix(searchText.lowercased())) {
                if (product.1.domain! == targetDomain || targetDomain == "All") {
                    sortedCells.append(productCell(
                        productID: product.0,
                        name: product.1.nameNoVintage(),
                        vintage: product.1.vintage ?? 0,
                        image: product.1.image ?? "",
                        domain: product.1.domain!,
                        price: "$\(Double(product.1.variants[0].price).formatValue())"
                    ));
                }
            }
        }
        return sortedCells;
    }
}

struct productCell: View, Identifiable {
    //scrolling from https://www.youtube.com/watch?v=5odxbJETCFA
    let id = UUID();
    let productID:String;
    let name:String;
    let vintage:Int;
    let image:String;
    let domain:String;
    let price:String;
    @State var scrollText = false;
    @State var vintageString = "";
    var body: some View {
        HStack {
            //Image("NoImageIcon");
            urlImage(url: image)
                .frame(width: 48, height: 48)
            Spacer();
            VStack {
                HStack {
                    ViewThatFits(in: .horizontal) {
                        Text(name)
                            .font(Font.headline)
                        /*
                        Text(name)
                            .font(Font.headline)
                            .frame(width: 600)
                            .offset(x: scrollText ? 0 : 300)
                            .onAppear {
                                withAnimation(.linear(duration: 8)) {
                                    self.scrollText.toggle()
                                }
                            }
                         */
                    }
                    Spacer();
                }
                HStack {
                    Text(vintageString)
                        .font(Font.subheadline)
                        .onAppear {
                            vintageString = String(vintage);
                            if (vintageString == "0") {
                                vintageString = "NV";
                            }
                        }
                    Text(domain)
                        .font(Font.subheadline)
                    Spacer();
                }
            }
            Spacer();
            Text(price)
        }
        .frame(height: 50);
    }
}


