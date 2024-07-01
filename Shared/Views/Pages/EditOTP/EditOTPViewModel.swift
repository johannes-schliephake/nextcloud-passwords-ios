import Foundation
import Combine
import Factory


protocol EditOTPViewModelProtocol: ViewModel where State == EditOTPViewModel.State, Action == EditOTPViewModel.Action {
    
    init(otp: OTP, updateOtp: @escaping (OTP?) -> Void)
    
}


final class EditOTPViewModel: EditOTPViewModelProtocol {
    
    final class State: ObservableObject {
        
        let isCreating: Bool
        @Published var otpType: OTP.OTPType
        @Published var otpAlgorithm: Crypto.OTP.Algorithm
        @Published var otpSecret: String
        @Published var otpDigits: Int
        @Published var otpCounter: Int
        @Published var otpPeriod: Int
        @Published var showMore: Bool
        @Published fileprivate(set) var sharingUrl: URL?
        @Published fileprivate(set) var sharingAvailable: Bool
        @Published fileprivate(set) var previousFieldFocusable: Bool
        @Published fileprivate(set) var nextFieldFocusable: Bool
        @Published var showDeleteAlert: Bool
        @Published var showCancelAlert: Bool
        @Published fileprivate(set) var hasChanges: Bool
        @Published fileprivate(set) var editIsValid: Bool
        @Published var focusedField: FocusField?
        
        let shouldDismiss = Signal()
        
        init(isCreating: Bool, otpType: OTP.OTPType, otpAlgorithm: Crypto.OTP.Algorithm, otpSecret: String, otpDigits: Int, otpCounter: Int, otpPeriod: Int, showMore: Bool, sharingUrl: URL?, sharingAvailable: Bool, previousFieldFocusable: Bool, nextFieldFocusable: Bool, showDeleteAlert: Bool, showCancelAlert: Bool, hasChanges: Bool, editIsValid: Bool, focusedField: FocusField?) {
            self.isCreating = isCreating
            self.otpType = otpType
            self.otpAlgorithm = otpAlgorithm
            self.otpSecret = otpSecret
            self.otpDigits = otpDigits
            self.otpCounter = otpCounter
            self.otpPeriod = otpPeriod
            self.showMore = showMore
            self.sharingUrl = sharingUrl
            self.sharingAvailable = sharingAvailable
            self.previousFieldFocusable = previousFieldFocusable
            self.nextFieldFocusable = nextFieldFocusable
            self.showDeleteAlert = showDeleteAlert
            self.showCancelAlert = showCancelAlert
            self.hasChanges = hasChanges
            self.editIsValid = editIsValid
            self.focusedField = focusedField
        }
        
    }
    
    enum Action {
        case focusPreviousField
        case focusNextField
        case submit
        case deleteOTP
        case confirmDelete
        case applyToOTP
        case cancel
        case discardChanges
        case dismissKeyboard
    }
    
    enum FocusField: Hashable {
        case otpSecret
        case otpDigits
        case otpCounter
        case otpPeriod
    }
    
    @Injected(\.otpService) private var otpService
    @Injected(\.otpValidationService) private var otpValidationService
    @LazyInjected(\.logger) private var logger
    
    let state: State
    
    private let otp: OTP
    private let updateOtp: (OTP?) -> Void
    private var previousField: FocusField?
    private var nextField: FocusField?
    private var cancellables = Set<AnyCancellable>()
    
    init(otp: OTP, updateOtp: @escaping (OTP?) -> Void) {
        let showMore = !_otpService.wrappedValue.hasDefaults(otp: otp)
        state = .init(isCreating: otp.secret.isEmpty, otpType: otp.type, otpAlgorithm: otp.algorithm, otpSecret: otp.secret, otpDigits: otp.digits, otpCounter: otp.counter, otpPeriod: otp.period, showMore: showMore, sharingUrl: nil, sharingAvailable: false, previousFieldFocusable: false, nextFieldFocusable: false, showDeleteAlert: false, showCancelAlert: false, hasChanges: false, editIsValid: true, focusedField: otp.secret.isEmpty ? .otpSecret : nil)
        self.otp = otp
        self.updateOtp = updateOtp
        
        setupPipelines()
    }
    
