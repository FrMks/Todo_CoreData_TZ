//
//  FetchTasksUseCase.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 20.01.2025.
//

import Foundation

final class FetchRemoteTasksUseCase {
    private let taskRepository: TaskRepositoryProtocol
    
    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }
    
    func execute() async throws -> [TaskDomainEntity] {
        let remoteTasks = try await taskRepository.fetchRemoteTasks()
        return remoteTasks
    }
}
