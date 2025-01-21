//
//  DeleteTaskUseCase.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 20.01.2025.
//

import Foundation

final class DeleteTaskUseCase {
    private let taskRepository: TaskRepositoryProtocol
    
    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }
    
    func execute(byId id: UUID) async throws {
        try await taskRepository.deleteTask(byId: id)
    }
}
