import SwiftUI


struct LabeledRow: View {
    
    private let type: RowType
    private let labelKey: LocalizedStringKey?
    private let labelString: String?
    private let value: String
    private let copiable: Bool
    
    @State private var hideSecret = true
    
    @_disfavoredOverload init(type: RowType, label: String? = nil, value: String, copiable: Bool = false) {
        self.type = type
        labelKey = nil
        self.labelString = label
        self.value = value
        self.copiable = copiable
    }
    
    init(type: RowType, label: LocalizedStringKey, value: String, copiable: Bool = false) {
        self.type = type
        self.labelKey = label
        labelString = nil
        self.value = value
        self.copiable = copiable
    }
    
    var body: some View {
        switch type {
        case .text:
            textStack()
        case .secret:
            secretStack()
        case .email:
            emailStack()
        case .url:
            urlStack()
        case .file:
            fileStack()
        case .pin:
            textStack()
        }
    }
    
    private func textStack() -> some View {
        mainStack()
    }
    
    private func secretStack() -> some View {
        HStack {
            mainStack()
            Spacer()
            Button {
                hideSecret.toggle()
            }
            label: {
                Image(systemName: hideSecret ? "eye" : "eye.slash")
            }
            .buttonStyle(.borderless)
        }
    }
    
    private func emailStack() -> some View {
        HStack {
            mainStack()
            if let url = URL(string: "mailto:\(value)") {
                Spacer()
                Link(destination: url) {
                    Image(systemName: Password.CustomField.CustomFieldType.email.systemName)
                }
                .buttonStyle(.borderless)
            }
        }
    }
    
    private func urlStack() -> some View {
        HStack {
            mainStack()
            if let url = URL(string: value) {
                Spacer()
                Link(destination: url) {
                    Image(systemName: Password.CustomField.CustomFieldType.url.systemName)
                }
                .buttonStyle(.borderless)
            }
        }
    }
    
    private func fileStack() -> some View {
        HStack {
            mainStack()
            if let session = SessionController.default.session,
               let url = session.generateFileLink(for: value) {
                Spacer()
                Link(destination: url) {
                    Image(systemName: Password.CustomField.CustomFieldType.file.systemName)
                }
                .buttonStyle(.borderless)
            }
        }
    }
    
    private func mainStack() -> some View {
        VStack {
            if copiable {
                copiableStack()
            }
            else {
                labeledStack()
            }
        }
    }
    
    private func copiableStack() -> some View {
        Button {
            if type == .secret {
                UIPasteboard.general.privateString = value
            }
            else {
                UIPasteboard.general.string = value
            }
        }
        label: {
            labeledStack()
        }
        .disabled(value.isEmpty)
    }
    
    private func labeledStack() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if let labelKey {
                Text(labelKey)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            else if let labelString {
                Text(labelString)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            switch type {
            case .secret:
                Text(hideSecret ? "••••••••••••" : value)
                    .foregroundColor(.primary)
                    .apply {
                        view in
                        if #available(iOS 16, *) {
                            view
                                .monospaced()
                        }
                        else {
                            view
                                .font(.system(.body, design: .monospaced))
                        }
                    }
            case .pin:
                Text(value.segmented)
                    .foregroundColor(.primary)
                    .apply {
                        view in
                        if #available(iOS 16, *) {
                            view
                                .monospaced()
                        }
                        else {
                            view
                                .font(.system(.body, design: .monospaced))
                        }
                    }
            default:
                Text(!value.isEmpty ? value : "-")
                    .foregroundColor(.primary)
            }
        }
    }
    
}


extension LabeledRow {
    
    enum RowType: String {
        case text
        case secret
        case email
        case url
        case file
        case pin
    }
    
}
