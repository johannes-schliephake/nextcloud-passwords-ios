import SwiftUI


struct EditLabeledRow: View {
    
    private let type: LabeledRow.RowType
    private let labelKey: LocalizedStringKey?
    private let labelString: String?
    @Binding private var stringValue: String
    @Binding private var intValue: Int
    private let bounds: ClosedRange<Int>?
    
    @State private var hideSecret = true
    @State private var numberStringValue: String
    private let isInt: Bool
    
    @_disfavoredOverload init(type: LabeledRow.RowType, label: String? = nil, value: Binding<String>) {
        self.type = type
        labelKey = nil
        self.labelString = label
        _stringValue = value
        _intValue = .constant(0)
        bounds = nil
        numberStringValue = ""
        isInt = false
    }
    
    init(type: LabeledRow.RowType, label: LocalizedStringKey, value: Binding<String>) {
        self.type = type
        self.labelKey = label
        labelString = nil
        _stringValue = value
        _intValue = .constant(0)
        bounds = nil
        numberStringValue = ""
        isInt = false
    }
    
    @_disfavoredOverload init(label: String? = nil, value: Binding<Int>, bounds: ClosedRange<Int>? = nil) {
        self.type = .text
        labelKey = nil
        self.labelString = label
        _stringValue = .constant("")
        _intValue = value
        self.bounds = bounds
        numberStringValue = String(value.wrappedValue)
        isInt = true
    }
    
    init(label: LocalizedStringKey, value: Binding<Int>, bounds: ClosedRange<Int>? = nil) {
        self.type = .text
        self.labelKey = label
        labelString = nil
        _stringValue = .constant("")
        _intValue = value
        self.bounds = bounds
        numberStringValue = String(value.wrappedValue)
        isInt = true
    }
    
    var body: some View {
        switch type {
        case .text:
            if isInt {
                intStack()
            }
            else {
                textStack()
            }
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
    
    private func intStack() -> some View {
        HStack {
            mainStack()
            Spacer()
            if let bounds = bounds {
                Stepper("", value: $intValue, in: bounds)
            }
            else {
                Stepper("", value: $intValue)
            }
        }
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
                Spacer()
            }
            else if let labelString = labelString {
                Text(labelString)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
            }
            switch type {
            case .text:
                if isInt {
                    TextField("-", text: $numberStringValue)
                        .keyboardType(.numberPad)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: numberStringValue) {
                            numberStringValue in
                            let numberStringValue = numberStringValue.filter { "0123456789-".contains($0) }
                            guard var intValue = Int(numberStringValue),
                                  self.intValue != intValue else {
                                self.numberStringValue = numberStringValue
                                return
                            }
                            if let bounds = bounds {
                                if bounds.lowerBound > 0 {
                                    intValue = intValue.clamped(to: 1...bounds.upperBound)
                                }
                                else if bounds.upperBound < 0 {
                                    intValue = intValue.clamped(to: bounds.lowerBound...(-1))
                                }
                                else {
                                    intValue = intValue.clamped(to: bounds)
                                }
                            }
                            self.intValue = intValue
                            self.numberStringValue = String(intValue)
                        }
                        .onChange(of: intValue) {
                            intValue in
                            let numberStringValue = String(intValue)
                            guard self.numberStringValue != numberStringValue else {
                                return
                            }
                            self.numberStringValue = numberStringValue
                        }
                }
                else {
                    TextField("-", text: $stringValue)
                }
            case .secret:
                if hideSecret {
                    ZStack(alignment: .leading) {
                        TextField("", text: .constant(""))
                            .font(.system(.body, design: .monospaced))
                            .disabled(true)
                            .hidden()
                        SecureField("-", text: $stringValue)
                            .foregroundColor(.primary)
                    }
                }
                else {
                    TextField("-", text: $stringValue)
                        .font(.system(.body, design: .monospaced))
                        .keyboardType(.alphabet)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            case .email:
                TextField("-", text: $stringValue)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            case .url, .file:
                TextField("-", text: $stringValue)
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            case .pin:
                TextField("-", text: $stringValue)
                    .font(.system(.body, design: .monospaced))
                    .keyboardType(.numberPad)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        }
    }
    
}
