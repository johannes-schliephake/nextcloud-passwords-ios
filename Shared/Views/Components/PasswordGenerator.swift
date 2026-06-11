import SwiftUI
import FactoryKit
import Combine


struct PasswordGenerator: View { // swiftlint:disable:this file_types_order
    
    @Binding var password: String
    @State var generateInitial = false
    
    // AppStorage freezes app on iOS 16 + 17
//    @AppStorage("generatorNumbers", store: Configuration.userDefaults) private var generatorNumbers = Configuration.defaults["generatorNumbers"] as! Bool
//    @AppStorage("generatorSpecial", store: Configuration.userDefaults) private var generatorSpecial = Configuration.defaults["generatorSpecial"] as! Bool
//    @AppStorage("generatorStrength", store: Configuration.userDefaults) private var generatorStrength = PasswordServiceRequest.Strength(rawValue: Configuration.defaults["generatorStrength"] as! Int) ?? .default
//    @AppStorage("generatorLength", store: Configuration.userDefaults) private var generatorLength = Configuration.defaults["generatorLength"] as! Int
//    @AppStorage("onDeviceGenerator", store: Configuration.userDefaults) private var onDeviceGenerator = Configuration.defaults["onDeviceGenerator"] as! Bool
    @State private var generatorNumbers = Configuration.userDefaults.bool(forKey: "generatorNumbers")
    @State private var generatorSpecial = Configuration.userDefaults.bool(forKey: "generatorSpecial")
    @State private var generatorStrength = PasswordServiceRequest.Strength(rawValue: Configuration.userDefaults.integer(forKey: "generatorStrength")) ?? .default
    @State private var generatorLength = Configuration.userDefaults.integer(forKey: "generatorLength")
    @State private var onDeviceGenerator = Configuration.userDefaults.bool(forKey: "onDeviceGenerator")
    
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
            generateInitial = false
            generatePassword()
        }
        .onChange(of: generatorNumbers) { Configuration.userDefaults.set($0, forKey: "generatorNumbers") }
        .onChange(of: generatorSpecial) { Configuration.userDefaults.set($0, forKey: "generatorSpecial") }
        .onChange(of: generatorStrength.rawValue) { Configuration.userDefaults.set($0, forKey: "generatorStrength") }
        .onChange(of: generatorLength) { Configuration.userDefaults.set($0, forKey: "generatorLength") }
        .onChange(of: onDeviceGenerator) { Configuration.userDefaults.set($0, forKey: "onDeviceGenerator") }
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
            if #unavailable(iOS 26) {
                Divider()
                    .padding(.trailing, -100)
            }
            Button {
                generatePassword()
            } label: {
                if #available(iOS 26, *) {
                    ZStack {
                        Label("_generatePassword", systemImage: "dice")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 34)
                        if showProgressView {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                } else {
                    HStack {
                        Label("_generatePassword", systemImage: "dice")
                        if showProgressView {
                            Spacer()
                            ProgressView()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .apply { view in
                if #available(iOS 26, *) {
                    view
                        .buttonStyle(.glassProminent)
                }
            }
            .disabled(showProgressView)
        }
    }
    
    private func segmentedSlider(_ label: String, tickCount: Int, labels: SegmentedSliderLabels? = nil, value: Binding<Int>, in bounds: ClosedRange<Int>) -> some View {
        HStack(spacing: 16) {
            Text(label)
            VStack(spacing: 4) {
                ZStack {
                    if #available(iOS 26, *) {
                        HStack {
                            Circle()
                                .frame(width: 3, height: 3)
                            ForEach(1..<tickCount, id: \.self) { _ in
                                Spacer()
                                Circle()
                                    .frame(width: 3, height: 3)
                            }
                        }
                        .foregroundColor(Color(white: 0.49, opacity: 0.22))
                        .padding(.horizontal, 17)
                        .offset(y: 8.5)
                    } else {
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
                    }
                    Slider(
                        value: .init(
                            get: { .init(value.wrappedValue) },
                            set: { value.wrappedValue = .init($0) }
                        ),
                        in: Double(bounds.lowerBound)...Double(bounds.upperBound),
                        step: 1
                    )
                }
                if let labels,
                   labels.leading != nil || labels.center != nil || labels.trailing != nil {
                    ZStack {
                        if let leading = labels.leading {
                            Text(leading)
                                .multilineTextAlignment(.leading)
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
                                .multilineTextAlignment(.center)
                                .frame(width: 36)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        if let trailing = labels.trailing {
                            Text(trailing)
                                .multilineTextAlignment(.trailing)
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
        guard let session = dependency(\.sessionController).session else {
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
            weak let `self` = self
            
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
