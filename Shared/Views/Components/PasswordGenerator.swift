import SwiftUI
import Factory
import Combine


struct PasswordGenerator: View { // swiftlint:disable:this file_types_order
    
    @Binding var password: String
    var generateInitial = false
    
    @AppStorage("generatorNumbers", store: Configuration.userDefaults) private var generatorNumbers = Configuration.defaults["generatorNumbers"] as! Bool // swiftlint:disable:this force_cast
    @AppStorage("generatorSpecial", store: Configuration.userDefaults) private var generatorSpecial = Configuration.defaults["generatorSpecial"] as! Bool // swiftlint:disable:this force_cast
    @AppStorage("generatorStrength", store: Configuration.userDefaults) private var generatorStrength = PasswordServiceRequest.Strength(rawValue: Configuration.defaults["generatorStrength"] as! Int) ?? .default // swiftlint:disable:this force_cast
    @AppStorage("generatorLength", store: Configuration.userDefaults) private var generatorLength = Configuration.defaults["generatorLength"] as! Int // swiftlint:disable:this force_cast
    @AppStorage("onDeviceGenerator", store: Configuration.userDefaults) private var onDeviceGenerator = Configuration.defaults["onDeviceGenerator"] as! Bool // swiftlint:disable:this force_cast
    
    @ScaledMetric private var generatorLengthLabelWidth = 30
    @State private var showPasswordGenerator = false
    @State private var showPasswordServiceErrorAlert = false
    @State private var showAppExtensionWordlistErrorAlert = false
    @State private var showProgressView = false
    
    // MARK: Views
    
    var body: some View {
        Button {
            showPasswordGenerator = true
        }
        label: {
            Image(systemName: "slider.horizontal.3")
        }
        .buttonStyle(.borderless)
        .tooltip(isPresented: $showPasswordGenerator) {
            passwordGenerator()
        }
        .alert(isPresented: $showPasswordServiceErrorAlert) {
            Alert(title: Text("_error"), message: Text("_passwordServiceErrorMessage"))
        }
        .alert(isPresented: $showAppExtensionWordlistErrorAlert) {
            Alert(title: Text("_error"), message: Text(Strings.appExtensionWordlistErrorMessage))
        }
        .onChange(of: password) { _ in showPasswordGenerator = false }
        .onAppear {
            guard generateInitial,
                  password.isEmpty else {
                return
            }
            generatePassword()
        }
    }
    
