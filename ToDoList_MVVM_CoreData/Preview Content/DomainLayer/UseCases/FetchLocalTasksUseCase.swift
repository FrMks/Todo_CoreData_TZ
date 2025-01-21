//
//  FetchLocalTasksUseCase.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 21.01.2025.
//

import Foundation

final class FetchLocalTasksUseCase {
    private let taskRepository: TaskRepositoryProtocol
    
    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }
    
    func execute() async throws -> [TaskDomainEntity] {
        print("🔄 Загрузка задач из CoreData...")
        let localTasks = try await taskRepository.fetchTasks()
        print("✅ Загружено задач из CoreData: \(localTasks.count)")
        return localTasks
    }
}
