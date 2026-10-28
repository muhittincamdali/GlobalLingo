import SwiftUI

/// The list of books on a shelf, with a counter and a delete button.
public struct ShelfView: View {
    let shelf: String
    let city: String
    @State private var books: [String] = []

    public init(shelf: String, city: String) {
        self.shelf = shelf
        self.city = city
    }

    public var body: some View {
        NavigationStack {
            List {
                Section("Books") {
                    ForEach(books, id: \.self) { Text(verbatim: $0) }
                }
                Text("\(books.count) books on \(shelf)")
                Text("Pull to refresh")
            }
            .navigationTitle("Shelf")
            .toolbar {
                Button("Delete all", role: .destructive) { books.removeAll() }
            }
        }
        // The shelf's city as a heading, in capital letters.
        Text(String(localized: "Pickup in \(city)").uppercased())
    }
}
