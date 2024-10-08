//
//  test.swift
//  Health Safety and Compliance
//
//  Created by Anthony Bacon on 07/10/2024.
//

import SwiftUI

struct test: View {
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 400, height: 200)
                .overlay {
                    Text("Hello, World!")
                        .foregroundStyle(.red)
                        .frame(width:400, height:200, alignment: .topLeading)
                }
        }
    }
}

#Preview {
    test()
}
