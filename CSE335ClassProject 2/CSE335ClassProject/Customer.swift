//
//  Customer.swift
//  CSE335ClassProject
//
//  Created by tlwood9 on 10/29/24.
//

import Foundation
class Customer: Identifiable, Codable, APIStruct {
    var id = UUID();
    var domain:String? = nil;
    var customerID:String;
    var honorific: String? = nil;
    var fName: String? = nil;
    var lName: String? = nil;
    var birthDate: String? = nil;
    var emails: [String];
    var phones: [String]? = nil;
    var address: Address? = nil;
    var clubs: [Club]? = nil;
    
    enum CodingKeys: String, CodingKey {
        case honorific, birthDate, emails, phones, clubs;
        case customerID = "id";
        case fName = "firstName";
        case lName = "lastName";
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self);
        //print("Attempting to decode:")
        customerID = try values.decode(String.self, forKey: .customerID);
        honorific = try values.decode(String?.self, forKey: .honorific);
        fName = try values.decode(String?.self, forKey: .fName);
        //print(fName);
        lName = try values.decode(String?.self, forKey: .lName);
        birthDate = try values.decode(String?.self, forKey: .birthDate);
                
        var emailHolder = try values.nestedUnkeyedContainer(forKey: .emails)
        var emails = [String]();
        while (!emailHolder.isAtEnd) {
            let email = try emailHolder.decode(Email.self);
            emails.append(email.email);
        }
        self.emails = emails;
        
        var phoneHolder = try values.nestedUnkeyedContainer(forKey: .phones)
        var phones = [String]();
        while (!phoneHolder.isAtEnd) {
            let phone = try phoneHolder.decode(Phone.self);
            phones.append(phone.phone);
        }
        self.phones = phones;
        
        var clubHolder = try values.nestedUnkeyedContainer(forKey: .clubs);
        var clubs = [Club]();
        while (!clubHolder.isAtEnd) {
            let club = try clubHolder.decode(Club.self);
            clubs.append(club);
        }
        self.clubs = clubs;
    }
    
    func name() -> String {
        return "\(fName ?? "") \(lName ?? "")";
    }
}

struct Email: Codable {
    var email: String;
}

struct Phone: Codable {
    var phone: String;
}

struct Address: Codable {
    var addr1: String;
    var addr2: String?;
    var city: String;
    var stateCode: String;
    var zipCode: String;
    var countryCode: String;
    
    enum CodingKeys: String, CodingKey {
        case city, stateCode, zipCode, countryCode
        case addr1 = "address"
        case addr2 = "address2"
    }
    
    func cityState() -> String {
        return "\(city), \(stateCode)";
    }
}

struct Club: Codable {
    var clubId: String?;
    var name: String?;
    var joinDate: String?;
    
    enum CodingKeys: String, CodingKey {
        case clubId = "clubID"
        case name = "clubTitle"
        case joinDate = "signupDate"
    }
}
