import SwiftUI


struct LogPage: View {
    
    @StateObject private var loggingController = LoggingController.shared
    @ScaledMetric private var eventTypeIconWidth = 30.0
    
    var body: some View {
        listView()
            .navigationTitle("Log")
    }
    
    private func listView() -> some View {
        List {
            if let loggedEvents = loggingController.events,
               !loggedEvents.isEmpty {
                Section {
                    warningLabel()
                    copyLogButton(loggedEvents: loggedEvents)
                }
                footer: {
                    logDescriptionFooter()
                }
                eventsSection(loggedEvents: loggedEvents)
            }
            else {
                VStack(alignment: .center) {
                    Text("Logging inactive")
                        .foregroundColor(.gray)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color(UIColor.systemGroupedBackground))
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func warningLabel() -> some View {
        Label("This log might contain highly sensitive data", systemImage: "exclamationmark.triangle")
            .foregroundColor(.red)
    }
    
    private func copyLogButton(loggedEvents: [LoggingController.Event]) -> some View {
        Button {
            UIPasteboard.general.string = loggedEvents.map(String.init).joined(separator: "\n")
        }
        label: {
            Label("Copy Entire Log", systemImage: "doc.on.doc")
        }
    }
    
    private func logDescriptionFooter() -> some View {
        Text("The log might contain information useful for debugging purposes. It is not shared or uploaded by the app. The log is deleted when the app is hard-closed.")
    }
    
    private func eventsSection(loggedEvents: [LoggingController.Event]) -> some View {
        Section(header: Text("Events")) {
            ForEach(loggedEvents.reversed()) {
                loggedEvent in
                HStack {
                    eventIcon(loggedEvent: loggedEvent)
                        .frame(minWidth: eventTypeIconWidth, maxHeight: .infinity, alignment: .leading)
                    VStack(alignment: .leading, spacing: 6) {
                        LabeledRow(type: .text, label: loggedEvent.date.formattedString, value: loggedEvent.message)
                        HStack {
                            Button("Copy") {
                                UIPasteboard.general.string = String(describing: loggedEvent)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder private func eventIcon(loggedEvent: LoggingController.Event) -> some View {
        switch loggedEvent.type {
        case .error:
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.yellow)
        case .info:
            Image(systemName: "info.circle")
                .foregroundColor(.gray)
        }
    }
    
}
