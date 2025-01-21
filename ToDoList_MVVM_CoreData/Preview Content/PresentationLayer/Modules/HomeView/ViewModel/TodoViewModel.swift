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
    private let filterTasksUseCase: FilterTasksUseCase
    private let updateTaskListUseCase: UpdateTaskListUseCase
    
    init(
        fetchLocalTasksUseCase: FetchLocalTasksUseCase,
        fetchRemoteTasksUseCase: FetchRemoteTasksUseCase,
        createTaskUseCase: CreateTaskUseCase,
        deleteTaskUseCase: DeleteTaskUseCase,
        toggleTaskCompletionUseCase: ToggleTaskCompletionUseCase,
        deleteAllTasksUseCase: DeleteAllTasksUseCase,
        filterTasksUseCase: FilterTasksUseCase,
        updateTaskListUseCase: UpdateTaskListUseCase
    ) {
        self.fetchLocalTasksUseCase = fetchLocalTasksUseCase
        self.fetchRemoteTasksUseCase = fetchRemoteTasksUseCase
        self.createTaskUseCase = createTaskUseCase
        self.deleteTaskUseCase = deleteTaskUseCase
        self.toggleTaskCompletionUseCase = toggleTaskCompletionUseCase
        self.deleteAllTasksUseCase = deleteAllTasksUseCase
        self.filterTasksUseCase = filterTasksUseCase
        self.updateTaskListUseCase = updateTaskListUseCase
    }
    
    convenience init() {
        let taskRepository = TaskRepository()
        self.init(
            fetchLocalTasksUseCase: FetchLocalTasksUseCase(taskRepository: taskRepository),
            fetchRemoteTasksUseCase: FetchRemoteTasksUseCase(taskRepository: taskRepository),
            createTaskUseCase: CreateTaskUseCase(taskRepository: taskRepository),
            deleteTaskUseCase: DeleteTaskUseCase(taskRepository: taskRepository),
            toggleTaskCompletionUseCase: ToggleTaskCompletionUseCase(taskRepository: taskRepository),
            deleteAllTasksUseCase: DeleteAllTasksUseCase(taskRepository: taskRepository),
            filterTasksUseCase: FilterTasksUseCase(),
            updateTaskListUseCase: UpdateTaskListUseCase()
        )
    }
    
    var filteredTasks: [TaskDomainEntity] {
        filterTasksUseCase.execute(tasks: tasks, searchText: searchText)
    }
    
    @MainActor
    func loadData() async {
        isLoading = true
        do {
            // 1. Load tasks from local storage (CoreData)
            let localTasks = try await fetchLocalTasksUseCase.execute()
            
            if localTasks.isEmpty {
                // 2. If there are no local tasks, load from the server
                let remoteTasks = try await fetchRemoteTasksUseCase.execute()
                
                // 3. Save tasks to local storage (CoreData)
                for task in remoteTasks {
                    try await createTaskUseCase.execute(
                        id: task.id,
                        title: task.title,
                        description: task.taskDescription,
                        date: task.date,
                        isCompleted: task.isCompleted
                    )
                }
                
                // 4. Updating the task list
                tasks = try await fetchLocalTasksUseCase.execute()
            } else {
                // 5. If there are local tasks, we use them
                tasks = localTasks
            }
        } catch {
            self.error = error
            print("❌ Error fetching tasks: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
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
            let updatedTask = TaskDomainEntity(
                id: task.id,
                title: task.title,
                taskDescription: task.taskDescription,
                date: task.date,
                isCompleted: !task.isCompleted // Инвертируем состояние
            )
            
            // Updating a task in CoreData
            try await toggleTaskCompletionUseCase.execute(task: updatedTask)
            
            // Updating a task in the local list
            tasks = updateTaskListUseCase.execute(tasks: tasks, updatedTask: updatedTask)
        } catch {
            print("❌ Error toggling task completion: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func clearAllData() async {
        do {
            tasks = []
            try await deleteAllTasksUseCase.execute()
        } catch {
            self.error = error
            print("❌ Error when deleting all data: \(error.localizedDescription)")
        }
    }
}
