//
//  TaskRepository.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 20.01.2025.
//

import Foundation

final class TaskRepository: TaskRepositoryProtocol {
    private let localTaskRepository: LocalTaskRepository
    private let remoteTaskRepository: RemoteTaskRepository
    
    init(
        localTaskRepository: LocalTaskRepository = .init(),
        remoteTaskRepository: RemoteTaskRepository = RemoteTaskRepository(networkService: NetworkService())
    ) {
        self.localTaskRepository = localTaskRepository
        self.remoteTaskRepository = remoteTaskRepository
    }
    
    func fetchTasks() async throws -> [TaskDomainEntity] {
        //Load tasks from local storage (CoreData)
        return try await localTaskRepository.fetchTasks()
    }
    
    func fetchRemoteTasks() async throws -> [TaskDomainEntity] {
        //Load tasks from the server
        return try await remoteTaskRepository.fetchRemoteTasks()
    }
    
    func saveTask(_ task: TaskDomainEntity) async throws {
        try await localTaskRepository.saveTask(task)
    }
    
    func deleteTask(byId id: UUID) async throws {
        try await localTaskRepository.deleteTask(byId: id)
    }
    
    func updateTask(task: TaskDomainEntity) async throws {
        try await localTaskRepository.updateTask(task: task)
    }
    
    func deleteAllTasks() async throws {
        try await localTaskRepository.deleteAllTasks()
    }
}
