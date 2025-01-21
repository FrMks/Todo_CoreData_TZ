//
//  TaskEditorView.swift
//  ToDoList_MVVM_CoreData
//
//  Created by Максим Французов on 17.01.2025.
//

import SwiftUI

struct TaskEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TaskEditorViewModel
    @ObservedObject var todoViewModel: TodoViewModel
    
    init(editingTask: TaskDomainEntity? = nil, todoViewModel: TodoViewModel) {
        _viewModel = StateObject(wrappedValue: TaskEditorViewModel(editingTask: editingTask))
        self.todoViewModel = todoViewModel
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                titleNameView
                dateView
                mainTextView
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    Task {
                        print("🔄 Starting back button task")
                        let shouldSave = await viewModel.handleBackButton()
                        print("📊 Should save result: \(shouldSave)")
                        
                        if shouldSave {
                            print("✅ Changes were saved, updating UI")
                            await MainActor.run {
                                Task {
                                    await todoViewModel.loadData()
                                }
                                
                                print("✅ UI updated, dismissing")
                                dismiss()
                            }
                        } else {
                            print("ℹ️ No changes to save, dismissing")
                            dismiss()
                        }
                    }
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                        Text("Назад")
                    }
                    .foregroundStyle(Color.theme.yellowCustom)
                }
            }

        }
        
    }
}

extension TaskEditorView {
    private var titleNameView: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $viewModel.title)
                .font(.system(size: 34))
                .foregroundStyle(Color.theme.whiteCustom)
                .scrollContentBackground(.hidden) // Убираем стандартный фон
                .background(Color.clear)
                .frame(height: calculateTextHeight()) // Динамическая высота
            
            if viewModel.title.isEmpty {
                Text("Название задачи")
                    .font(.system(size: 34))
                    .foregroundStyle(Color.theme.whiteCustom.opacity(0.5))
                    .padding(.top, 8)
                    .padding(.leading, 5)
            }
        }
        .padding(.horizontal, 20)
    }
    
    
    private var dateView: some View {
        HStack {
            // Дата
            Text(viewModel.date.formatToShortDate())
                .font(.system(size: 12))
                .foregroundStyle(Color.theme.whiteCustom.opacity(0.5))
                .padding(.leading, 20)
                .padding(.top, 8)
            Spacer()
        }
    }
    
    private var mainTextView: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $viewModel.taskDescription)
                .font(.system(size: 20))
                .foregroundStyle(Color.theme.whiteCustom)
                .scrollContentBackground(.hidden) // Убираем стандартный фон
                .background(Color.clear)
                .frame(maxHeight: .infinity)
            
            if viewModel.taskDescription.isEmpty {
                Text("Добавьте описание задачи...")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.theme.whiteCustom.opacity(0.5))
                    .padding(.top, 8)
                    .padding(.leading, 5)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    fileprivate func calculateTextHeight() -> CGFloat {
        let text = viewModel.title.isEmpty ? "Название задачи" : viewModel.title
        let width = UIScreen.main.bounds.width - 40 // Учитываем отступы (.horizontal, 20)
        let font = UIFont.systemFont(ofSize: 34)
        let attributes = [NSAttributedString.Key.font: font]
        let boundingRect = text.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
        )
        return max(boundingRect.height + 16, 50) // Минимальная высота 50
    }
}

// Добавляем extension для placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}

//#Preview {
//    TaskEditorView()
//}