    private func setupPipelines() {
        weak var `self` = self
        
        Publishers.CombineLatest6(
            state.$otpType,
            state.$otpAlgorithm,
            state.$otpSecret,
            state.$otpDigits,
            state.$otpCounter,
            state.$otpPeriod
        )
        .map { self?.otpService.otpUrl(type: $0, algorithm: $1, secret: $2, digits: $3, counter: $4, period: $5, issuer: self?.otp.issuer, accountname: self?.otp.accountname) }
        .sink { sharingUrl in
            self?.state.sharingUrl = sharingUrl
            self?.state.sharingAvailable = sharingUrl != nil
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest3(
            state.$focusedField,
            state.$showMore,
            state.$otpType
        )
        .map { focusedField, showMore, otpType in
            let previousField: FocusField?
            let nextField: FocusField?
            switch focusedField {
            case .otpSecret:
                previousField = nil
                nextField = showMore ? .otpDigits : nil
            case .otpDigits:
                previousField = .otpSecret
                nextField = otpType == .totp ? .otpPeriod : .otpCounter
            case .otpCounter, .otpPeriod:
                previousField = .otpDigits
                nextField = nil
            case nil:
                previousField = nil
                nextField = nil
            }
            return (previousField, nextField)
        }
        .sink { previousField, nextField in
            self?.previousField = previousField
            self?.nextField = nextField
            self?.state.previousFieldFocusable = previousField != nil
            self?.state.nextFieldFocusable = nextField != nil
        }
        .store(in: &cancellables)
        
        let counterHasChangesPublisher = Publishers.CombineLatest(
            state.$otpType,
            state.$otpCounter
        )
            .map { $0 == .hotp && $1 != self?.otp.counter }
        let periodHasChangesPublisher = Publishers.CombineLatest(
            state.$otpType,
            state.$otpPeriod
        )
            .map { $0 == .totp && $1 != self?.otp.period }
        Publishers.CombineLatest6(
            state.$otpType
                .map { $0 != self?.otp.type },
            state.$otpAlgorithm
                .map { $0 != self?.otp.algorithm },
            state.$otpSecret
                .map { $0 != self?.otp.secret },
            state.$otpDigits
                .map { $0 != self?.otp.digits },
            counterHasChangesPublisher,
            periodHasChangesPublisher
        )
        .map { $0 || $1 || $2 || $3 || $4 || $5 }
        .sink { self?.state.hasChanges = $0 }
        .store(in: &cancellables)
        
        Publishers.CombineLatest5(
            state.$otpType,
            state.$otpSecret,
            state.$otpDigits,
            state.$otpCounter,
            state.$otpPeriod
        )
        .compactMap { self?.otpValidationService.validate(type: $0, secret: $1, digits: $2, counter: $3, period: $4) }
        .sink { self?.state.editIsValid = $0 }
        .store(in: &cancellables)
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case .focusPreviousField:
            guard state.previousFieldFocusable,
                  let previousField else {
                logger.log(error: "View-ViewModel inconsistency encountered, this case shouldn't be reachable")
                return
            }
            state.focusedField = previousField
        case .focusNextField:
            guard state.nextFieldFocusable,
                  let nextField else {
                logger.log(error: "View-ViewModel inconsistency encountered, this case shouldn't be reachable")
                return
            }
            state.focusedField = nextField
        case .submit:
            if state.nextFieldFocusable {
                self(.focusNextField)
            } else {
                self(.applyToOTP)
            }
        case .deleteOTP:
            state.showDeleteAlert = true
        case .confirmDelete:
            updateOtp(nil)
            state.shouldDismiss()
        case .applyToOTP:
            guard let otp = otpService.makeOtp(type: state.otpType, algorithm: state.otpAlgorithm, secret: state.otpSecret, digits: state.otpDigits, counter: state.otpCounter, period: state.otpPeriod) else {
                logger.log(error: "View-ViewModel inconsistency encountered, this case shouldn't be reachable")
                return
            }
            updateOtp(otp)
            state.shouldDismiss()
        case .cancel:
            if state.hasChanges {
                state.showCancelAlert = true
            } else {
                state.shouldDismiss()
            }
        case .discardChanges:
            state.shouldDismiss()
        case .dismissKeyboard:
            state.focusedField = nil
        }
    }
    
}
