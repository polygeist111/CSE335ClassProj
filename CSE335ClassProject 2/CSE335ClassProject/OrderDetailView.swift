//
//  OrderDetailView.swift
//  CSE335ClassProject
//
//  Created by Tucker Wood on 11/29/24.
//

import SwiftUI
import SwiftData
import Foundation

struct OrderDetailView: View {
    @ObservedObject private var viewManager = ViewManager.shared;
    @State var screenName: String = "";
    let order:Order;
    var productCells = [productCell]();
    var totalQuantity = 0;
    
    init(order:Order) {
        self.order = order;
        for orderItem in order.items {
            var product = viewManager.c7Data.products[orderItem.productID ?? ""]
            if (product == nil) {
                product = viewManager.c7Data.productBySKU(sku: orderItem.sku, domain: order.domain!)
            }
            if (product == nil) {
                print("Invalid SKU in order record: \(orderItem.sku)");
                continue;
            }
            print(orderItem.productID ?? "No Valid ProductID")
            print(orderItem.sku)
            totalQuantity += orderItem.quantity;
            productCells.append(productCell(
                productID: orderItem.productID ?? "",
                name: product!.nameNoVintage(),
                vintage: product!.vintage ?? 0,
                image: product!.image ?? "",
                domain: "",
                price: "$\(Double(product!.variants[0].price * orderItem.quantity).formatValue()) (\(orderItem.quantity))"
            ));
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
                    HStack {
                        Spacer();
                        Text(viewManager.c7Data.customers[order.customerID ?? ""]?.name() ?? "No Associated Customer")
                            .font(Font.headline)
                        Spacer();
                    }
                    HStack {
                        Spacer();
                        Text(order.domain!)
                            .font(Font.subheadline)
                        Spacer();
                    }
                    HStack {
                        Spacer();
                        Text(order.formattedDate() + "\n")
                            .font(Font.subheadline)
                        Spacer();
                    }
                }
                VStack(spacing: 10) {
                    ForEach(productCells) { cell in
                        cell;
                    }
                }
                VStack(alignment: HorizontalAlignment.leading) {
                    Text("\nTotal Items: \(totalQuantity)");
                    Text("---");
                    Text("Subtotal: $\(Double(order.subTotal).formatValue())");
                    Text("Tax: $\(Double(order.taxTotal).formatValue())");
                    Text("Shipping: $\(Double(order.shipTotal).formatValue())");
                    Text("Grand Total: $\(Double(order.total).formatValue())\n");
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


