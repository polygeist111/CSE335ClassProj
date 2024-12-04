//
//  Product.swift
//  CSE335ClassProject
//
//  Created by tlwood9 on 10/29/24.
//

import Foundation

class Product: Identifiable, Codable, APIStruct {
    var id = UUID();
    var domain:String? = nil;
    var productID: String;
    var name: String;
    var region: String?;
    var image: String?;
    var vendor: String;
    var teaser: String?;
    var description: String?;
    var wineType: String?;
    var vintage: Int?;
    var variants: [Variant];
    var adminStatus: String;
    var webStatus: String;
    
    enum CodingKeys: String, CodingKey {
        case image, vendor, teaser, variants, adminStatus, webStatus;
        case productID = "id";
        case name = "title";
        case region = "subTitle";
        case description = "content";
        case wineType = "wine";
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self);
        productID = try values.decode(String.self, forKey: .productID);
        name = try values.decode(String.self, forKey: .name);
        region = try values.decode(String?.self, forKey: .region);
        image = try values.decode(String?.self, forKey: .image);
        teaser = try values.decode(String?.self, forKey: .teaser);
        description = try values.decode(String?.self, forKey: .description);
        adminStatus = try values.decode(String.self, forKey: .adminStatus);
        webStatus = try values.decode(String.self, forKey: .webStatus);
        
                
        var variantHolder = try values.nestedUnkeyedContainer(forKey: .variants)
        var variants = [Variant]();
        while (!variantHolder.isAtEnd) {
            let variant = try variantHolder.decode(Variant.self);
            variants.append(variant);
        }
        self.variants = variants;
        
        let wineData:Wine? = try values.decodeIfPresent(Wine.self, forKey: .wineType);
        wineType = wineData?.wineType;
        vintage = wineData?.vintage;
        
        let vendorData = try values.decode(Vendor?.self, forKey: .vendor);
        vendor = vendorData?.vendor ?? "NA";
    }
    
    func getCostFromSku(skuIn:String) -> Double {
        for variant in variants {
            if (variant.sku == skuIn) {
                return Double(variant.costOfGood);
            }
        }
        return -1.00;
    }
    
    func formatPrices() -> String {
        var result = "";
        var multiple = false;
        for variant in variants {
            if (!multiple) {
                multiple = true;
            } else {
                result += " | ";
            }
            result += "$\(Double(variant.price).formatValue())";
        }
        return result;
    }
    
    func nameNoVintage() -> String {
        //has vintage
        if (name.first == "2") {
            return String(name.dropFirst(5));
        //no vintage
        } else {
            return name;
        }
    }
}

struct Vendor: Codable {
    var vendor: String;
    
    enum CodingKeys: String, CodingKey {
        case vendor = "title";
    }
}

struct Wine: Codable {
    var wineType: String?;
    var vintage: Int? = 0;
    
    enum CodingKeys: String, CodingKey {
        case vintage;
        case wineType = "type";
    }
}

struct Variant: Codable {
    var costOfGood: Int;
    var price: Int;
    var sku: String;
    var volume: Int?;
    var inventory: [Inventory]?;
    
    enum CodingKeys: String, CodingKey {
        case costOfGood, price, sku, inventory;
        case volume = "volumeInML";
    }
}

struct Inventory: Codable {
    var allocated: Int;
    var available: Int;
    var reserved: Int;
    var locationID: String;
    
    enum CodingKeys: String, CodingKey {
        case allocated = "allocatedCount";
        case available = "availableForSaleCount";
        case reserved = "reserveCount";
        case locationID = "inventoryLocationId";
    }
}
