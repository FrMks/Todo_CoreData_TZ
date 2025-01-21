//
//  CreateTaskUseCase.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 20.01.2025.
//

import Foundation

final class CreateTaskUseCase {
    private let taskRepository: TaskRepositoryProtocol
    
    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }
    
    func execute(title: String, description: String, date: Date) async throws -> TaskDomainEntity {
        let task = TaskDomainEntity(
            id: UUID(),
            title: title,
            taskDescription: description,
            date: date,
            isCompleted: false
        )
        
        try await taskRepository.saveTask(task)
        return task
    }
}
