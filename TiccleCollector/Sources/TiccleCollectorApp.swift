import SwiftUI
import SwiftData

@main
struct TiccleCollectorApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Budget.self)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(modelContext: container.mainContext)
        }
        .modelContainer(container)
    }
}
