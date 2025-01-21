//
//  TaskEditorViewModel.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 17.01.2025.
//

import Foundation

class TaskEditorViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var taskDescription: String = ""
    @Published var date: Date = Date()
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private var editingTask: TaskDomainEntity?
    private var originalTitle: String = ""
    private var originalDescription: String = ""
    
    private let createTaskUseCase: CreateTaskUseCase
    private let updateTaskUseCase: UpdateTaskUseCase
    
    init(
        editingTask: TaskDomainEntity? = nil,
        createTaskUseCase: CreateTaskUseCase = CreateTaskUseCase(taskRepository: TaskRepository()),
        updateTaskUseCase: UpdateTaskUseCase = UpdateTaskUseCase(taskRepository: TaskRepository())
    ) {
        self.editingTask = editingTask
        self.createTaskUseCase = createTaskUseCase
        self.updateTaskUseCase = updateTaskUseCase
        
        if let task = editingTask {
            self.title = task.title
            self.taskDescription = task.taskDescription
            self.date = task.date
            self.originalTitle = task.title
            self.originalDescription = task.taskDescription
        }
    }
    
    @MainActor
    func handleBackButton() async -> Bool {
        guard !title.isEmpty else {
            return false
        }
        
        if let editingTask = editingTask {
            do {
                let updatedTask = TaskDomainEntity(
                    id: editingTask.id,
                    title: title,
                    taskDescription: taskDescription,
                    date: date,
                    isCompleted: editingTask.isCompleted
                )
                try await updateTaskUseCase.execute(task: updatedTask)
                return true
            } catch {
                self.alertMessage = "Ошибка при обновлении задачи"
                self.showAlert = true
                return false
            }
        } else {
            do {
                let task = try await createTaskUseCase.execute(
                    id: UUID(),
                    title: title,
                    description: taskDescription,
                    date: date,
                    isCompleted: false
                )
                return true
            } catch {
                self.alertMessage = "Ошибка при создании задачи"
                self.showAlert = true
                return false
            }
        }
    }
    
    func clearFields() {
        title = ""
        taskDescription = ""
        date = Date()
    }
}
