//
//  Task+CoreDataProperties.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 16.01.2025.
//

import Foundation
import CoreData

extension TaskEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var isCompleted: Bool
    @NSManaged public var title: String
    @NSManaged public var taskDescription: String
    @NSManaged public var date: Date
}

extension TaskEntity: Identifiable { }
