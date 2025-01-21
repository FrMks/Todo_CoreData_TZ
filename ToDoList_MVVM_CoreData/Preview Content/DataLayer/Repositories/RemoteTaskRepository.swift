//
//  RemoteTaskRepository.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 21.01.2025.
//

import Foundation

final class RemoteTaskRepository: RemoteTaskRepositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchRemoteTasks() async throws -> [TaskDomainEntity] {
        let todos = try await networkService.fetchTodos()
        return todos.map { todo in
            TaskDomainEntity(
                id: todo.uuid,
                title: todo.todo,
                taskDescription: "",
                date: Date(),
                isCompleted: todo.completed
            )
        }
    }
}
