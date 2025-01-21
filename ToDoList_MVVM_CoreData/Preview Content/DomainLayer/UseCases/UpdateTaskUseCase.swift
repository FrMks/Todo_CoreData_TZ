//
//  UpdateTaskUseCase.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 21.01.2025.
//

import Foundation

final class UpdateTaskUseCase {
    private let taskRepository: TaskRepository
    
    init(taskRepository: TaskRepository) {
        self.taskRepository = taskRepository
    }
    
    func execute(task: TaskDomainEntity) async throws {
        try await taskRepository.updateTask(task: task)
    }
}
