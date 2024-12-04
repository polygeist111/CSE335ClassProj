//
//  DashboardView.swift
//  CSE335ClassProject
//
//  Created by tlwood9 on 11/25/24.
//

import SwiftUI
import SwiftData
import Foundation

struct DashboardView: View {
    private var modelContext:ModelContext;
    @ObservedObject private var viewManager = ViewManager.shared;
    @State var screenName: String;
    
    init(context:ModelContext, screenName:String) {
        self.modelContext = context;
        self.screenName = screenName;
    }
    
    var body: some View {
        ZStack {
            //Color.white
            VStack {
                //HEADER
                header(title:screenName);
                
                //BODY CONTENT HERE
                Spacer();
                VStack(spacing: 4) {
                    Spacer();
                    dashBoardTile(title: "D2C",
                                  ytd: "YTD: $\(viewManager.c7Data.d2cYTDSales.formatValue())",
                                  sixMonthAvg: "Monthly: $\(viewManager.c7Data.d2c6MonthlyAvgSales.formatValue(division: 6.0))",
                                  customers: "\(viewManager.c7Data.customers.filter({$0.value.domain == "D2C"}).count)",
                                  margin: viewManager.c7Data.d2cYTDMargin
                    );
                    Spacer();
                    dashBoardTile(title: "Trade",
                                  ytd: "YTD: $\(viewManager.c7Data.tradeYTDSales.formatValue())",
                                  sixMonthAvg: "Monthly: $\(viewManager.c7Data.trade6MonthlyAvgSales.formatValue(division: 6.0))",
                                  customers: "\(viewManager.c7Data.customers.filter({$0.value.domain == "Trade"}).count)",
                                  margin: viewManager.c7Data.tradeYTDMargin
                    );
                    Spacer();
                    dashBoardTile(title: "Combined",
                                  ytd: "YTD: $\((viewManager.c7Data.d2cYTDSales + viewManager.c7Data.tradeYTDSales).formatValue())",
                                  sixMonthAvg: "Monthly: $\((viewManager.c7Data.d2c6MonthlyAvgSales + viewManager.c7Data.trade6MonthlyAvgSales).formatValue(division: 6.0))",
                                  customers: "\(viewManager.c7Data.customers.count)",
                                  margin: viewManager.c7Data.combinedYTDMargin
                    );
                    Spacer();
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

