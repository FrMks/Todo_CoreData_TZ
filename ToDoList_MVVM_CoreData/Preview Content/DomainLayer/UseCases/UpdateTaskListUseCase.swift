//
//  UpdateTaskListUseCase.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 21.01.2025.
//

import Foundation

final class UpdateTaskListUseCase {
    func execute(tasks: [TaskDomainEntity], updatedTask: TaskDomainEntity) -> [TaskDomainEntity] {
        var updatedTasks = tasks
        if let index = updatedTasks.firstIndex(where: { $0.id == updatedTask.id }) {
            updatedTasks[index] = updatedTask
        }
        return updatedTasks
    }
}
