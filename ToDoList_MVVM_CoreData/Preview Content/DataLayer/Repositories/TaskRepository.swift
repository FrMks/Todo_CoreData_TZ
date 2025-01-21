//
//  TaskRepository.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 20.01.2025.
//

import Foundation
import CoreData

final class TaskRepository {
    private let coreDataManager: CoreDataManager
    private let networkService: NetworkService
    
    init(coreDataManager: CoreDataManager = .shared, networkService: NetworkService = .init()) {
        self.coreDataManager = coreDataManager
        self.networkService = networkService
    }
    
    func fetchTasks() async throws -> [TodoDTO] {
        let todos = try await networkService.fetchTodos()
        
        try saveTasks(todos) //For CoreData
        
        return todos
    }
    
    func saveTasks(_ tasks: [TodoDTO]) throws {
        let context = coreDataManager.context
        
        tasks.forEach { todo in
            let taskEntity = TaskEntity(context: context)
            taskEntity.id = todo.uuid
            taskEntity.title = todo.todo
            taskEntity.taskDescription = "" // По умолчанию, если описание не приходит с сервера
            taskEntity.date = Date() // По умолчанию, если дата не приходит с сервера
            taskEntity.isCompleted = todo.completed
        }
        
        try context.save()
    }
    
    func deleteTask(byId id: UUID) throws {
        coreDataManager.deleteTask(byId: id)
    }
}
