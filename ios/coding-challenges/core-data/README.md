# Core Data Challenges

## Challenge 1: Basic Core Data Stack

**Time:** 25 minutes

### Requirements

1. Create a Core Data model with one entity: `Item`
2. Item has attributes: `name` (String), `createdAt` (Date)
3. Set up Core Data stack in AppDelegate
4. Create functions to save and fetch items

### Model Setup

```
Entity: Item
Attributes:
  - name: String
  - createdAt: Date
```

### Expected Code

```swift
class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyApp")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func save() {
        if context.hasChanges {
            try? context.save()
        }
    }
}
```

### Evaluation Criteria

- NSPersistentContainer setup
- Context access
- Save function

---

## Challenge 2: CRUD Operations

**Time:** 35 minutes

### Requirements

1. Create function to add new Item
2. Create function to fetch all Items
3. Create function to update Item
4. Create function to delete Item

### Expected Functions

```swift
func createItem(name: String) {
    let item = Item(context: context)
    item.name = name
    item.createdAt = Date()
    save()
}

func fetchItems() -> [Item] {
    let request: NSFetchRequest<Item> = Item.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
    return try? context.fetch(request) ?? []
}

func deleteItem(_ item: Item) {
    context.delete(item)
    save()
}
```

### Evaluation Criteria

- Entity creation
- Fetch request
- Delete operation
- Save after changes

---

## Challenge 3: Predicates and Filtering

**Time:** 30 minutes

### Requirements

1. Fetch items where name contains a string
2. Fetch items created after a date
3. Combine multiple predicates
4. Sort by multiple criteria

### Expected Code

```swift
func searchItems(query: String) -> [Item] {
    let request: NSFetchRequest<Item> = Item.fetchRequest()
    request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
    return try? context.fetch(request) ?? []
}

func fetchRecentItems(after date: Date) -> [Item] {
    let request: NSFetchRequest<Item> = Item.fetchRequest()
    request.predicate = NSPredicate(format: "createdAt > %@", date as NSDate)
    return try? context.fetch(request) ?? []
}
```

### Evaluation Criteria

- NSPredicate usage
- String matching
- Date comparison
- Multiple predicates

---

## Challenge 4: Relationships

**Time:** 40 minutes

### Requirements

1. Create two entities: `Category` and `Item`
2. Category has to-many relationship with Item
3. Item has to-one relationship with Category
4. Fetch items by category
5. Delete cascade when category is deleted

### Model Setup

```
Entity: Category
Attributes:
  - name: String
Relationships:
  - items: To-Many (Item)

Entity: Item
Attributes:
  - name: String
  - createdAt: Date
Relationships:
  - category: To-One (Category)
```

### Evaluation Criteria

- Relationship setup
- Inverse relationships
- Cascade delete rules
- Fetching across relationships

---

## Challenge 5: SwiftUI Integration

**Time:** 45 minutes

### Requirements

1. Create @FetchRequest for Items
2. Display items in List
3. Add new item with TextField
4. Swipe to delete
5. Auto-save on changes

### Expected Code

```swift
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.createdAt, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    Text(item.name ?? "Unknown")
                }
                .onDelete(perform: deleteItems)
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        offsets.map { items[$0] }.forEach(viewContext.delete)
        try? viewContext.save()
    }
}
```

### Evaluation Criteria

- @FetchRequest usage
- FetchedResults iteration
- Delete with offsets
- Context injection

---

## Challenge 6: Background Context

**Time:** 35 minutes

### Requirements

1. Create background context for heavy operations
2. Import data from JSON file
3. Show progress during import
4. Merge changes to main context

### Expected Code

```swift
func importDataInBackground() async {
    let backgroundContext = CoreDataStack.shared.persistentContainer.newBackgroundContext()
    
    await backgroundContext.perform {
        // Import data
        for item in items {
            let newItem = Item(context: backgroundContext)
            newItem.name = item.name
        }
        
        try? backgroundContext.save()
        
        await MainActor.run {
            CoreDataStack.shared.context.mergeChanges(fromContextDidSave: backgroundContext)
        }
    }
}
```

### Evaluation Criteria

- Background context creation
- perform block usage
- Save on background
- Merge changes to main

---

## Challenge 7: Migration

**Time:** 30 minutes

### Requirements

1. Create version 1 of data model
2. Create version 2 with new attribute
3. Enable automatic migration
4. Test migration with existing data

### Steps

1. Add new model version in Xcode
2. Add new attribute: `description` (String)
3. Enable automatic migration in persistent store setup
4. Test with existing database

### Expected Code

```swift
container.loadPersistentStores { description, error in
    if let error = error {
        fatalError("Migration failed: \(error)")
    }
}
// Automatic migration happens when model version changes
```

### Evaluation Criteria

- Model versioning
- Migration setup
- Testing with existing data

---

## Solutions

Reference solutions are in the `solutions/` directory.