    private func passwordGenerator() -> some View {
        VStack(spacing: 15) {
            VStack {
                Toggle("_numbers", isOn: $generatorNumbers)
                    .apply { view in
                        if #available(iOS 26, *) {
                            view
                                .padding(.vertical, 4)
                        }
                    }
                Toggle("_specialCharacters", isOn: $generatorSpecial)
                    .apply { view in
                        if #available(iOS 26, *) {
                            view
                                .padding(.vertical, 4)
                        }
                    }
                if onDeviceGenerator {
                    HStack {
                        segmentedSlider(
                            Strings.length,
                            tickCount: 9,
                            labels: .init(
                                leading: "8",
                                center: "36",
                                trailing: "64"
                            ),
                            value: $generatorLength,
                            in: 8...64
                        )
                        Text(String(generatorLength))
                            .bold()
                            .frame(width: generatorLengthLabelWidth, alignment: .trailing)
                    }
                } else {
                    segmentedSlider(
                        Strings.strength,
                        tickCount: PasswordServiceRequest.Strength.allCases.count,
                        labels: .init(
                            leading: Strings.low,
                            center: Strings.medium,
                            trailing: Strings.ultra
                        ),
                        value: .init(
                            get: { generatorStrength.rawValue },
                            set: { generatorStrength = PasswordServiceRequest.Strength(rawValue: $0) ?? generatorStrength }
                        ),
                        in: 0...PasswordServiceRequest.Strength.allCases.count - 1
                    )
                }
            }
            Divider()
                .padding(.trailing, -100)
            Button {
                generatePassword()
            }
            label: {
                HStack {
                    Label("_generatePassword", systemImage: "dice")
                    if showProgressView {
                        Spacer()
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .disabled(showProgressView)
        }
    }
    
    private func segmentedSlider(_ label: String, tickCount: Int, labels: SegmentedSliderLabels? = nil, value: Binding<Int>, in bounds: ClosedRange<Int>) -> some View {
        HStack(spacing: 16) {
            Text(label)
            VStack(spacing: 4) {
                if #available(iOS 26, *) {
                    Slider(
                        value: Binding(
                            get: { Double(value.wrappedValue) },
                            set: { value.wrappedValue = Int($0) }
                        ),
                        in: Double(bounds.lowerBound)...Double(bounds.upperBound),
                        label: {},
                        ticks: {
                            SliderTickContentForEach(
                                Array(
                                    stride(
                                        from: Double(bounds.lowerBound),
                                        through: Double(bounds.upperBound),
                                        by: Double(bounds.count / (tickCount - 1))
                                    )
                                ),
                                id: \.self,
                                content: SliderTick.init
                            )
                        }
                    )
                } else {
                    ZStack {
                        HStack {
                            Rectangle()
                                .frame(width: 4, height: 6)
                            ForEach(1..<tickCount, id: \.self) { _ in
                                Spacer()
                                Rectangle()
                                    .frame(width: 4, height: 6)
                            }
                        }
                        .foregroundColor(Color(white: 0.5, opacity: 0.23))
                        .padding(.horizontal, 11.5)
                        .offset(y: 5.5)
                        Slider(value: Binding(
                            get: { Double(value.wrappedValue) },
                            set: { value.wrappedValue = Int($0) }
                        ), in: Double(bounds.lowerBound)...Double(bounds.upperBound), step: 1)
                    }
                }
                if let labels,
                   labels.leading != nil || labels.center != nil || labels.trailing != nil {
                    ZStack {
                        if let leading = labels.leading {
                            Text(leading)
                                .frame(width: 36)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .apply { view in
                                    if #unavailable(iOS 26) {
                                        view
                                            .offset(x: -4.5)
                                    }
                                }
                        }
                        if let center = labels.center {
                            Text(center)
                                .frame(width: 36)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        if let trailing = labels.trailing {
                            Text(trailing)
                                .frame(width: 36)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .apply { view in
                                    if #unavailable(iOS 26) {
                                        view
                                            .offset(x: 4.5)
                                    }
                                }
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(.gray)
                }
            }
        }
    }
    
    private struct SegmentedSliderLabels {
        let leading: String?
        let center: String?
        let trailing: String?
    }
    
    // MARK: Functions
    
    private func generatePassword() {
        if onDeviceGenerator {
            generatePasswordOnDevice()
        } else {
            generatePasswordRemotely()
        }
    }
    
    private func generatePasswordOnDevice() {
        showProgressView = true
        Task {
            defer { showProgressView = false }
            let generatePasswordHelperViewModel = GeneratePasswordHelperViewModel()
            let password = await generatePasswordHelperViewModel(.generatePassword(includingNumbers: generatorNumbers, includingSpecialCharacters: generatorSpecial, length: generatorLength), returning: \.$password)
            guard let password, let password else {
                if generatePasswordHelperViewModel[\.hasFailedInsideAppExtension] {
                    showAppExtensionWordlistErrorAlert = true
                } else {
                    showPasswordServiceErrorAlert = true
                }
                return
            }
            self.password = password
        }
    }
    
    private func generatePasswordRemotely() {
        guard let session = SessionController.default.session else {
            showPasswordServiceErrorAlert = true
            return
        }
        
        showProgressView = true
        PasswordServiceRequest(session: session, strength: generatorStrength, numbers: generatorNumbers, special: generatorSpecial).send {
            password in
            showProgressView = false
            guard let password else {
                showPasswordServiceErrorAlert = true
                return
            }
            self.password = password
        }
    }
    
}


private class GeneratePasswordHelperViewModel: ViewModel {
    
    final class State: ObservableObject {
        
        @Published fileprivate(set) var password: String?
        fileprivate(set) var hasFailedInsideAppExtension: Bool
        
        init(password: String?, hasFailedInExtension: Bool) {
            self.password = password
            self.hasFailedInsideAppExtension = hasFailedInExtension
        }
        
    }
    
    enum Action {
        case generatePassword(includingNumbers: Bool, includingSpecialCharacters: Bool, length: Int)
    }
    
    @LazyInjected(\.generatePasswordUseCase) private var generatePasswordUseCase
    @LazyInjected(\.logger) private var logger
    
    let state: State
    
    private var cancellable: AnyCancellable?
    
    init() {
        state = .init(password: nil, hasFailedInExtension: false)
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .generatePassword(includingNumbers: includingNumbers, includingSpecialCharacters: includingSpecialCharacters, length: length):
            weak var `self` = self
            
            cancellable = Just((includingNumbers, includingSpecialCharacters, length))
                .receive(on: \.userInitiatedScheduler)
                .handle(with: generatePasswordUseCase, { .generatePassword(includingNumbers: $0, includingSpecialCharacters: $1, length: $2) }, publishing: \.$generatedPassword)
                .handleEvents(receiveFailure: { error in
                    self?.logger.log(error: error)
                    self?.state.hasFailedInsideAppExtension = (error as NSError).code == 4994
                })
                .optionalize()
                .replaceError(with: nil)
                .receive(on: \.mainScheduler)
                .sink { self?.state.password = $0 }
        }
    }
    
}
