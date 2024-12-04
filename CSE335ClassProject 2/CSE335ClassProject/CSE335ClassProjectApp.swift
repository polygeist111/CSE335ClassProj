//
//  CSE335ClassProjectApp.swift
//  CSE335ClassProject
//
//  Created by tlwood9 on 10/29/24.
//

import SwiftUI
import SwiftData

@main
struct CSE335ClassProjectApp: App {
    //@StateObject private var viewManager = ViewManager();
    @ObservedObject private var viewManager = ViewManager.shared;
    //@StateObject private var c7Linker = C7Linker();
    let container: ModelContainer;
    init() {
            do {
                container = try ModelContainer(for: CustomNote.self);
                viewManager.context = container.mainContext;
            } catch {
                fatalError("ActivityRecord container creation failed");
            }
        }
    
    var body: some Scene {
        WindowGroup {
            Group {
                //this technique for lateral rather than stack navigation found here: https://medium.com/@jaykar.parmar/changing-the-root-view-in-swiftui-5aaaf1c1d66
                switch viewManager.displayedRoot {
                case .dashboard:
                    if (viewManager.c7Data.doneLoading) {
                        DashboardView(context: container.mainContext, screenName: "Dashboard");
                    } else {
                        LoadingView();
                    }
                case .products:
                    ProductSearchView(context: container.mainContext, screenName: "Products", sortedProducts: viewManager.c7Data.getSortedProducts());
                case .customers:
                    CustomerSearchView(context: container.mainContext, screenName: "Customers", sortedCustomers: viewManager.c7Data.getSortedCustomers());
                case .orders:
                    OrderSearchView(context: container.mainContext, screenName: "Orders", sortedOrders: viewManager.c7Data.getSortedOrders());
                case .profile:
                    ProfileView(context: container.mainContext, screenName: "Profile");
                case .customerMap:
                    CustomerLocationView(context: container.mainContext, screenName: "Cust. Map");
                }
            }
        }
        .modelContainer(container);
    }
}
