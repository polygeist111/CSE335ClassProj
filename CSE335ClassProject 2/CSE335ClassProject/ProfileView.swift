//
//  ProfileView.swift
//  CSE335ClassProject
//
//  Created by tlwood9 on 11/27/24.
//

import SwiftUI
import SwiftData
import Foundation

struct ProfileView: View {
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
                    Spacer();
                    Text("Welcome, User!")
                        .font(Font.headline)
                    //api call details
                    VStack(spacing: 5) {
                        Text("API Summary:")
                            .font(Font.headline);
                        Text("D2C Customers:    \(viewManager.c7Data.customers.filter({$0.value.domain == "D2C"}).count)");
                        Text("Trade Customers:  \(viewManager.c7Data.customers.filter({$0.value.domain == "Trade"}).count)");
                        Text("D2C Products:    \(viewManager.c7Data.products.filter({$0.value.domain == "D2C"}).count)");
                        Text("Trade Products:  \(viewManager.c7Data.products.filter({$0.value.domain == "Trade"}).count)");
                        Text("D2C Orders:    \(viewManager.c7Data.orders.filter({$0.value.domain == "D2C"}).count)");
                        Text("Trade Orders:  \(viewManager.c7Data.orders.filter({$0.value.domain == "Trade"}).count)");
                    }
                    Spacer();
                    VStack(spacing: 5) {
                        Text("App built by Tucker Wood for ASU CSE 335")                            .multilineTextAlignment(TextAlignment.center)
                            .font(Font.caption)
                        Text("Sample data generously provided by\nArchetyp Alpine Wines via Commerce7 APIs")
                            .multilineTextAlignment(TextAlignment.center)
                            .font(Font.caption)
                        Text("All personally identifying information has\nbeen anonymized, and location (city, zipcode)\nis randomized on each run")
                            .multilineTextAlignment(TextAlignment.center)
                            .font(Font.caption)
                        Text("Map Icon by Freepik\nhttps://www.flaticon.com/free-icons/location")
                            .multilineTextAlignment(TextAlignment.center)
                            .font(Font.caption)
                        Text("Basket Icon by Freepik\nhttps://www.flaticon.com/free-icons/shopping-basket")
                            .multilineTextAlignment(TextAlignment.center)
                            .font(Font.caption)
                        Text("Pallet Icon by PixelPerfect\nhttps://www.flaticon.com/free-icons/pallet")
                            .multilineTextAlignment(TextAlignment.center)
                            .font(Font.caption)
                        Text("Circles Icon by UniconLabs\nhttps://www.flaticon.com/free-icons/combination")
                            .multilineTextAlignment(TextAlignment.center)
                            .font(Font.caption)
                        Text("Ghost Icon: My own personal design/logo")
                            .multilineTextAlignment(TextAlignment.center)
                            .font(Font.caption)
                        Text("All other icons from Figma Simple Design System")
                            .multilineTextAlignment(TextAlignment.center)
                            .font(Font.caption)
                    }
                    .frame(width: 340)
                    .padding(10)
                    Spacer();
                    /*
                    Text("Select Theme");
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(CommonColors.ArchBlue())
                        HStack(spacing: 0) {
                            Button(action: {
                                viewManager.setTheme(themeIn: "Light");
                            },
                                label: {
                                    ZStack {
                                        Circle()
                                            .fill(CommonColors.ArchLightBlue())
                                            .hidden(viewManager.currentTheme.rawValue != "Light")
                                            
                                        Image("NoImageIcon")
                                            .resizable()
                                            .frame(width: 32, height: 32);
                                    }
                                    .frame(width: 48, height: 48);
                                }
                            );
                            Button(action: {
                                viewManager.setTheme(themeIn: "Dark");
                            },
                                label: {
                                    ZStack {
                                        Circle()
                                            .fill(CommonColors.ArchLightBlue())
                                            .hidden(viewManager.currentTheme.rawValue != "Dark")
                                            
                                        Image("NoImageIcon")
                                            .resizable()
                                            .frame(width: 32, height: 32);
                                    }
                                    .frame(width: 48, height: 48);
                                }
                            );
                        }
                        .frame(width: 96, height: 48)
                        .fixedSize()
                    }
                    .frame(width: 96, height: 48)
                    .fixedSize()
                    Spacer();
                     */
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


