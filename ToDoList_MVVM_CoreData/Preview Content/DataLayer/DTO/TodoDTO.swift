//
//  Todo.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 16.01.2025.
//

import Foundation
import CryptoKit

struct TodoDTO: Codable, Identifiable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
    
    
    // Вычисляемое свойство для преобразования Int в UUID
    var uuid: UUID {
        // Преобразуем Int в UUID
        var uuidBytes = [UInt8](repeating: 0, count: 16)
        
        // Копируем байты из Int в uuidBytes
        withUnsafeBytes(of: id) { idBytes in
            for i in 0..<min(MemoryLayout<Int>.size, uuidBytes.count) {
                uuidBytes[i] = idBytes[i]
            }
        }
        
        // Создаем UUID из массива байтов
        return UUID(uuid: (
            uuidBytes[0], uuidBytes[1], uuidBytes[2], uuidBytes[3],
            uuidBytes[4], uuidBytes[5], uuidBytes[6], uuidBytes[7],
            uuidBytes[8], uuidBytes[9], uuidBytes[10], uuidBytes[11],
            uuidBytes[12], uuidBytes[13], uuidBytes[14], uuidBytes[15]
        ))
    }
}
