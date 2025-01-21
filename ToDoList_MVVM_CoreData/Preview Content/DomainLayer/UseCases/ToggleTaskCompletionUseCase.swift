//
//  ToggleTaskCompletionUseCase.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 21.01.2025.
//

import Foundation

final class ToggleTaskCompletionUseCase {
    private let taskRepository: TaskRepositoryProtocol
    
    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }
    
    func execute(task: TaskDomainEntity) async throws {
        // Обновляем задачу в CoreData
        print("\(task.id)")
        try await taskRepository.updateTask(task: task)
    }
}
