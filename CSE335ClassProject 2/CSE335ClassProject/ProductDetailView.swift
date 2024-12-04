//
//  ProductDetailView.swift
//  CSE335ClassProject
//
//  Created by Tucker Wood on 11/28/24.
//

import SwiftUI
import SwiftData
import Foundation

struct ProductDetailView: View {
    @ObservedObject private var viewManager = ViewManager.shared;
    @State var screenName: String = "";
    var vintageStr = "";
    let product:Product;
    
    init(product:Product) {
        self.product = product;
        if (product.vintage != nil) {
            vintageStr = "\(product.vintage ?? 0)";
        } else {
            vintageStr = "NV";
        }
    }
    
    var body: some View {
        ZStack {
            List {
                //HEADER
                //header(title: screenName);
                //BODY CONTENT HERE
                //Spacer();
                VStack(alignment: HorizontalAlignment.center) {
                    Spacer();
                    urlImage(url: product.image ?? "")
                        .frame(width: 128, height: 128)
                    Spacer();
                    HStack {
                        Spacer();
                        Text(product.name)
                            .font(Font.headline)
                        Spacer();
                    }
                    HStack {
                        Spacer();
                        Text(product.region ?? "No Region Listed")
                            .font(Font.subheadline)
                        Spacer();
                    }
                }
                VStack(spacing: 10) {
                    VStack(alignment: HorizontalAlignment.leading) {
                        Spacer();
                        Text(product.description?.htmlDecoded ?? "No provided description")
                        Spacer();
                        VStack(alignment: HorizontalAlignment.center) {
                            HStack {
                                Spacer();
                                Text(product.formatPrices() + "\n")
                                    .font(Font.headline)
                                Spacer();
                            }
                        }
                    }
                }
                //Spacer();
    
                //FOOTER
                //bottomBar();
            }
            
            
            //TOP LEFT DOMAIN SELECTOR
            //domainSelector();
        }
        .ignoresSafeArea()
    }
}


