//
//  C7Linker.swift
//  CSE335ClassProject
//
//  Created by tlwood9 on 10/29/24.
//
//C7 API Docs: https://developer.commerce7.com/docs/products

import Foundation
import SwiftUI
//import MapKit

class C7Linker: ObservableObject {
    @Published var customers = [String: Customer]();
    @Published var customerFilterTerms = {
        var state = [String]();
        var ltv = [9999, 49999, 99999, 999999]; //lifetime value in cents
        //most recent activity?
    }
    @Published var locations:Locations = Locations();

    @Published var products = [String: Product]();
    @Published var productFilterTerms = {
        var vintages = [Int]();
        var vendor = [String]();
        var country = [String]();
        var priceThreshold = [999, 1999, 2999, 5999]; //in cents
        //var invLocation = [String]();
    }
    @Published var orders = [String: Order]();
    @Published var orderFilterTerms = {
        var bottleCount = [6, 12, 24, 48, 96, 192];
        var valueThreshold = [4999, 9999, 49999, 99999, 999999];
    }
    
    //ytd is based on subtotal
    //monthly is average of last 6 months
    //margin is ytd subtotal / ytd cost of goods
    @Published var d2cYTDSales = 0.0;
    @Published var d2c6MonthlyAvgSales = 0.0;
    var d2cYTDCost = 0.0;
    @Published var d2cYTDMargin = 0.0;
    
    @Published var tradeYTDSales = 0.0;
    @Published var trade6MonthlyAvgSales = 0.0;
    var tradeYTDCost = 0.0;
    @Published var tradeYTDMargin = 0.0;
    
    @Published var combinedYTDMargin = 0.0;
    
    var firstLoaded = false;
    @Published var doneLoading = false;
    
    //date handling with c7
    let dateFormatter = DateFormatter();
        
    private let basic = "Basic aW9zLXByb3RvdHlwZS1kYXNoYm9hcmQ6MXpwSVIwaURndkJZdmJZdzR6a2RvRnRkUktKZUU3SjU1ck5BQ3Nsa0dyemdsaThPYlBjQTNjNmpDd1BkNWxtdQ==";
    private let d2c = "archetyp";
    private var trade = "archetyp-distribution";
    
    private let sampleFNames = ["Michelle", "Eric", "David", "Jason", "Linda", "Kim", "William", "Tom", "Nick", "Alexis"];
    private let sampleLNames = ["Brown", "Smith", "Daniels", "Diaz", "Frank", "Glover", "Harris", "Martinez", "Schneider", "Webb"];
    private let sampleCityNames = ["Portland", "Hillsboro", "Salem", "Lake Oswego", "Multnomah Village", "Canby", "Happy Valley", "Gresham"];
    private let sampleZipCodes = ["97221", "97034", "97034"]
    
    
    init() {
        dateFormatter.locale = Locale(identifier: "en_US_POSIX");
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss";
        getCustomers(cursor: "start", domain: "D2C");
        getCustomers(cursor: "start", domain: "Trade");
        getProducts(cursor: "start", domain: "D2C");
        getProducts(cursor: "start", domain: "Trade");
        //getProducts calls its respective getOrder
    }
    
    func productBySKU(sku:String, domain:String) -> Product? {
        let productDictItem = self.products.filter({$0.value.domain == domain}).first(where: {
            $1.variants.contains(where: {$0.sku == sku})
        });
        let productItem = productDictItem?.value
        return productItem;
    }
    
    func getSortedCustomers() -> [(String, Customer)]{
        //sorts by lName, then fName, then domain
        return customers.sorted {lhs, rhs -> Bool in
            if (lhs.value.lName != rhs.value.lName) {
                return lhs.value.lName ?? "" < rhs.value.lName ?? "";
            } else if (lhs.value.fName != rhs.value.fName) {
                return lhs.value.fName ?? "" < rhs.value.fName ?? "";
            } else /*if (lhs.value.domain! != domain!)*/ {
                return lhs.value.domain! < rhs.value.domain!;
            }
        }

    }
    
    func getSortedProducts() -> [(String, Product)]{
        //sorts by name, then domain, then vintage
        return products.sorted {lhs, rhs -> Bool in
            if (lhs.value.nameNoVintage() != rhs.value.nameNoVintage()) {
                return lhs.value.nameNoVintage() < rhs.value.nameNoVintage();
            } else if (lhs.value.domain != rhs.value.domain) {
                return lhs.value.domain! < rhs.value.domain!;
            } else /*if (lhs.value.vintage != rhs.value.vintage)*/ {
                return lhs.value.vintage ?? 0 < rhs.value.vintage ?? 0;
            }
        }
    }
    
    func getSortedOrders() -> [(String, Order)]{
        //sorts by date
        return orders.sorted {lhs, rhs -> Bool in
            let lDateString = String(lhs.value.orderSubmittedDate.prefix(upTo: lhs.value.orderSubmittedDate.firstIndex(of: ".")!));
            let lOrderDate = self.dateFormatter.date(from: lDateString);
            let rDateString = String(rhs.value.orderSubmittedDate.prefix(upTo: rhs.value.orderSubmittedDate.firstIndex(of: ".")!));
            let rOrderDate = self.dateFormatter.date(from: rDateString);
            return (Date() - lOrderDate!) < (Date() - rOrderDate!);
        }
    }
    
