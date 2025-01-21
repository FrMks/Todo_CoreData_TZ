//
//  ContentView.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 16.01.2025.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @StateObject private var viewModel = TodoViewModel()
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.blackCustom.edgesIgnoringSafeArea(.all)
                VStack {
                    if viewModel.isLoading {
                        progressView
                    } else if let error = viewModel.error {
                        Text("Error: \(error.localizedDescription)")
                            .foregroundStyle(Color.theme.whiteCustom)
                    } else {
                        SearchBar(text: $viewModel.searchText)
                        if viewModel.filteredTasks.isEmpty && !viewModel.searchText.isEmpty{
                            Text("Ничего не найдено")
                                .foregroundStyle(Color.theme.grayCustom)
                                .padding(.top, 20)
                        } else {
                            tasksList
                        }
                        Spacer()
                        bottomBar
                    }
                }
                .navigationTitle("Задачи")
                .onAppear {
                    Task {
                        await viewModel.loadData()
                    }
                }
            }
            
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    NavigationView {
        HomeView()
    }
}

extension HomeView {
    private var bottomBar: some View {
        HStack {
            Spacer()
            Text("\(viewModel.tasks.count) Задач")
                .foregroundStyle(Color.theme.whiteCustom)
                .font(.system(size: 11))
            Spacer()
            NavigationLink(destination: TaskEditorView(todoViewModel: viewModel)) {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.yellow)
                    .font(.system(size: 20))
            }
            //MARK: if you want to delete everything from CoreData
//            Spacer()
//            Button(action: {
//                Task {
//                    await viewModel.clearAllData()
//                }
//                
//            }) {
//                Image(systemName: "trash")
//                    .foregroundStyle(.red)
//                    .font(.system(size: 20))
//            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.theme.grayCustom)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.theme.grayCustom)
                .offset(y: -0.5),
            alignment: .top
        )
    }
    private var progressView: some View {
        ProgressView("Loading...")
            .foregroundColor(Color.theme.whiteCustom)
    }
    private var tasksList: some View {
        List {
            ForEach(viewModel.filteredTasks, id: \.id) { task in
                TaskRow(task: task, viewModel: viewModel, isCompleted: task.isCompleted)
                    .listRowBackground(Color.black)
            }
            .onDelete { indexSet in
                print("🗑️ HomeView: Deleting tasks at indices: \(indexSet)")
                indexSet.forEach { index in
                    let taskToDelete = viewModel.filteredTasks[index]
                    Task {
                        await viewModel.deleteTask(byId: taskToDelete.id)
                    }
                    
                }
            }
        }
        .listStyle(.plain)
        .background(Color.black)
    }
}
