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
    
    func execute(id: UUID, title: String, description: String, date: Date, isCompleted: Bool) async throws -> TaskDomainEntity {
        let task = TaskDomainEntity(
            id: id,
            title: title,
            taskDescription: description,
            date: date,
            isCompleted: isCompleted
        )
        
        try await taskRepository.saveTask(task)
        return task
    }
}
