//
//  SearchBar.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 17.01.2025.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.theme.whiteCustom.opacity(0.5))
            
            TextField("Search", text: $text)
                .foregroundColor(Color.theme.whiteCustom.opacity(0.5))
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.theme.whiteCustom.opacity(0.5))
                }
            }
        }
        .padding(8)
        .background(Color.theme.grayCustom)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
