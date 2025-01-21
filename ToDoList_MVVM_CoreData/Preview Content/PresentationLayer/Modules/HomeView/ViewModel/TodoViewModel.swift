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
    @Published private(set) var tasks: [TaskDomainEntity] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    @Published var searchText: String = ""
    
    private let fetchLocalTasksUseCase: FetchLocalTasksUseCase
    private let fetchRemoteTasksUseCase: FetchRemoteTasksUseCase
    private let createTaskUseCase: CreateTaskUseCase
    private let deleteTaskUseCase: DeleteTaskUseCase
    private let toggleTaskCompletionUseCase: ToggleTaskCompletionUseCase
    private let deleteAllTasksUseCase: DeleteAllTasksUseCase
    
    init(
        fetchLocalTasksUseCase: FetchLocalTasksUseCase = FetchLocalTasksUseCase(taskRepository: TaskRepository()),
        fetchRemoteTasksUseCase: FetchRemoteTasksUseCase = FetchRemoteTasksUseCase(taskRepository: TaskRepository()),
        createTaskUseCase: CreateTaskUseCase = CreateTaskUseCase(taskRepository: TaskRepository()),
        deleteTaskUseCase: DeleteTaskUseCase = DeleteTaskUseCase(taskRepository: TaskRepository()),
        toggleTaskCompletionUseCase: ToggleTaskCompletionUseCase = ToggleTaskCompletionUseCase(taskRepository: TaskRepository()),
        deleteAllTasksUseCase: DeleteAllTasksUseCase = DeleteAllTasksUseCase(taskRepository: TaskRepository())
    ) {
        self.fetchLocalTasksUseCase = fetchLocalTasksUseCase
        self.fetchRemoteTasksUseCase = fetchRemoteTasksUseCase
        self.createTaskUseCase = createTaskUseCase
        self.deleteTaskUseCase = deleteTaskUseCase
        self.toggleTaskCompletionUseCase = toggleTaskCompletionUseCase
        self.deleteAllTasksUseCase = deleteAllTasksUseCase
    }
    
    // Отфильтрованные задачи на основе searchText
    var filteredTasks: [TaskDomainEntity] {
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
        do {
            // 1. Загружаем задачи из локального хранилища (CoreData)
            let localTasks = try await fetchLocalTasksUseCase.execute()
            print("🔄 Загружено задач из CoreData: \(localTasks.count)")
            
            if localTasks.isEmpty {
                print("ℹ️ Локальных задач нет, загружаем с сервера...")
                // 2. Если локальных задач нет, загружаем с сервера
                let remoteTasks = try await fetchRemoteTasksUseCase.execute()
                print("🔄 Загружено задач с сервера: \(remoteTasks.count)")
                
                // 3. Сохраняем задачи в локальное хранилище (CoreData)
                for task in remoteTasks {
                    try await createTaskUseCase.execute(
                        id: task.id,
                        title: task.title,
                        description: task.taskDescription,
                        date: task.date,
                        isCompleted: task.isCompleted
                    )
                }
                print("✅ Задачи сохранены в CoreData")
                
                // 4. Обновляем список задач
                tasks = try await fetchLocalTasksUseCase.execute()
            } else {
                print("ℹ️ Используем задачи из CoreData")
                // 5. Если локальные задачи есть, используем их
                tasks = localTasks
            }
        } catch {
            self.error = error
            print("❌ Error fetching tasks: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
//    @MainActor
//    func addTask(title: String, description: String) async {
//        do {
//            let task = try await createTaskUseCase.execute(id: <#UUID#>, title: title, description: description, date: Date(), isCompleted: false)
//            tasks.append(task)
//        } catch {
//            print("❌ Error creating task: \(error.localizedDescription)")
//        }
//    }
    
    @MainActor
    func deleteTask(byId id: UUID) async {
        do {
            try await deleteTaskUseCase.execute(byId: id)
            tasks.removeAll { $0.id == id }
        } catch {
            print("❌ Error deleting task: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func toggleTaskCompletion(task: TaskDomainEntity) async {
        do {
            // Создаем обновленную задачу с измененным состоянием isCompleted
            print("Создаем обновленную задачу с измененным состоянием isCompleted")
            print("ID задачи: \(task.id)")
            let updatedTask = TaskDomainEntity(
                id: task.id,
                title: task.title,
                taskDescription: task.taskDescription,
                date: task.date,
                isCompleted: !task.isCompleted // Инвертируем состояние
            )
            
            // Обновляем задачу в CoreData
            print("Обновляем задачу в CoreData \(updatedTask.id)")
            try await toggleTaskCompletionUseCase.execute(task: updatedTask)
            print("Обновили задачу в CoreData")
            
            // Обновляем задачу в локальном списке
            if let index = tasks.firstIndex(where: { $0.id == updatedTask.id }) {
                tasks[index] = updatedTask
            }
            print("Обновили задачу в локальном списке")
        } catch {
            print("❌ Error toggling task completion: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func clearAllData() async {
        do {
            tasks = []
            try await deleteAllTasksUseCase.execute()
            
            print("✅ Все данные успешно удалены")
        } catch {
            self.error = error
            print("❌ Ошибка при удалении всех данных: \(error.localizedDescription)")
        }
    }
}
