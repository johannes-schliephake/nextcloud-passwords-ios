import SwiftUI


struct EditLabeledRow: View {
    
    private let type: LabeledRow.RowType
    private let labelKey: LocalizedStringKey?
    private let labelString: String?
    @Binding private var value: String
    
    @State private var hideSecret = true
    
    init(type: LabeledRow.RowType, label: LocalizedStringKey, value: Binding<String>) {
        self.type = type
        self.labelKey = label
        labelString = nil
        _value = value
    }
    
    init(type: LabeledRow.RowType, label: String, value: Binding<String>) {
        self.type = type
        labelKey = nil
        self.labelString = label
        _value = value
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
        }
    }
    
    private func textStack() -> some View {
        mainStack()
    }
    
    private func secretStack() -> some View {
        HStack {
            mainStack()
                .animation(nil)
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
        mainStack()
    }
    
    private func urlStack() -> some View {
        mainStack()
    }
    
    private func fileStack() -> some View {
        mainStack()
    }
    
    private func mainStack() -> some View {
        labeledStack()
    }
    
    private func labeledStack() -> some View {
        VStack(alignment: .leading) {
            if let labelKey = labelKey {
                Text(labelKey)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            else if let labelString = labelString {
                Text(labelString)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            if type == .secret {
                if hideSecret {
                    ZStack(alignment: .leading) {
                        TextField("", text: .constant(""))
                            .font(.system(.body, design: .monospaced))
                            .disabled(true)
                            .hidden()
                        SecureField("-", text: $value)
                            .foregroundColor(.primary)
                    }
                }
                else {
                    TextField("-", text: $value)
                        .font(.system(.body, design: .monospaced))
                        .keyboardType(.alphabet)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            else if type == .email {
                TextField("-", text: $value)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            else if type == .url || type == .file {
                TextField("-", text: $value)
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            else {
                TextField("-", text: $value)
            }
        }
    }
    
}
