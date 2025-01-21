//
//  TaskRepositoryProtocol.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 20.01.2025.
//

import Foundation

protocol TaskRepositoryProtocol {
    func fetchTasks() async throws -> [TaskDomainEntity] // Локальные задачи (CoreData)
    func fetchRemoteTasks() async throws -> [TaskDomainEntity] // Задачи с сервера
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
