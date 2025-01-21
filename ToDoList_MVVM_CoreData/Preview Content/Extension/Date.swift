//
//  Date.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 17.01.2025.
//

import Foundation

extension Date {
    func formatToShortDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: self)
    }
}
