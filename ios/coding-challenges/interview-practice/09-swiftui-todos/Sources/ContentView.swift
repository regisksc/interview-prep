import SwiftUI

struct ContentView: View {
    @State private var todos: [TodoItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var filter: TodoFilter = .all

    enum TodoFilter: String, CaseIterable {
        case all = "All"
        case completed = "Done"
        case pending = "Pending"
    }

    private var filteredTodos: [TodoItem] {
        switch filter {
        case .all: return todos
        case .completed: return todos.filter { $0.completed }
        case .pending: return todos.filter { !$0.completed }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading todos...")
                } else if let error = errorMessage {
                    VStack(spacing: 12) {
                        Text(error).foregroundStyle(.red)
                        Button("Retry") { Task { await loadTodos() } }
                    }
                } else {
                    VStack(spacing: 0) {
                        Picker("Filter", selection: $filter) {
                            ForEach(TodoFilter.allCases, id: \.self) { f in
                                Text(f.rawValue).tag(f)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()

                        List(filteredTodos) { todo in
                            HStack {
                                Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(todo.completed ? .green : .gray)
                                    .onTapGesture { toggleTodo(todo) }

                                Text(todo.todo)
                                    .strikethrough(todo.completed)
                                    .foregroundStyle(todo.completed ? .secondary : .primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Todos (\(filteredTodos.count))")
            .task { await loadTodos() }
        }
    }

    private func toggleTodo(_ todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].completed.toggle()
        }
    }

    private func loadTodos() async {
        isLoading = true
        errorMessage = nil
        do {
            guard let url = URL(string: "https://dummyjson.com/todos?limit=30") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(TodoResponse.self, from: data)
            todos = response.todos
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func partitionByPriority(_ todos: [TodoItem]) -> (doNow: [TodoItem], doLater: [TodoItem]) {
        return (doNow: [], doLater: [])
    }
}

#Preview { ContentView() }
