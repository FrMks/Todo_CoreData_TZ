//
//  CoreDataManager.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 16.01.2025.
//

import Foundation
import CoreData

//MARK: - CRUD
public final class CoreDataManager {
    public static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    let context: NSManagedObjectContext
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "TaskEntity")
        persistentContainer.loadPersistentStores { description, error in
            if let error {
                fatalError("Error initializing CoreData: \(error.localizedDescription)")
            }
        }
        context = persistentContainer.viewContext
    }
    
    public func createTask(id: UUID, title: String, taskDescription: String, date: Date, isCompleted: Bool) -> TaskEntity? {
        let task = TaskEntity(context: context)
        task.id = id
        task.title = title
        task.taskDescription = taskDescription
        task.date = date
        task.isCompleted = isCompleted
        
        do {
            try context.save()
            return task
        } catch {
            print("❌ CoreDataManager: Error saving task: \(error)")
            return nil
        }
    }
    
    public func fetchTasks() -> [TaskEntity] {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        
        do {
            // Adding sorting for stable order
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.date, ascending: false)]
            let tasks = try context.fetch(fetchRequest)
            return tasks
        } catch {
            print("Error fetching tasks: \(error)")
            return []
        }
    }
    
    public func updateTask(task: TaskEntity, title: String? = nil, taskDescription: String? = nil, date: Date? = nil, isCompleted: Bool? = nil) {
        if let title = title {
            task.title = title
        }
        if let taskDescription = taskDescription {
            task.taskDescription = taskDescription
        }
        if let date = date {
            task.date = date
        }
        if let isCompleted = isCompleted {
            task.isCompleted = isCompleted
        }
        
        saveContext()
        
        // Notice of change
        context.refresh(task, mergeChanges: true)
    }
    
    public func deleteTask(task: TaskEntity) {
        print("🗑️ CoreDataManager: Starting task deletion")
        
        // Check that the object exists in the context
        if context.registeredObjects.contains(task) && !task.isDeleted {
            context.delete(task)
            
            do {
                try context.save()
                print("✅ CoreDataManager: Task deleted and context saved successfully")
            } catch {
                print("❌ CoreDataManager: Error deleting task: \(error)")
                context.rollback()
            }
        } else {
            print("ℹ️ CoreDataManager: Task is not registered in context or already deleted")
        }
    }
    
    
    public func deleteTask(byId id: UUID) {
        print("🗑️ CoreDataManager: Starting task deletion by id: \(id)")
        
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let tasks = try context.fetch(fetchRequest)
            if let taskToDelete = tasks.first {
                print("🗑️ CoreDataManager: Task found in context, deleting...")
                context.delete(taskToDelete)
                
                // Save changes immediately after deletion
                try context.save()
                print("✅ CoreDataManager: Task deleted and context saved successfully")
            }
        } catch {
            print("❌ CoreDataManager: Error deleting task: \(error)")
            context.rollback()
        }
    }
    
    public func saveContext() {
        print("💾 CoreDataManager: Starting context save")
        if context.hasChanges {
            do {
                try context.save()
                print("✅ CoreDataManager: Context saved successfully")
            } catch {
                print("❌ CoreDataManager: Error saving context: \(error)")
            }
        } else {
            print("ℹ️ CoreDataManager: No changes to save")
        }
    }
    
    
    
    public func deleteAllData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TaskEntity")
        
        // Create batch delete request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            try context.save()
        } catch {
            print("Error deleting all data: \(error)")
        }
    }
    
}
