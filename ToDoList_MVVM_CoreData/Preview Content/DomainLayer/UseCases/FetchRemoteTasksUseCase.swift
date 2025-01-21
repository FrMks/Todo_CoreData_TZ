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
        print("🔄 Загрузка задач с сервера...")
        let remoteTasks = try await taskRepository.fetchRemoteTasks()
        print("✅ Загружено задач с сервера: \(remoteTasks.count)")
        return remoteTasks
    }
}
