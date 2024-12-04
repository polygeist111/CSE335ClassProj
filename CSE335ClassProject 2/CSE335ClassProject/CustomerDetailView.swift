//
//  CustomerDetailView.swift
//  CSE335ClassProject
//
//  Created by tlwood9 on 11/27/24.
//

import SwiftUI
import SwiftData
import Foundation

struct CustomerDetailView: View {
    @ObservedObject private var viewManager = ViewManager.shared;
    //@ObservedObject private var c7Data: C7Linker;
    @State var screenName: String = "";
    
    let customer:Customer;
    @State private var noteProgressText:String = "";
    
    init(customer:Customer) {
        self.customer = customer;
    }
    
    var body: some View {
        ZStack {
            List {
                //HEADER
                //header(title: screenName);
                 
                //BODY CONTENT HERE
                //Spacer();
                Text(customer.name())
                    .font(Font.headline)
                VStack(spacing: 10) {
                    VStack(alignment: HorizontalAlignment.leading) {
                        Text("\(customer.fName?.lowercased() ?? "")\(customer.lName?.lowercased() ?? "")@gmail.com")
                        Text("+1-222-333-4444\n")
                        Text("\(customer.address?.city ?? "No city given"), \(customer.address?.stateCode ?? "No state given")")
                        Text(customer.address?.zipCode ?? "")
                        Text("\nNotes:\n")
                        ForEach(viewManager.notes.filter({$0.customerID == customer.customerID})) { note in
                            Text("---");
                            Text(note.noteText);
                        }
                        Text("---")
                            .onAppear {viewManager.fetchData()}
                        Text("\nNew Note:");
                        TextField("Write a new note", text: $noteProgressText)
                        Button(action: {
                            viewManager.writeNote(customerID: customer.customerID, noteText: noteProgressText);
                            noteProgressText = "";
                        }, label: {
                            Text("Log Note")
                                .disabled(noteProgressText.isEmpty)
                        })
                    }
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


