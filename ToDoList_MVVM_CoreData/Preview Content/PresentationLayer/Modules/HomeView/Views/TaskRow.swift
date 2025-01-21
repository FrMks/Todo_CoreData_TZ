//
//  TaskRow.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 17.01.2025.
//

import SwiftUI
import Swift

struct TaskRow: View {
    let task: TaskDomainEntity
    @ObservedObject var viewModel: TodoViewModel
    @State private var isCompleted: Bool
    @State private var showingEditView = false
    
    init(task: TaskDomainEntity, viewModel: TodoViewModel, isCompleted: Bool) {
        self.task = task
        self.viewModel = viewModel
        _isCompleted = State(initialValue: task.isCompleted)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                statusButtonView
                titleTextView
                Spacer()
            }
            if !task.taskDescription.isEmpty {
                taskDescriptionView
            }
            
            dateView
            
        }
        .padding(.horizontal, 20)
        .contextMenu {
            Button(action: {
                showingEditView = true
            }) {
                Label("Редактировать", systemImage: "pencil")
            }
            
            Button(action: {
                // Add share functionality
            }) {
                Label("Поделиться", systemImage: "square.and.arrow.up")
            }
            
            Button(role: .destructive, action: {
                Task {
                    await viewModel.deleteTask(byId: task.id)
                }
                
                
            }) {
                Label("Удалить", systemImage: "trash")
            }
        }
        .overlay {
            NavigationLink(isActive: $showingEditView) {
                TaskEditorView(editingTask: task, todoViewModel: viewModel)
            } label: {
                EmptyView()
            }
            .opacity(0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension TaskRow {
    private var statusButtonView: some View {
        Button(action: {
            isCompleted.toggle()
            Task {
                await viewModel.toggleTaskCompletion(task: task)
            }
        }) {
            Image(isCompleted ? "DoneTask" : "TaskNotCompleted")
                .resizable()
                .frame(width: 24, height: 48)
                .animation(.easeInOut, value: isCompleted)
        }
    }
    private var titleTextView: some View {
        Text(task.title.prefix(30) + (task.title.count > 30 ? "..." : ""))
            .font(.system(size: 16))
            .foregroundColor(isCompleted ? Color.theme.whiteCustom.opacity(0.5) : Color.theme.whiteCustom)
            .strikethrough(isCompleted)
            .padding(.leading, 8)
    }
    private var taskDescriptionView: some View {
        Text(task.taskDescription.prefix(30) + (task.taskDescription.count > 30 ? "..." : ""))
            .font(.system(size: 12))
            .foregroundColor(isCompleted ? Color.theme.whiteCustom.opacity(0.5) : Color.theme.whiteCustom)
            .padding(.top, 6)
            .padding(.leading, 32)
    }
    private var dateView: some View {
        Text(task.date.formatToShortDate())
            .font(.system(size: 12))
            .foregroundStyle(Color.theme.whiteCustom.opacity(0.5))
            .padding(.top, 6)
            .padding(.leading, 32)
    }
}
