//
//  TaskRepositoryProtocol.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 20.01.2025.
//

import Foundation

protocol TaskRepositoryProtocol {
    func fetchTasks() async throws -> [TaskDomainEntity]
    func saveTask(_ task: TaskDomainEntity) async throws
    func deleteTask(byId id: UUID) async throws
}
