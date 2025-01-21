//
//  Task.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 20.01.2025.
//

import Foundation

struct TaskDomainEntity: Identifiable {
    let id: UUID
    let title: String
    let taskDescription: String
    let date: Date
    let isCompleted: Bool
}
