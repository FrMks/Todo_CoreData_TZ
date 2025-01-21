//
//  NetworkService.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 16.01.2025.
//

import Foundation

enum ErrorList: Error {
    case invalidURL
    case noData
    case decodingError
}

final class NetworkService {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    private func createURLComponents() -> URLComponents {
        var urlComponent = URLComponents()
        urlComponent.scheme = "https"
        urlComponent.host = "drive.google.com"
        urlComponent.path = "/uc"
        
        return urlComponent
    }
    
    private func createQueryItems() -> [URLQueryItem] {
        return [
            URLQueryItem(name: "export", value: "download"),
            URLQueryItem(name: "id", value: "1MXypRbK2CS9fqPhTtPonn580h1sHUs2W")
        ]
    }
    
    func fetchTodos() async throws -> [TodoDTO] {
        var urlComponents = createURLComponents()
        urlComponents.queryItems = createQueryItems()
        
        guard let url = urlComponents.url else {
            throw ErrorList.invalidURL
        }
        
        let request = URLRequest(url: url)
        
        let (data, _) = try await session.data(for: request)
        
        guard !data.isEmpty else {
            throw ErrorList.noData
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(TodoResponseDTO.self, from: data)
            return decodedResponse.todos
        } catch {
            throw ErrorList.decodingError
        }
    }
}
