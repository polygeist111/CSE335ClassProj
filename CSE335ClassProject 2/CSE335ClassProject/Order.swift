//
//  Order.swift
//  CSE335ClassProject
//
//  Created by tlwood9 on 10/29/24.
//

import Foundation

//may need to introduce special handling to process refunds
class Order: Identifiable, Codable, APIStruct {
    var id = UUID();
    var orderID:String;
    var domain:String? = nil;
    var orderSubmittedDate: String;
    var paymentStatus: String;
    var channel: String;
    var posProfileID: String?;
    var customerID: String?;
    var orderDeliveryMethod: String;
    var subTotal: Int;
    var shipTotal: Int;
    var taxTotal: Int;
    var total: Int;
    var club: Club?;
    var items: [OrderItem];
    
    enum CodingKeys: String, CodingKey {
        case orderSubmittedDate, paymentStatus, channel, orderDeliveryMethod, subTotal, shipTotal, taxTotal, total, club, items;
        case orderID = "id";
        case posProfileID = "posProfileId";
        case customerID = "customerId";
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self);
        orderID = try values.decode(String.self, forKey: .orderID);
        orderSubmittedDate = try values.decode(String.self, forKey: .orderSubmittedDate);
        paymentStatus = try values.decode(String.self, forKey: .paymentStatus);
        channel = try values.decode(String.self, forKey: .channel);
        posProfileID = try values.decode(String?.self, forKey: .posProfileID);
        customerID = try values.decode(String?.self, forKey: .customerID);
        orderDeliveryMethod = try values.decode(String.self, forKey: .orderDeliveryMethod);
        
        subTotal = try values.decode(Int.self, forKey: .subTotal);
        shipTotal = try values.decode(Int.self, forKey: .shipTotal);
        taxTotal = try values.decode(Int.self, forKey: .taxTotal);
        total = try values.decode(Int.self, forKey: .total);
                
        club = try values.decode(Club?.self, forKey: .club);

        var itemsHolder = try values.nestedUnkeyedContainer(forKey: .items)
        var items = [OrderItem]();
        while (!itemsHolder.isAtEnd) {
            let item = try itemsHolder.decode(OrderItem.self);
            items.append(item);
        }
        self.items = items;
        
    }
    
    func formattedDate() -> String {
        return String(orderSubmittedDate.dropLast(14))
    }
}

struct OrderItem: Codable {
    var sku: String;
    var quantity: Int;
    var productID: String?;
    
    enum CodingKeys: String, CodingKey {
        case sku, quantity;
        case productID = "productId";
    }
}

protocol APIStruct {
    init(from decoder: Decoder) throws
}
