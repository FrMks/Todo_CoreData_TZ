//
//  TodoViewModel.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 16.01.2025.
//

import Foundation
import CoreData
import Combine

class TodoViewModel: ObservableObject {
    @Published private(set) var todos: [TodoDTO] = []
    @Published private(set) var tasks: [TaskEntity] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    @Published var searchText: String = ""
    
    private let coreDataManager = CoreDataManager.shared
    private let networkService = NetworkService()
    
    var filteredTasks: [TaskEntity] {
        if searchText.isEmpty {
            return tasks
        }
        return tasks.filter { task in
            task.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    @MainActor
    func loadData() async {
        isLoading = true
        loadTasksFromCoreData()
        
        if tasks.isEmpty {
            do {
                let fetchedTodos = try await networkService.fetchTodos()
                //Сохраняем полученные данные в CoreData
                for todo in fetchedTodos {
                    coreDataManager.createTask(id: todo.uuid,
                                               title: todo.todo,
                                               taskDescription: "",
                                               date: Date(),
                                               isCompleted: todo.completed)
                }
                //загружаем сохраненные данные
                loadTasksFromCoreData()
            } catch {
                self.error = error
                print("Error fetching todos: \(error.localizedDescription)")
            }
        }
        isLoading = false
    }
    
    // Добавление новой задачи
    @MainActor
    func addTask(title: String, description: String) {
        let newId = UUID()
        //let newId = Int16(tasks.count)
        coreDataManager.createTask(
            //id: newId,
            id: newId,
            title: title,
            taskDescription: description,
            date: Date(),
            isCompleted: false
        )
        loadTasksFromCoreData()
    }
    
    // Обновление задачи
    @MainActor
    func toggleTaskCompletion(task: TaskEntity) {
        // Сохраняем новое значение
        let newValue = !task.isCompleted
        
        // Обновляем в CoreData
        coreDataManager.updateTask(task: task, isCompleted: newValue)
        
        // Принудительно сохраняем контекст
        coreDataManager.saveContext()
        
        // Обновляем UI и локальное состояние
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted = newValue
            objectWillChange.send()
        }
    }
    
    
    
    @MainActor
    func deleteTask(task: TaskEntity) {
        print("🗑️ TodoViewModel: Starting task deletion")
        
        // Удаляем задачу из локального массива tasks
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            print("🗑️ TodoViewModel: Removing task from local tasks array")
            tasks.remove(at: index)
            objectWillChange.send() // Обновляем UI
            print("✅ TodoViewModel: Task removed from UI")
        } else {
            print("ℹ️ TodoViewModel: Task not found in local tasks array")
        }
        
        // Удаляем задачу из CoreData
        coreDataManager.deleteTask(task: task)
        
        print("✅ TodoViewModel: Task deletion process completed")
    }
    
//    @MainActor
//    func deleteTask(task: TaskList) {
//        print("🗑️ TodoViewModel: Starting task deletion")
//        guard let taskToDelete = coreDataManager.fetchTaskById(byId: task.id) else {
//            print("❌ TodoViewModel: Task not found for deletion")
//            return
//        }
//        
//        coreDataManager.deleteTask(task: taskToDelete)
//        print("♻️ TodoViewModel: Reloading tasks after deletion")
//        loadTasksFromCoreData() // Ensure this updates the UI
//    }
    
//    @MainActor
//    func deleteTask(byId id: UUID) {
//        print("🗑️ TodoViewModel: Starting task deletion by id: \(id)")
//        
//        // Удаляем задачу из локального массива tasks
//        if let index = tasks.firstIndex(where: { $0.id == id }) {
//            print("🗑️ TodoViewModel: Removing task from local tasks array at index: \(index)")
//            tasks.remove(at: index)
//            objectWillChange.send() // Обновляем UI
//            print("✅ TodoViewModel: Task removed from UI")
//        } else {
//            print("ℹ️ TodoViewModel: Task not found in local tasks array")
//        }
//        
//        // Удаляем задачу из CoreData
//        print("🗑️ TodoViewModel: Deleting task from CoreData")
//        coreDataManager.deleteTask(byId: id)
//        
//        print("✅ TodoViewModel: Task deletion process completed")
//    }
    
    @MainActor
        func deleteTask(byId id: UUID)  {
            print("🗑️ TodoViewModel: Starting task deletion by id: \(id)")
            
            // Создаем временную копию массива, исключая удаляемую задачу
            tasks = tasks.filter { $0.id != id }
            
            // Обновляем UI немедленно
            print("🔄 TodoViewModel: Updating UI after filtering tasks")
            objectWillChange.send()
            
            // Удаляем из CoreData
            print("🗑️ TodoViewModel: Deleting task from CoreData")
            coreDataManager.deleteTask(byId: id)
            
            // Перезагружаем данные для синхронизации
            print("🔄 TodoViewModel: Reloading tasks from CoreData")
            loadTasksFromCoreData()
            
            print("✅ TodoViewModel: Task deletion process completed")
        }

    @MainActor
    func loadTasksFromCoreData() {
        print("📥 TodoViewModel: Starting to load tasks from CoreData")
        tasks = coreDataManager.fetchTasks()
        print("✅ TodoViewModel: Loaded \(tasks.count) tasks from CoreData")
    }


    
    @MainActor
    func clearAllData() {
        coreDataManager.deleteAllData()
        tasks = []
    }
}
