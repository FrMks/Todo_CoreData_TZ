//
//  FilterTasksUseCase.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 21.01.2025.
//

import Foundation

final class FilterTasksUseCase {
    func execute(tasks: [TaskDomainEntity], searchText: String) -> [TaskDomainEntity] {
        if searchText.isEmpty {
            return tasks
        }
        return tasks.filter { task in
            task.title.localizedCaseInsensitiveContains(searchText)
        }
    }
}
