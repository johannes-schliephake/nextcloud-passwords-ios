import XCTest
import Nimble
import Factory
@testable import Passwords


final class EditOTPViewModelTests: XCTestCase {
    
    @Injected(\.otp) private var otpMock
    
    @MockInjected(\.otpService) private var otpServiceMock: OTPServiceMock
    @MockInjected(\.otpValidationService) private var otpValidationServiceMock: OTPValidationServiceMock
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
    func testInit_givenExistingOTP_thenSetsInitialState() {
        otpServiceMock._hasDefaults = true
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        
        expect(editOTPViewModel[\.isCreating]).to(beFalse())
        expect(editOTPViewModel[\.otpType]).to(equal(otpMock.type))
        expect(editOTPViewModel[\.otpAlgorithm]).to(equal(otpMock.algorithm))
        expect(editOTPViewModel[\.otpSecret]).to(equal(otpMock.secret))
        expect(editOTPViewModel[\.otpDigits]).to(equal(otpMock.digits))
        expect(editOTPViewModel[\.otpCounter]).to(equal(otpMock.counter))
        expect(editOTPViewModel[\.otpPeriod]).to(equal(otpMock.period))
        expect(editOTPViewModel[\.showMore]).to(beFalse())
        expect(editOTPViewModel[\.sharingUrl]).to(beNil())
        expect(editOTPViewModel[\.sharingAvailable]).to(beFalse())
        expect(editOTPViewModel[\.previousFieldFocusable]).to(beFalse())
        expect(editOTPViewModel[\.nextFieldFocusable]).to(beFalse())
        expect(editOTPViewModel[\.showDeleteAlert]).to(beFalse())
        expect(editOTPViewModel[\.showCancelAlert]).to(beFalse())
        expect(editOTPViewModel[\.hasChanges]).to(beFalse())
        expect(editOTPViewModel[\.editIsValid]).to(beFalse())
        expect(editOTPViewModel[\.focusedField]).to(beNil())
    }
    
    func testInit_givenNewlyCreatedOTP_thenSetsInitialState() {
        otpServiceMock._hasDefaults = true
        let newOTP = OTP()!
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: newOTP) { _ in }
        