    func getCustomers(cursor: String, domain: String) {
        var tenant = "";
        if (domain == "D2C") {
            tenant = d2c;
        } else if (domain == "Trade") {
            tenant = trade;
        }  else {
            print("Not a Recognized Domain");
            return;
        }
        var receivedCursor: String? = nil;
        let urlAsString = "https://api.commerce7.com/v1/customer?cursor=" + cursor;
        
        let url = URL(string: urlAsString)!
        var request = URLRequest(url: url);
        request.httpMethod = "GET";
        request.setValue("application/json", forHTTPHeaderField: "Content-Type");
        request.setValue(basic, forHTTPHeaderField: "Authorization");
        request.setValue(tenant, forHTTPHeaderField: "Tenant");
        
        let urlSession = URLSession.shared
        
        let jsonQuery = urlSession.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            }
            //var err: NSError?
            
            do {
                //print("JSON String: \(String(data: data!, encoding: .utf8))")
                let decodedData = try JSONDecoder().decode(CustomerArr.self, from: data!)
                //print(decodedData);
                
                DispatchQueue.main.async {
                    for cust in decodedData.customers {
                        cust.domain = domain;
                        let city = self.sampleCityNames.randomElement() ?? "";
                        let zip = self.sampleZipCodes.randomElement() ?? "";
                        cust.fName = "Customer";
                        let shortID = String(cust.customerID.dropLast(28));
                        cust.lName = shortID;
                        let simulatedAddress = Address(addr1: "1234 Test Rd.", city: city, stateCode: "OR", zipCode: zip, countryCode: "US")
                        cust.address = simulatedAddress;
                        self.locations.addMarker(cityState: cust.address?.cityState() ?? "Portland, OR");
                        self.customers[cust.customerID] = cust;
                        //print("\(self.d2cCustomers.count) \(cust.fName ?? "noF") \(cust.lName ?? "noL")");
                    }
                    //recalls self if most recent page is not the last one
                    if (receivedCursor != nil) {
                        self.getCustomers(cursor: receivedCursor!, domain: domain);
                    }
                }
                
                receivedCursor = decodedData.cursor;
            } catch {
                print("error: \(error)\n in getCustomers");
            }
        })
        jsonQuery.resume();
    }
    
    

    func getProducts(cursor: String, domain: String) {
        var tenant = "";
        if (domain == "D2C") {
            tenant = d2c;
        } else if (domain == "Trade") {
            tenant = trade;
        }  else {
            print("Not a Recognized Domain");
            return;
        }
        var receivedCursor: String? = nil;
        let urlAsString = "https://api.commerce7.com/v1/product?cursor=" + cursor;
        
        let url = URL(string: urlAsString)!
        var request = URLRequest(url: url);
        request.httpMethod = "GET";
        request.setValue("application/json", forHTTPHeaderField: "Content-Type");
        request.setValue(basic, forHTTPHeaderField: "Authorization");
        request.setValue(tenant, forHTTPHeaderField: "Tenant");
        
        let urlSession = URLSession.shared
        
        let jsonQuery = urlSession.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            }
            //var err: NSError?
            
            do {
                //print("JSON String: \(String(data: data!, encoding: .utf8))")
                let decodedData = try JSONDecoder().decode(ProductArr.self, from: data!)
                //print(decodedData);
                
                DispatchQueue.main.async {
                    for prod in decodedData.products {
                        if (prod.wineType != nil) {
                            prod.domain = domain;
                            self.products[prod.productID] = prod;
                            //print("\(self.d2cCustomers.count) \(cust.fName ?? "noF") \(cust.lName ?? "noL")");
                        }
                    }
                    //recalls self if most recent page is not the last one
                    if (receivedCursor != nil) {
                        self.getProducts(cursor: receivedCursor!, domain: domain);
                    } else {
                        self.getOrders(cursor: "start", domain: domain);
                        print("Calling orders on domain \(domain)");
                    }
                }
                 
                receivedCursor = decodedData.cursor;
            } catch {
                print("error: \(error)\n in getCustomers");
            }
        })
        jsonQuery.resume();
    }
    
    
    
    func getOrders(cursor: String, domain: String) {
        var tenant = "";
        if (domain == "D2C") {
            tenant = d2c;
        } else if (domain == "Trade") {
            tenant = trade;
        }  else {
            print("Not a Recognized Domain");
            return;
        }
        var receivedCursor: String? = nil;
        let urlAsString = "https://api.commerce7.com/v1/order?cursor=" + cursor;
        
        let url = URL(string: urlAsString)!
        var request = URLRequest(url: url);
        request.httpMethod = "GET";
        request.setValue("application/json", forHTTPHeaderField: "Content-Type");
        request.setValue(basic, forHTTPHeaderField: "Authorization");
        request.setValue(tenant, forHTTPHeaderField: "Tenant");
        
        let urlSession = URLSession.shared
        
        let jsonQuery = urlSession.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            }
            //var err: NSError?
            
            do {
                //print("JSON String: \(String(data: data!, encoding: .utf8))")
                let decodedData = try JSONDecoder().decode(OrderArr.self, from: data!)
                //print(decodedData);
                DispatchQueue.main.async {
                    for order in decodedData.orders {
                        order.domain = domain;
                        self.orders[order.orderID] = order;
                        let dateString = String(order.orderSubmittedDate.prefix(upTo: order.orderSubmittedDate.firstIndex(of: ".")!));
                        let orderDate = self.dateFormatter.date(from: dateString);
                        //if order is from current year
                        if (Calendar.current.isDate(Date(), equalTo: orderDate!, toGranularity: .year)) {
                            if (domain == "D2C") {
                                //ytd sales
                                self.d2cYTDSales += Double(order.subTotal);
                                //ytd margin
                                for item in order.items {
                                    if (item.productID != nil) {
                                        let productItem = self.products.filter({$0.value.domain == domain})[item.productID!];
                                        let unitCost = productItem?.getCostFromSku(skuIn: item.sku);
                                        self.d2cYTDCost += (unitCost ?? 0.0) * Double(item.quantity);
                                    } else {
                                        //handles deleted/migrated listings because SKUs are (almost) always preserved
                                        //print("Null d2c product ID")
                                        //print(order.orderSubmittedDate)
                                        let productItem = self.productBySKU(sku: item.sku, domain: domain);
                                        let unitCost = productItem?.getCostFromSku(skuIn: item.sku)
                                        //print(unitCost);
                                        self.d2cYTDCost += (unitCost ?? 0.0) * Double(item.quantity);
                                        
                                    }
                                }
                            } else if (domain == "Trade") {
                                //ytd sales
                                self.tradeYTDSales += Double(order.subTotal);
                                //ytd margin
                                for item in order.items {
                                    if (item.productID != nil) {
                                        let productItem = self.products.filter({$0.value.domain == domain})[item.productID!];
                                        let unitCost = productItem?.getCostFromSku(skuIn: item.sku);
                                        self.tradeYTDCost += (unitCost ?? 0.0) * Double(item.quantity);
                                    } else {
                                        //handles deleted/migrated listings because SKUs are (almost) always preserved
                                        //print("Null d2c product ID")
                                        //print(order.orderSubmittedDate)
                                        let productItem = self.productBySKU(sku: item.sku, domain: domain);
                                        let unitCost = productItem?.getCostFromSku(skuIn: item.sku)
                                        //print(unitCost);
                                        self.tradeYTDCost += (unitCost ?? 0.0) * Double(item.quantity);
                                        
                                    }
                                }
                            }
                        }
                        //if order is from last 6 months
                        //int is half the seconds in a year
                        if (Date() - orderDate! < 15768000) {
                            if (domain == "D2C") {
                                self.d2c6MonthlyAvgSales += Double(order.subTotal);
                            } else if (domain == "Trade") {
                                self.trade6MonthlyAvgSales += Double(order.subTotal);
                            }
                        }
                    }
                    //recalls self if most recent page is not the last one
                    if (receivedCursor != nil) {
                        self.getOrders(cursor: receivedCursor!, domain: domain);
                    } else {
                        if (domain == "D2C") {
                            self.d2cYTDMargin = (self.d2cYTDSales - self.d2cYTDCost) / self.d2cYTDSales;
                            let combinedSales = self.d2cYTDSales + self.tradeYTDSales;
                            let combinedCosts = self.d2cYTDCost + self.tradeYTDCost;
                            self.combinedYTDMargin = (combinedSales - combinedCosts) / combinedSales;
                            //print("\(combinedSales) \(combinedCosts)")
                            //print(self.d2cYTDMargin);
                        } else if (domain == "Trade") {
                            self.tradeYTDMargin = (self.tradeYTDSales - self.tradeYTDCost) / self.tradeYTDSales;
                            let combinedSales = self.d2cYTDSales + self.tradeYTDSales;
                            let combinedCosts = self.d2cYTDCost + self.tradeYTDCost;
                            self.combinedYTDMargin = (combinedSales - combinedCosts) / combinedSales;
                            //print("\(combinedSales) \(combinedCosts)")
                            //print(self.tradeYTDMargin);
                        }
                        if (!self.firstLoaded) {
                            self.firstLoaded = true;
                        } else {
                            self.doneLoading = true;
                        }
                    }
                }
                receivedCursor = decodedData.cursor;
            } catch {
                print("error: \(error)\n in getCustomers");
            }
        })
        jsonQuery.resume();
    }
}


struct CustomerArr: Codable {
    var cursor: String?;
    var customers: [Customer];
}

struct ProductArr: Codable {
    var cursor: String?;
    var products: [Product];
}

struct OrderArr: Codable {
    var cursor: String?;
    var orders: [Order];
}


