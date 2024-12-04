//
//  UI Structs.swift
//  CSE335ClassProject
//
//  Created by tlwood9 on 11/26/24.
//

import Foundation
import SwiftUI
import SwiftData

struct header: View {
    var title:String;
    
    var body: some View {
        HStack (alignment: .top) {
            Spacer();
            Text(title)
                .font(.system(size: 36))
                .fontWeight(.semibold)
                .padding(.top, 6)
                .padding(.leading, 68)
            
            Spacer();
            navButton(icon: "ProfileIcon", targetPage: 4)
                .padding(.trailing, 20);
        }
        .padding(.top, 50)
        .padding(.bottom, 15)
        .background(CommonColors.MenuGray())
    }
}

struct domainSelector: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(CommonColors.ArchBlue())
            VStack(spacing: 0) {
                domainButton(icon: "D2CIcon", targetDomain: "D2C");
                domainButton(icon: "TradeIcon", targetDomain: "Trade");
                domainButton(icon: "AllIcon", targetDomain: "All");
            }
            .frame(width: 48, height: 144)
            .fixedSize()
        }
        .frame(width: 48, height: 144)
        .fixedSize()
        .padding(.trailing, 305)
        .padding(.bottom, 611.5)
    }
}

struct bottomBar: View {
    var body: some View {
        HStack {
            Spacer();
            navButton(icon: "DashboardIcon", targetPage: 0);
            Spacer();
            navButton(icon: "ProductIcon", targetPage: 1);
            Spacer();
            navButton(icon: "UserIcon", targetPage: 2);
            Spacer();
            navButton(icon: "OrderIcon", targetPage: 3);
            Spacer();
            navButton(icon: "MapIcon", targetPage: 5);
            Spacer();
        }
        .padding(.bottom, 15)
        .frame(width: 393, height: 85)
        .background(CommonColors.MenuGray())
    }
}

struct urlImage: View {
    let url:String;
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
            image.resizable()
            .aspectRatio(contentMode: .fit)
        } placeholder: {
            Image("NoImageIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}


//adapted from https://stackoverflow.com/questions/76832159/searchable-make-the-search-box-stick-to-the-top-without-moving-when-focused
struct HeaderSearchBar: View {
    @Binding var searchText: String
    
    @State var active = false
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("Search", text: $searchText, onEditingChanged: { editing in
                    withAnimation {
                        active = editing
                    }
                })
                .autocorrectionDisabled(true)
            }
            .padding(7)
            .background(Color(.white))
            .cornerRadius(10)
            .padding(.horizontal, active ? 0 : 10)
            if (active) {
                Button("Cancel") {
                    withAnimation {
                        active = false
                        //https://roadfiresoftware.com/2015/01/the-easy-way-to-dismiss-the-ios-keyboard/
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                    }
                }
            }
            //.frame(width: active ? nil : 0)
        }
    }
}

struct domainButton: View {
    let icon:String;
    let targetDomain:String;
    @ObservedObject private var viewManager = ViewManager.shared;
    
    var body: some View {
        Button(action: {
            viewManager.setDomain(domainIn: targetDomain);
        },
            label: {
                ZStack {
                    Circle()
                        .fill(CommonColors.ArchLightBlue())
                        .hidden(viewManager.targetDomain.rawValue != targetDomain)
                        
                    Image(icon)
                        .resizable()
                        .renderingMode(Image.TemplateRenderingMode.template)
                        .foregroundStyle(Color.white)
                        .frame(width: 32, height: 32)
                }
                .frame(width: 48, height: 48);
            }
        );
    }
}

struct navButton: View {
    let icon:String;
    let targetPage:Int;
    @ObservedObject private var viewManager = ViewManager.shared;

    var body: some View {
        Button(action: {
            viewManager.setScreen(screenIn: targetPage);
        },
            label: {
                ZStack {
                    Circle()
                        .fill(viewManager.displayedRoot.rawValue != targetPage ? CommonColors.ArchBlue() : CommonColors.ArchLightBlue())
                    Image(icon)
                        .resizable()
                        .renderingMode(Image.TemplateRenderingMode.template)
                        .foregroundStyle(Color.white)
                        .frame(width: 32, height: 32)
                }
                .frame(width: 48, height: 48);
            }
        );
    }
}

struct dashBoardTile: View {
    let title:String;
    let ytd:String;
    let sixMonthAvg:String;
    let customers:String;
    let margin:Double;
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(CommonColors.MenuGray())
            HStack {
                //leftside data
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.system(size: 24))
                        .padding(.bottom, 8)
                    Text(ytd)
                        .font(.system(size: 18))
                        .padding(.bottom, 4)
                    Text(sixMonthAvg)
                        .font(.system(size: 18))
                    HStack {
                        Image("UserIcon")
                            .resizable()
                            .frame(width: 24, height: 24);
                        Text(customers)
                            .font(.system(size: 18))
                        Spacer();
                    }
                }
                //rightside margin data
                VStack(alignment: .center) {
                    Text("Margin")
                        .font(.system(size: 18))
                        .padding(.trailing, 5)
                    ZStack {
                        progressCircle(progressPercent: margin);
                        Text("\(margin.formatValue(division: 0.0001))%")
                    }
                    .frame(width: 90, height: 90)
                    .fixedSize()
                    .padding(.vertical, 5)
                    .padding(.trailing, 5)
                }
            }
            .padding(20);
        }
        .frame(width: 350, height: 180)
        .fixedSize()
    }
}

//circular progress bar
//learned here: https://sarunw.com/posts/swiftui-circular-progress-bar/
struct progressCircle: View {
    var progressPercent:Double;
    @State var fillCircle = false;
    var body: some View {
        ZStack {
            Circle()
                .stroke(CommonColors.ArchLightBlue(), lineWidth: 15);
            Circle()
                .trim(from: 0.0, to: fillCircle ? progressPercent : 0.0)
                .stroke(CommonColors.ArchBlue(), style: StrokeStyle (lineWidth: 15, lineCap: .round))
                .rotationEffect(.degrees(90))
                .onAppear {
                    withAnimation(.linear(duration: 1)) {
                        self.fillCircle.toggle()
                    }
                }
        }
    }
}
