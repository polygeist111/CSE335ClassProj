//
//  LoadingView.swift
//  CSE335ClassProject
//
//  Created by Tucker Wood on 11/30/24.
//

import SwiftUI
import Foundation

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 10) {
            Spacer();

            Image("PolygeistIcon")
                .resizable()
                .renderingMode(Image.TemplateRenderingMode.template)
                .foregroundStyle(CommonColors.ArchBlue())
                .aspectRatio(contentMode: .fit)
                .frame(width: 196, height: 196)
            Spacer();
            Text("Loading, your patience is appreciated")
            Spacer();
            Text("\nApp built by Tucker Wood for ASU CSE 335")
            Text("Full credits in Profile view")
        }
        .padding(10)
    }
}
