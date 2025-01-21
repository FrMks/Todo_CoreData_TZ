//
//  DeleteAllTasks.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 21.01.2025.
//

import Foundation

final class DeleteAllTasksUseCase {
    private let taskRepository: TaskRepositoryProtocol
    
    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }
    
    func execute() async throws {
        try await taskRepository.deleteAllTasks()
    }
}
