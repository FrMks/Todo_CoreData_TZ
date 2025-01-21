//
//  LocalTaskRepository.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 21.01.2025.
//

import Foundation
import CoreData

final class LocalTaskRepository: LocalTaskRepositoryProtocol {
    private let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
    }
    
    func fetchTasks() async throws -> [TaskDomainEntity] {
        //print("🔄 Извлечение задач из CoreData...")
        let taskEntities = coreDataManager.fetchTasks()
        //print("✅ Извлечено задач из CoreData: \(taskEntities.count)")
        return taskEntities.map { taskEntity in
            TaskDomainEntity(
                id: taskEntity.id,
                title: taskEntity.title,
                taskDescription: taskEntity.taskDescription,
                date: taskEntity.date,
                isCompleted: taskEntity.isCompleted
            )
        }
    }
    
    func saveTask(_ task: TaskDomainEntity) async throws {
        //print("🔄 Сохранение задачи в CoreData: \(task.title)")
        let context = coreDataManager.context
        let taskEntity = TaskEntity(context: context)
        taskEntity.id = task.id
        taskEntity.title = task.title
        taskEntity.taskDescription = task.taskDescription
        taskEntity.date = task.date
        taskEntity.isCompleted = task.isCompleted
        try context.save()
        //print("✅ Задача сохранена в CoreData: \(task.title)")
    }
    
    func deleteTask(byId id: UUID) async throws {
        try coreDataManager.deleteTask(byId: id)
    }
    
    func updateTask(task: TaskDomainEntity) async throws {
        let context = coreDataManager.context
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
        
        let tasks = try context.fetch(fetchRequest)
        if let taskEntity = tasks.first {
            taskEntity.title = task.title
            taskEntity.taskDescription = task.taskDescription
            taskEntity.date = task.date
            taskEntity.isCompleted = task.isCompleted
            try context.save()
        } else {
            throw NSError(domain: "TaskNotFound", code: 404, userInfo: nil)
        }
    }
    
    func deleteAllTasks() async throws {
        try coreDataManager.deleteAllData()
    }
}
