//
//  TaskEditorViewModel.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 17.01.2025.
//

import Foundation
import CoreData

class TaskEditorViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var taskDescription: String = ""
    @Published var date: Date = Date()
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let coreDataManager = CoreDataManager.shared
    private var editingTask: TaskEntity?
    private var originalTitle: String = ""
    private var originalDescription: String = ""
    
    init(editingTask: TaskEntity? = nil) {
        self.editingTask = editingTask
        self.date = editingTask?.date ?? Date()
        
        if let task = editingTask {
            self.title = task.title
            self.taskDescription = task.taskDescription
            self.originalTitle = task.title
            self.originalDescription = task.taskDescription
        }
    }
    
//    private func generateUniqueId() -> Int16 {
//        // Генерируем случайное число в диапазоне Int16
//        let randomId = Int16.random(in: Int16.min...Int16.max)
//        return randomId
//    }
    
    private func generateUniqueId() -> UUID {
        return UUID()
    }
    
    func handleBackButton() async -> Bool {
        guard !title.isEmpty else {
            print("❌ Title is empty, cancelling")
            return false
        }
        
        if let editingTask = editingTask {
            print("🔄 Updating existing task")
            // Обновляем только изменённые поля
            coreDataManager.updateTask(
                task: editingTask,
                title: title,
                taskDescription: taskDescription,
                date: date
            )
            return true
        } else {
            print("➕ Creating new task")
            let id = generateUniqueId()
            if let _ = await MainActor.run(body: {
                coreDataManager.createTask(
                    id: id,
                    title: title,
                    taskDescription: taskDescription,
                    date: date,
                    isCompleted: false
                )
            }) {
                print("✅ New task created successfully")
                return true
            }
            print("❌ Failed to create new task")
            return false
        }
    }

    
    private func hasChanges() -> Bool {
        return title != originalTitle || taskDescription != originalDescription
    }
    
    private func createNewTask() {
        let id = generateUniqueId()
        coreDataManager.createTask(
            id: id,
            title: title,
            taskDescription: taskDescription,
            date: date,
            isCompleted: false
        )
    }
    
//    func saveTask() -> Bool {
//        guard !title.isEmpty else {
//            alertMessage = "Введите название задачи"
//            showAlert = true
//            return false
//        }
//        
//        if let existingTask = editingTask {
//            // Обновляем существующую задачу
//            coreDataManager.updateTask(
//                task: existingTask,
//                title: title,
//                taskDescription: taskDescription,
//                date: date
//            )
//        } else {
//            // Создаем новую задачу
//            let id = Int16(Date().timeIntervalSince1970)
//            coreDataManager.createTask(
//                id: id,
//                title: title,
//                taskDescription: taskDescription,
//                date: date,
//                isCompleted: false
//            )
//        }
//        
//        return true
//    }
    
    func clearFields() {
        title = ""
        taskDescription = ""
        date = Date()
    }
    
}

