import SwiftUI


struct LogPage: View {
    
    @StateObject var viewModel: AnyViewModel<LogViewModel.State, LogViewModel.Action>
    
    @ScaledMetric private var eventTypeIconWidth = 30.0
    
    var body: some View {
        listView()
            .navigationTitle("Log")
    }
    
    private func listView() -> some View {
        List {
            if viewModel[\.isAvailable] {
                Section {
                    warningLabel()
                    copyLogButton()
                } footer: {
                    logDescriptionFooter()
                }
                eventsSection()
            } else {
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
    
    private func copyLogButton() -> some View {
        Button {
            viewModel(.copyLog)
        } label: {
            Label("Copy Entire Log", systemImage: "doc.on.doc")
        }
    }
    
    private func logDescriptionFooter() -> some View {
        Text("The log might contain information useful for debugging purposes. It is not shared or uploaded by the app. The log is deleted when the app is hard-closed.")
    }
    
    private func eventsSection() -> some View {
        Section(header: Text("Events")) {
            ForEach(viewModel[\.events]) {
                event in
                HStack {
                    icon(for: event)
                        .frame(minWidth: eventTypeIconWidth, maxHeight: .infinity, alignment: .leading)
                    VStack(alignment: .leading, spacing: 6) {
                        LabeledRow(type: .text, label: event.dateDescription, value: event.message)
                        Group {
                            if #available(iOS 16, *) {
                                FlowView(spacing: 5, alignment: .leading) {
                                    ForEach(event.trace, id: \.self) {
                                        traceItem in
                                        HStack(spacing: 5) {
                                            Text(traceItem)
                                            if traceItem != event.trace.last {
                                                Image(systemName: "chevron.forward")
                                                    .foregroundColor(Color(.systemGray3))
                                            }
                                        }
                                    }
                                }
                            } else {
                                LegacyFlowView(event.trace, spacing: 5, alignment: .leading) {
                                    traceItem in
                                    HStack(spacing: 5) {
                                        Text(traceItem)
                                        if traceItem != event.trace.last {
                                            Image(systemName: "chevron.forward")
                                                .foregroundColor(Color(.systemGray3))
                                        }
                                    }
                                }
                            }
                        }
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .imageScale(.medium)
                        Button("Copy") {
                            viewModel(.copyEvent(event))
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
        }
    }
    
    @ViewBuilder private func icon(for event: LogEvent) -> some View {
        switch event.type {
        case .error:
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.yellow)
        case .info:
            Image(systemName: "info.circle")
                .foregroundColor(.gray)
        }
    }
    
}
