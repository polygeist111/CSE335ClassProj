//
//  ViewManager.swift
//  CSE335ClassProject
//
//  Created by tlwood9 on 11/25/24.
//

import Foundation
import SwiftUI
import Combine
import SwiftData

final class ViewManager: ObservableObject {
    public var context:ModelContext? = nil;
    static let shared = ViewManager();
    var anyCancellable1: AnyCancellable? = nil
    @Published var notes = [CustomNote]();

    private init() {
        //forces c7Datachanges to propogate upwards into view
        //found here: https://stackoverflow.com/questions/58406287/how-to-tell-swiftui-views-to-bind-to-nested-observableobjects
        anyCancellable1 = c7Data.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
    }
    //handles view controls
    @Published var displayedRoot: rootScreens = .dashboard;
    @Published var targetDomain: domains = .All;
    @Published var currentTheme: themes = .Light;
    @Published var c7Data = C7Linker();
        
    enum rootScreens:Int {
        case dashboard; //0
        case products; //1
        case customers; //2
        case orders; //3
        case profile; //4
        case customerMap; //5
    }
    
    enum domains:String {
        case All;
        case Trade;
        case D2C;
    }
    
    enum themes:String {
        case Light;
        case Dark;
    }
    
    func setScreen(screenIn:Int) {
        self.displayedRoot = rootScreens(rawValue: screenIn)!;
    }
    
    func setDomain(domainIn:String) {
        self.targetDomain = domains(rawValue: domainIn)!;
    }
    
    func setTheme(themeIn:String) {
        self.currentTheme = themes(rawValue: themeIn)!;
    }
    //iphone 15 pro has 393w x 852h viewport
    
    func fetchData() {
        do {
            let descriptor = FetchDescriptor<CustomNote>()
            notes = try context!.fetch(descriptor);
        } catch {
            print("DB read failed");
        }
    }
    
    func getNote(customerID:String) -> [CustomNote]{
        return notes.filter({$0.customerID == customerID});
    }
    
    func writeNote(customerID:String, noteText:String) {
        let newNote = CustomNote(customerID: customerID, noteText: noteText);
        context!.insert(newNote);
        fetchData();
    }
}

//from https://stackoverflow.com/questions/56490250/dynamically-hiding-view-in-swiftui
//allows conditional use of .hidden()
extension View {
    func hidden (_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1);
    }
}

//from https://stackoverflow.com/questions/50950092/calculating-the-difference-between-two-dates-in-swift
//allows direct subtraction of dates
extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

//formats cents to dollar value with optional subdivision (e.g. divide by 6 for the 6 month average
extension Double {
    private static var valueFormatter: NumberFormatter = {
        let formatter = NumberFormatter();
        formatter.numberStyle = .decimal;
        formatter.minimumFractionDigits = 2;
        formatter.maximumFractionDigits = 2;
        formatter.groupingSize = 3;
        formatter.groupingSeparator = ",";
        return formatter;
    }()
    
    func formatValue(division: Double = 1.0) -> String {
        let number = NSNumber(value: self / (division * 100));
        //print(Self.valueFormatter.string(from: number)!)
        return Self.valueFormatter.string(from: number)!;
    }
}

//sample accent decoding from https://stackoverflow.com/questions/25607247/how-do-i-decode-html-entities-in-swift
extension String {
    var htmlDecoded: String {
        let decoded = try? NSAttributedString(data: Data(utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ], documentAttributes: nil).string

        return decoded ?? self
    }
}

struct CommonColors {
    //#2B3475
    static func ArchBlue() -> Color {
        return Color(red: 0.1686275, green: 0.203922, blue: 0.448824);
    }
    //#a0a4be
    static func ArchLightBlue() -> Color {
        return Color(red: 0.627451, green: 0.6431373, blue: 0.745098);
    }
    
    static func MenuGray() -> Color {
        return Color(red: 0.8784314, green: 0.8784314, blue: 0.8784314);
    }
    
    static func MenuLightGray() -> Color {
        return Color(red: 0.9784314, green: 0.9784314, blue: 0.9784314);
    }
    
    //#ADADAD
    static func MenuDarkGray() -> Color {
        return Color(red: 0.6784314, green: 0.6784314, blue: 0.6784314);
    }
}