        expect(self.otpServiceMock).to(beCalled(.once, on: "hasDefaults(otp:)", withParameter: newOTP))
        expect(editOTPViewModel[\.isCreating]).to(beTrue())
        expect(editOTPViewModel[\.otpType]).to(equal(newOTP.type))
        expect(editOTPViewModel[\.otpAlgorithm]).to(equal(newOTP.algorithm))
        expect(editOTPViewModel[\.otpSecret]).to(equal(newOTP.secret))
        expect(editOTPViewModel[\.otpDigits]).to(equal(newOTP.digits))
        expect(editOTPViewModel[\.otpCounter]).to(equal(newOTP.counter))
        expect(editOTPViewModel[\.otpPeriod]).to(equal(newOTP.period))
        expect(editOTPViewModel[\.showMore]).to(beFalse())
        expect(editOTPViewModel[\.sharingUrl]).to(beNil())
        expect(editOTPViewModel[\.sharingAvailable]).to(beFalse())
        expect(editOTPViewModel[\.previousFieldFocusable]).to(beFalse())
        expect(editOTPViewModel[\.nextFieldFocusable]).to(beFalse())
        expect(editOTPViewModel[\.showDeleteAlert]).to(beFalse())
        expect(editOTPViewModel[\.showCancelAlert]).to(beFalse())
        expect(editOTPViewModel[\.hasChanges]).to(beFalse())
        expect(editOTPViewModel[\.editIsValid]).to(beFalse())
        expect(editOTPViewModel[\.focusedField]).to(equal(.otpSecret))
    }
    
    func testInit_givenNonDefaultOTP_thenSetsInitialState() {
        let nonDefaultOTP = OTP()!
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: nonDefaultOTP) { _ in }
        
        expect(self.otpServiceMock).to(beCalled(.once, on: "hasDefaults(otp:)", withParameter: nonDefaultOTP))
        expect(editOTPViewModel[\.isCreating]).to(beTrue())
        expect(editOTPViewModel[\.otpType]).to(equal(nonDefaultOTP.type))
        expect(editOTPViewModel[\.otpAlgorithm]).to(equal(nonDefaultOTP.algorithm))
        expect(editOTPViewModel[\.otpSecret]).to(equal(nonDefaultOTP.secret))
        expect(editOTPViewModel[\.otpDigits]).to(equal(nonDefaultOTP.digits))
        expect(editOTPViewModel[\.otpCounter]).to(equal(nonDefaultOTP.counter))
        expect(editOTPViewModel[\.otpPeriod]).to(equal(nonDefaultOTP.period))
        expect(editOTPViewModel[\.showMore]).to(beTrue())
        expect(editOTPViewModel[\.sharingUrl]).to(beNil())
        expect(editOTPViewModel[\.sharingAvailable]).to(beFalse())
        expect(editOTPViewModel[\.previousFieldFocusable]).to(beFalse())
        expect(editOTPViewModel[\.nextFieldFocusable]).to(beTrue())
        expect(editOTPViewModel[\.showDeleteAlert]).to(beFalse())
        expect(editOTPViewModel[\.showCancelAlert]).to(beFalse())
        expect(editOTPViewModel[\.hasChanges]).to(beFalse())
        expect(editOTPViewModel[\.editIsValid]).to(beFalse())
        expect(editOTPViewModel[\.focusedField]).to(equal(.otpSecret))
    }
    
    func testInit_whenChangingOtpProperties_thenCallsOtpService() {
        let newOtpType = OTP.OTPType.hotp
        let newOtpAlgorithm = Crypto.OTP.Algorithm.sha256
        let newOtpSecret = String.random()
        let newOtpDigits = 7
        let newOtpCounter = 1
        let newOtpPeriod = 1
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        
        editOTPViewModel[\.otpType] = newOtpType
        editOTPViewModel[\.otpAlgorithm] = newOtpAlgorithm
        editOTPViewModel[\.otpSecret] = newOtpSecret
        editOTPViewModel[\.otpDigits] = newOtpDigits
        editOTPViewModel[\.otpCounter] = newOtpCounter
        editOTPViewModel[\.otpPeriod] = newOtpPeriod
        
        expect(self.otpServiceMock).to(beCalled(.aSpecifiedAmount(7), on: "otpUrl(type:algorithm:secret:digits:counter:period:issuer:accountname:)", withParameters: OTP.OTPType.totp, Crypto.OTP.Algorithm.sha1, otpMock.secret, 6, 0, 30, otpMock.issuer, otpMock.accountname, atCallIndex: 0))
        expect(self.otpServiceMock).to(beCalled(.aSpecifiedAmount(7), on: "otpUrl(type:algorithm:secret:digits:counter:period:issuer:accountname:)", withParameters: newOtpType, Crypto.OTP.Algorithm.sha1, otpMock.secret, 6, 0, 30, otpMock.issuer, otpMock.accountname, atCallIndex: 1))
        expect(self.otpServiceMock).to(beCalled(.aSpecifiedAmount(7), on: "otpUrl(type:algorithm:secret:digits:counter:period:issuer:accountname:)", withParameters: newOtpType, newOtpAlgorithm, otpMock.secret, 6, 0, 30, otpMock.issuer, otpMock.accountname, atCallIndex: 2))
        expect(self.otpServiceMock).to(beCalled(.aSpecifiedAmount(7), on: "otpUrl(type:algorithm:secret:digits:counter:period:issuer:accountname:)", withParameters: newOtpType, newOtpAlgorithm, newOtpSecret, 6, 0, 30, otpMock.issuer, otpMock.accountname, atCallIndex: 3))
        expect(self.otpServiceMock).to(beCalled(.aSpecifiedAmount(7), on: "otpUrl(type:algorithm:secret:digits:counter:period:issuer:accountname:)", withParameters: newOtpType, newOtpAlgorithm, newOtpSecret, newOtpDigits, 0, 30, otpMock.issuer, otpMock.accountname, atCallIndex: 4))
        expect(self.otpServiceMock).to(beCalled(.aSpecifiedAmount(7), on: "otpUrl(type:algorithm:secret:digits:counter:period:issuer:accountname:)", withParameters: newOtpType, newOtpAlgorithm, newOtpSecret, newOtpDigits, newOtpCounter, 30, otpMock.issuer, otpMock.accountname, atCallIndex: 5))
        expect(self.otpServiceMock).to(beCalled(.aSpecifiedAmount(7), on: "otpUrl(type:algorithm:secret:digits:counter:period:issuer:accountname:)", withParameters: newOtpType, newOtpAlgorithm, newOtpSecret, newOtpDigits, newOtpCounter, newOtpPeriod, otpMock.issuer, otpMock.accountname, atCallIndex: 6))
    }
    
    func testInit_givenValidOtpProperties_whenChangingOtpProperties_thenUpdatesSharingProperties() {
        let urlMock = URL.random()
        otpServiceMock._otpUrl = urlMock
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        
        editOTPViewModel[\.otpType] = .hotp
        
        expect(editOTPViewModel[\.sharingUrl]).to(equal(urlMock))
        expect(editOTPViewModel[\.sharingAvailable]).to(beTrue())
    }
    
    func testInit_givenInvalidOtpProperties_whenChangingOtpProperties_thenUpdatesSharingProperties() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        
        editOTPViewModel[\.otpType] = .hotp
        
        expect(editOTPViewModel[\.sharingUrl]).to(beNil())
        expect(editOTPViewModel[\.sharingAvailable]).to(beFalse())
    }
    
    func testInit_givenFocusedFieldIsNil_thenSetsFieldFocusableProperties() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.focusedField] = nil
        
        expect(editOTPViewModel[\.previousFieldFocusable]).to(beFalse())
        expect(editOTPViewModel[\.nextFieldFocusable]).to(beFalse())
    }
    
    func testInit_givenFocusedFieldIsOtpSecretAndShowMoreIsFalse_thenSetsFieldFocusableProperties() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = false
        editOTPViewModel[\.focusedField] = .otpSecret
        
        expect(editOTPViewModel[\.previousFieldFocusable]).to(beFalse())
        expect(editOTPViewModel[\.nextFieldFocusable]).to(beFalse())
    }
    
    func testInit_givenFocusedFieldIsOtpSecretAndShowMoreIsTrue_thenSetsFieldFocusableProperties() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpSecret
        
        expect(editOTPViewModel[\.previousFieldFocusable]).to(beFalse())
        expect(editOTPViewModel[\.nextFieldFocusable]).to(beTrue())
    }
    
    func testInit_givenFocusedFieldIsOtpDigitsAndOtpTypeIsTotp_thenSetsFieldFocusableProperties() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpDigits
        editOTPViewModel[\.otpType] = .totp
        
        expect(editOTPViewModel[\.previousFieldFocusable]).to(beTrue())
        expect(editOTPViewModel[\.nextFieldFocusable]).to(beTrue())
    }
    
    func testInit_givenFocusedFieldIsOtpDigitsAndOtpTypeIsHotp_thenSetsFieldFocusableProperties() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpDigits
        editOTPViewModel[\.otpType] = .hotp
        
        expect(editOTPViewModel[\.previousFieldFocusable]).to(beTrue())
        expect(editOTPViewModel[\.nextFieldFocusable]).to(beTrue())
    }
    
    func testInit_givenFocusedFieldIsOtpCounter_thenSetsFieldFocusableProperties() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpCounter
        
        expect(editOTPViewModel[\.previousFieldFocusable]).to(beTrue())
        expect(editOTPViewModel[\.nextFieldFocusable]).to(beFalse())
    }
    
    func testInit_givenFocusedFieldIsOtpPeriod_thenSetsFieldFocusableProperties() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpPeriod
        
        expect(editOTPViewModel[\.previousFieldFocusable]).to(beTrue())
        expect(editOTPViewModel[\.nextFieldFocusable]).to(beFalse())
    }
    
    func testInit_whenChangingOtpType_thenSetsHasChangesToTrue() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        
        editOTPViewModel[\.otpType] = .hotp
        
        expect(editOTPViewModel[\.hasChanges]).to(beTrue())
    }
    
    func testInit_whenChangingOtpAlgorithm_thenSetsHasChangesToTrue() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        
        editOTPViewModel[\.otpAlgorithm] = .sha256
        
        expect(editOTPViewModel[\.hasChanges]).to(beTrue())
    }
    
    func testInit_whenChangingOtpSecret_thenSetsHasChangesToTrue() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        
        editOTPViewModel[\.otpSecret] = .random()
        
        expect(editOTPViewModel[\.hasChanges]).to(beTrue())
    }
    
    func testInit_whenChangingOtpDigits_thenSetsHasChangesToTrue() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        
        editOTPViewModel[\.otpDigits] = 7
        
        expect(editOTPViewModel[\.hasChanges]).to(beTrue())
    }
    
    func testInit_givenOtpTypeIsHotp_whenChangingOtpCounter_thenSetsHasChangesToTrue() {
        let otpMock = OTP(type: .hotp, algorithm: nil, secret: "", digits: nil, counter: nil, period: nil)!
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        
        editOTPViewModel[\.otpCounter] = 1
        
        expect(editOTPViewModel[\.hasChanges]).to(beTrue())
    }
    
    func testInit_givenOtpTypeIsTotp_whenChangingOtpCounter_thenSetsHasChangesToFalse() {
        let otpMock = OTP(type: .totp, algorithm: nil, secret: "", digits: nil, counter: nil, period: nil)!
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        
        editOTPViewModel[\.otpCounter] = 1
        
        expect(editOTPViewModel[\.hasChanges]).to(beFalse())
    }
    
    func testInit_givenOtpTypeIsTotp_whenChangingOtpPeriod_thenSetsHasChangesToTrue() {
        let otpMock = OTP(type: .totp, algorithm: nil, secret: "", digits: nil, counter: nil, period: nil)!
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        
        editOTPViewModel[\.otpPeriod] = 1
        
        expect(editOTPViewModel[\.hasChanges]).to(beTrue())
    }
    
    func testInit_givenOtpTypeIsHotp_whenChangingOtpPeriod_thenSetsHasChangesToFalse() {
        let otpMock = OTP(type: .hotp, algorithm: nil, secret: "", digits: nil, counter: nil, period: nil)!
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        
        editOTPViewModel[\.otpPeriod] = 1
        
        expect(editOTPViewModel[\.hasChanges]).to(beFalse())
    }
    
    func testInit_whenDoingAndUndoingChanges_thenSetsHasChangesToFalse() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        
        editOTPViewModel[\.otpType] = .hotp
        editOTPViewModel[\.otpAlgorithm] = .sha256
        editOTPViewModel[\.otpSecret] = .random()
        editOTPViewModel[\.otpDigits] = 7
        editOTPViewModel[\.otpCounter] = 1
        editOTPViewModel[\.otpPeriod] = 1
        editOTPViewModel[\.otpType] = otpMock.type
        editOTPViewModel[\.otpAlgorithm] = otpMock.algorithm
        editOTPViewModel[\.otpSecret] = otpMock.secret
        editOTPViewModel[\.otpDigits] = otpMock.digits
        editOTPViewModel[\.otpCounter] = otpMock.counter
        editOTPViewModel[\.otpPeriod] = otpMock.period
        
        expect(editOTPViewModel[\.hasChanges]).to(beFalse())
    }
    
    func testInit_whenChangingOtpType_thenCallsOtpService() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        let newOtpType = OTP.OTPType.hotp
        
        editOTPViewModel[\.otpType] = newOtpType
        
        expect(self.otpValidationServiceMock).to(beCalled(.twice, on: "validate(type:secret:digits:counter:period:)", withParameters: newOtpType, otpMock.secret, otpMock.digits, otpMock.counter, otpMock.period, atCallIndex: 1))
    }
    
    func testInit_whenChangingOtpType_thenUpdatesEditIsValid() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        let validateOtpMock = Bool.random()
        otpValidationServiceMock._validate = validateOtpMock
        
        editOTPViewModel[\.otpType] = OTP.OTPType.hotp
        
        expect(editOTPViewModel[\.editIsValid]).to(equal(validateOtpMock))
    }
    
    func testInit_whenChangingOtpSecret_thenUpdatesEditIsValid() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        let validateOtpMock = Bool.random()
        otpValidationServiceMock._validate = validateOtpMock
        
        editOTPViewModel[\.otpSecret] = .random()
        
        expect(editOTPViewModel[\.editIsValid]).to(equal(validateOtpMock))
    }
    
    func testInit_whenChangingOtpDigits_thenUpdatesEditIsValid() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        let validateOtpMock = Bool.random()
        otpValidationServiceMock._validate = validateOtpMock
        
        editOTPViewModel[\.otpDigits] = 7
        
        expect(editOTPViewModel[\.editIsValid]).to(equal(validateOtpMock))
    }
    
    func testInit_whenChangingOtpCounter_thenUpdatesEditIsValid() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        let validateOtpMock = Bool.random()
        otpValidationServiceMock._validate = validateOtpMock
        
        editOTPViewModel[\.otpCounter] = 1
        
        expect(editOTPViewModel[\.editIsValid]).to(equal(validateOtpMock))
    }
    
    func testInit_whenChangingOtpPeriod_thenUpdatesEditIsValid() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        let validateOtpMock = Bool.random()
        otpValidationServiceMock._validate = validateOtpMock
        
        editOTPViewModel[\.otpPeriod] = 1
        
        expect(editOTPViewModel[\.editIsValid]).to(equal(validateOtpMock))
    }
    
    func testCallAsFunction_givenFocusedFieldIsNil_whenCallingFocusPreviousField_thenDoesntSetFocusedField() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.focusedField] = nil
        
        editOTPViewModel(.focusPreviousField)
        
        expect(editOTPViewModel[\.focusedField]).to(beNil())
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpSecret_whenCallingFocusPreviousField_thenDoesntSetFocusedField() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.focusedField] = .otpSecret
        
        editOTPViewModel(.focusPreviousField)
        
        expect(editOTPViewModel[\.focusedField]).to(equal(.otpSecret))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpDigits_whenCallingFocusPreviousField_thenSetsFocusedField() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpDigits
        
        editOTPViewModel(.focusPreviousField)
        
        expect(editOTPViewModel[\.focusedField]).to(equal(.otpSecret))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpCounter_whenCallingFocusPreviousField_thenSetsFocusedField() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpCounter
        
        editOTPViewModel(.focusPreviousField)
        
        expect(editOTPViewModel[\.focusedField]).to(equal(.otpDigits))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpPeriod_whenCallingFocusPreviousField_thenSetsFocusedField() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpPeriod
        
        editOTPViewModel(.focusPreviousField)
        
        expect(editOTPViewModel[\.focusedField]).to(equal(.otpDigits))
    }
    
    func testCallAsFunction_givenFocusedFieldIsNil_whenCallingFocusNextField_thenDoesntSetFocusedField() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.focusedField] = nil
        
        editOTPViewModel(.focusNextField)
        
        expect(editOTPViewModel[\.focusedField]).to(beNil())
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpSecretAndShowMoreIsFalse_whenCallingFocusNextField_thenDoesntSetFocusedField() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = false
        editOTPViewModel[\.focusedField] = .otpSecret
        
        editOTPViewModel(.focusNextField)
        
        expect(editOTPViewModel[\.focusedField]).to(equal(.otpSecret))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpSecretAndShowMoreIsTrue_whenCallingFocusNextField_thenSetsFocusedField() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpSecret
        
        editOTPViewModel(.focusNextField)
        
        expect(editOTPViewModel[\.focusedField]).to(equal(.otpDigits))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpDigitsAndOtpTypeIsTotp_whenCallingFocusNextField_thenSetsFocusedField() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpDigits
        editOTPViewModel[\.otpType] = .totp
        
        editOTPViewModel(.focusNextField)
        
        expect(editOTPViewModel[\.focusedField]).to(equal(.otpPeriod))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpDigitsAndOtpTypeIsHotp_whenCallingFocusNextField_thenSetsFocusedField() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpDigits
        editOTPViewModel[\.otpType] = .hotp
        
        editOTPViewModel(.focusNextField)
        
        expect(editOTPViewModel[\.focusedField]).to(equal(.otpCounter))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpCounter_whenCallingFocusNextField_thenDoesntSetFocusedField() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpCounter
        
        editOTPViewModel(.focusNextField)
        
        expect(editOTPViewModel[\.focusedField]).to(equal(.otpCounter))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpPeriod_whenCallingFocusNextField_thenDoesntSetFocusedField() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpPeriod
        
        editOTPViewModel(.focusNextField)
        
        expect(editOTPViewModel[\.focusedField]).to(equal(.otpPeriod))
    }
    
    func testCallAsFunction_givenFocusedFieldIsNil_whenCallingSubmit_thenCallsOtpService() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.focusedField] = nil
        
        editOTPViewModel(.submit)
        
        expect(self.otpServiceMock).to(beCalled(.once, on: "makeOtp(type:algorithm:secret:digits:counter:period:)", withParameters: otpMock.type, otpMock.algorithm, otpMock.secret, otpMock.digits, otpMock.counter, otpMock.period))
    }
    
    func testCallAsFunction_givenFocusedFieldIsNilAndOtpIsReturned_whenCallingSubmit_thenCallsUpdateOtp() {
        let closure = ClosureMock()
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock, updateOtp: closure.log)
        otpServiceMock._makeOtp = otpMock
        editOTPViewModel[\.focusedField] = nil
        
        editOTPViewModel(.submit)
        
        expect(closure).to(beCalled(.once, withParameter: otpMock))
    }
    
    func testCallAsFunction_givenFocusedFieldIsNilAndNoOtpIsReturned_whenCallingSubmit_thenDoesntCallUpdateOtp() {
        let closure = ClosureMock()
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock, updateOtp: closure.log)
        editOTPViewModel[\.focusedField] = nil
        
        editOTPViewModel(.submit)
        
        expect(closure).toNot(beCalled())
    }
    
    func testCallAsFunction_givenFocusedFieldIsNilAndOtpIsReturned_whenCallingSubmit_thenShouldDismissEmits() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        otpServiceMock._makeOtp = otpMock
        editOTPViewModel[\.focusedField] = nil
        
        expect(editOTPViewModel[\.shouldDismiss]).to(emit(when: { editOTPViewModel(.submit) }))
    }
    
    func testCallAsFunction_givenFocusedFieldIsNilAndNoOtpIsReturned_whenCallingSubmit_thenShouldDismissDoesntEmit() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.focusedField] = nil
        
        expect(editOTPViewModel[\.shouldDismiss]).toNot(emit(when: { editOTPViewModel(.submit) }))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpSecretAndShowMoreIsFalse_whenCallingSubmit_thenCallsOtpService() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = false
        editOTPViewModel[\.focusedField] = .otpSecret
        
        editOTPViewModel(.submit)
        
        expect(self.otpServiceMock).to(beCalled(.once, on: "makeOtp(type:algorithm:secret:digits:counter:period:)", withParameters: otpMock.type, otpMock.algorithm, otpMock.secret, otpMock.digits, otpMock.counter, otpMock.period))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpSecretAndShowMoreIsFalseAndOtpIsReturned_whenCallingSubmit_thenCallsUpdateOtp() {
        let closure = ClosureMock()
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock, updateOtp: closure.log)
        otpServiceMock._makeOtp = otpMock
        editOTPViewModel[\.showMore] = false
        editOTPViewModel[\.focusedField] = .otpSecret
        
        editOTPViewModel(.submit)
        
        expect(closure).to(beCalled(.once, withParameter: otpMock))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpSecretAndShowMoreIsFalseAndNoOtpIsReturned_whenCallingSubmit_thenDoesntCallUpdateOtp() {
        let closure = ClosureMock()
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock, updateOtp: closure.log)
        editOTPViewModel[\.showMore] = false
        editOTPViewModel[\.focusedField] = .otpSecret
        
        editOTPViewModel(.submit)
        
        expect(closure).toNot(beCalled())
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpSecretAndShowMoreIsFalseAndOtpIsReturned_whenCallingSubmit_thenShouldDismissEmits() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        otpServiceMock._makeOtp = otpMock
        editOTPViewModel[\.showMore] = false
        editOTPViewModel[\.focusedField] = .otpSecret
        
        expect(editOTPViewModel[\.shouldDismiss]).to(emit(when: { editOTPViewModel(.submit) }))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpSecretAndShowMoreIsFalseAndNoOtpIsReturned_whenCallingSubmit_thenShouldDismissDoesntEmit() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = false
        editOTPViewModel[\.focusedField] = .otpSecret
        
        expect(editOTPViewModel[\.shouldDismiss]).toNot(emit(when: { editOTPViewModel(.submit) }))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpSecretAndShowMoreIsTrue_whenCallingSubmit_thenSetsFocusedField() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpSecret
        
        editOTPViewModel(.submit)
        
        expect(editOTPViewModel[\.focusedField]).to(equal(.otpDigits))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpDigitsAndOtpTypeIsTotp_whenCallingSubmit_thenSetsFocusedField() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpDigits
        editOTPViewModel[\.otpType] = .totp
        
        editOTPViewModel(.submit)
        
        expect(editOTPViewModel[\.focusedField]).to(equal(.otpPeriod))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpDigitsAndOtpTypeIsHotp_whenCallingSubmit_thenSetsFocusedField() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpDigits
        editOTPViewModel[\.otpType] = .hotp
        
        editOTPViewModel(.submit)
        
        expect(editOTPViewModel[\.focusedField]).to(equal(.otpCounter))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpCounter_whenCallingSubmit_thenCallsOtpService() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpCounter
        
        editOTPViewModel(.submit)
        
        expect(self.otpServiceMock).to(beCalled(.once, on: "makeOtp(type:algorithm:secret:digits:counter:period:)", withParameters: otpMock.type, otpMock.algorithm, otpMock.secret, otpMock.digits, otpMock.counter, otpMock.period))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpCounterAndOtpIsReturned_whenCallingSubmit_thenCallsUpdateOtp() {
        let closure = ClosureMock()
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock, updateOtp: closure.log)
        otpServiceMock._makeOtp = otpMock
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpCounter
        
        editOTPViewModel(.submit)
        
        expect(closure).to(beCalled(.once, withParameter: otpMock))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpCounterAndNoOtpIsReturned_whenCallingSubmit_thenDoesntCallUpdateOtp() {
        let closure = ClosureMock()
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock, updateOtp: closure.log)
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpCounter
        
        editOTPViewModel(.submit)
        
        expect(closure).toNot(beCalled())
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpCounterAndOtpIsReturned_whenCallingSubmit_thenShouldDismissEmits() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        otpServiceMock._makeOtp = otpMock
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpCounter
        
        expect(editOTPViewModel[\.shouldDismiss]).to(emit(when: { editOTPViewModel(.submit) }))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpCounterAndNoOtpIsReturned_whenCallingSubmit_thenShouldDismissDoesntEmit() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpCounter
        
        expect(editOTPViewModel[\.shouldDismiss]).toNot(emit(when: { editOTPViewModel(.submit) }))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpPeriod_whenCallingSubmit_thenCallsOtpService() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpPeriod
        
        editOTPViewModel(.submit)
        
        expect(self.otpServiceMock).to(beCalled(.once, on: "makeOtp(type:algorithm:secret:digits:counter:period:)", withParameters: otpMock.type, otpMock.algorithm, otpMock.secret, otpMock.digits, otpMock.counter, otpMock.period))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpPeriodAndOtpIsReturned_whenCallingSubmit_thenCallsUpdateOtp() {
        let closure = ClosureMock()
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock, updateOtp: closure.log)
        otpServiceMock._makeOtp = otpMock
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpPeriod
        
        editOTPViewModel(.submit)
        
        expect(closure).to(beCalled(.once, withParameter: otpMock))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpPeriodAndNoOtpIsReturned_whenCallingSubmit_thenDoesntCallUpdateOtp() {
        let closure = ClosureMock()
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock, updateOtp: closure.log)
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpPeriod
        
        editOTPViewModel(.submit)
        
        expect(closure).toNot(beCalled())
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpPeriodAndOtpIsReturned_whenCallingSubmit_thenShouldDismissEmits() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        otpServiceMock._makeOtp = otpMock
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpPeriod
        
        expect(editOTPViewModel[\.shouldDismiss]).to(emit(when: { editOTPViewModel(.submit) }))
    }
    
    func testCallAsFunction_givenFocusedFieldIsOtpPeriodAndNoOtpIsReturned_whenCallingSubmit_thenShouldDismissDoesntEmit() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.showMore] = true
        editOTPViewModel[\.focusedField] = .otpPeriod
        
        expect(editOTPViewModel[\.shouldDismiss]).toNot(emit(when: { editOTPViewModel(.submit) }))
    }
    
    func testCallAsFunction_whenCallingDeleteOtp_thenSetsShowDeleteAlertToTrue() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        
        editOTPViewModel(.deleteOTP)
        
        expect(editOTPViewModel[\.showDeleteAlert]).to(beTrue())
    }
    
    func testCallAsFunction_whenCallingConfirmDelete_thenCallsUpdateOtp() {
        let closure = ClosureMock()
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock, updateOtp: closure.log)
        
        editOTPViewModel(.confirmDelete)
        
        expect(closure).to(beCalled(.once, withParameter: nil as OTP?))
    }
    
    func testCallAsFunction_whenCallingConfirmDelete_thenShouldDismissEmits() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        
        expect(editOTPViewModel[\.shouldDismiss]).to(emit(when: { editOTPViewModel(.confirmDelete) }))
    }
    
    func testCallAsFunction_whenCallingApplyToOtp_thenCallsOtpService() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        
        editOTPViewModel(.applyToOTP)
        
        expect(self.otpServiceMock).to(beCalled(.once, on: "makeOtp(type:algorithm:secret:digits:counter:period:)", withParameters: otpMock.type, otpMock.algorithm, otpMock.secret, otpMock.digits, otpMock.counter, otpMock.period))
    }
    
    func testCallAsFunction_givenOtpIsReturned_whenCallingApplyToOtp_thenCallsUpdateOtp() {
        let closure = ClosureMock()
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock, updateOtp: closure.log)
        otpServiceMock._makeOtp = otpMock
        
        editOTPViewModel(.applyToOTP)
        
        expect(closure).to(beCalled(.once, withParameter: otpMock))
    }
    
    func testCallAsFunction_givenNoOtpIsReturned_whenCallingApplyToOtp_thenDoesntCallUpdateOtp() {
        let closure = ClosureMock()
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock, updateOtp: closure.log)
        
        editOTPViewModel(.applyToOTP)
        
        expect(closure).toNot(beCalled())
    }
    
    func testCallAsFunction_givenOtpIsReturned_whenCallingApplyToOtp_thenShouldDismissEmits() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        otpServiceMock._makeOtp = otpMock
        
        expect(editOTPViewModel[\.shouldDismiss]).to(emit(when: { editOTPViewModel(.applyToOTP) }))
    }
    
    func testCallAsFunction_givenNoOtpIsReturned_whenCallingApplyToOtp_thenShouldDismissDoesntEmit() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        
        expect(editOTPViewModel[\.shouldDismiss]).toNot(emit(when: { editOTPViewModel(.applyToOTP) }))
    }
    
    func testCallAsFunction_givenHasChangesIsTrue_whenCallingCancel_thenSetsShowCancelAlertToTrue() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.otpSecret] = .random()
        
        editOTPViewModel(.cancel)
        
        expect(editOTPViewModel[\.showCancelAlert]).to(beTrue())
    }
    
    func testCallAsFunction_givenHasChangesIsFalse_whenCallingCancel_thenShouldDismissEmits() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        
        expect(editOTPViewModel[\.shouldDismiss]).to(emit(when: { editOTPViewModel(.cancel) }))
    }
    
    func testCallAsFunction_givenHasChangesIsTrue_whenCallingDiscardChanges_thenShouldDismissEmits() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.otpSecret] = .random()
        
        expect(editOTPViewModel[\.shouldDismiss]).to(emit(when: { editOTPViewModel(.discardChanges) }))
    }
    
    func testCallAsFunction_givenHasChangesIsFalse_whenCallingDiscardChanges_thenShouldDismissEmits() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        
        expect(editOTPViewModel[\.shouldDismiss]).to(emit(when: { editOTPViewModel(.discardChanges) }))
    }
    
    func testCallAsFunction_whenCallingDismissKeyboard_thenSetsFocusedFieldToNil() {
        let editOTPViewModel: any EditOTPViewModelProtocol = EditOTPViewModel(otp: otpMock) { _ in }
        editOTPViewModel[\.focusedField] = .otpSecret
        
        editOTPViewModel(.dismissKeyboard)
        
        expect(editOTPViewModel[\.focusedField]).to(beNil())
    }
    
}
