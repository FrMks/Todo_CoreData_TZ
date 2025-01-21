//
//  TaskRepositoryProtocol.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 20.01.2025.
//

import Foundation

protocol TaskRepositoryProtocol {
    func fetchTasks() async throws -> [TaskDomainEntity]
    func fetchRemoteTasks() async throws -> [TaskDomainEntity]
    func saveTask(_ task: TaskDomainEntity) async throws
    func deleteTask(byId id: UUID) async throws
    func updateTask(task: TaskDomainEntity) async throws
    func deleteAllTasks() async throws
}

protocol LocalTaskRepositoryProtocol {
    func fetchTasks() async throws -> [TaskDomainEntity]
    func saveTask(_ task: TaskDomainEntity) async throws
    func deleteTask(byId id: UUID) async throws
    func updateTask(task: TaskDomainEntity) async throws
    func deleteAllTasks() async throws
}

protocol RemoteTaskRepositoryProtocol {
    func fetchRemoteTasks() async throws -> [TaskDomainEntity]
}
