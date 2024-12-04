//
//  CustomNote.swift
//  CSE335ClassProject
//
//  Created by tlwood9 on 11/25/24.
//

import Foundation
import SwiftData

@Model
class CustomNote: Identifiable {
    @Attribute(.unique) var id = UUID();
    @Attribute var customerID:String;
    @Attribute var noteText:String;
    init(customerID:String, noteText:String) {
        self.customerID = customerID;
        self.noteText = noteText;
    }
}
