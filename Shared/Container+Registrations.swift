import Factory
import CoreImage


extension Container {
    
    var configurationType: Factory<any Configurating.Type> {
        self { Configuration.self }
    }
    var editFolderViewModelType: Factory<any EditFolderViewModelProtocol.Type> {
        self { EditFolderViewModel.self }
    }
    var editOTPViewModelType: Factory<any EditOTPViewModelProtocol.Type> {
        self { EditOTPViewModel.self }
    }
    var folderValidationService: Factory<any FolderValidationServiceProtocol> {
        self { FolderValidationService() }
            .cached
    }
    var foldersService: Factory<any FoldersServiceProtocol> {
        self { FoldersService() }
            .cached
    }
    var logger: Factory<any Logging> {
        self { Logger() }
            .cached
    }
    var logViewModelType: Factory<any LogViewModelProtocol.Type> {
        self { LogViewModel.self }
    }
    var otpService: Factory<any OTPServiceProtocol> {
        self { OTPService() }
            .cached
    }
    var otpValidationService: Factory<any OTPValidationServiceProtocol> {
        self { OTPValidationService() }
            .cached
    }
    var pasteboardService: Factory<any PasteboardServiceProtocol> {
        self { PasteboardService() }
            .cached
    }
    var qrCodeGenerator: Factory<(any QRCodeGenerating)?> {
        self { CIFilter(name: "CIQRCodeGenerator") }
    }
    var qrCodeService: Factory<any QRCodeServiceProtocol> {
        self { QRCodeService() }
            .cached
    }
    var selectTagsViewModelType: Factory<any SelectTagsViewModelProtocol.Type> {
        self { SelectTagsViewModel.self }
    }
    var shareOTPViewModelType: Factory<any ShareOTPViewModelProtocol.Type> {
        self { ShareOTPViewModel.self }
    }
    var tagValidationService: Factory<any TagValidationServiceProtocol> {
        self { TagValidationService() }
            .cached
    }
    var tagsService: Factory<any TagsServiceProtocol> {
        self { TagsService() }
            .cached
    }
    
    // TODO: remove
    var entriesController: Factory<EntriesController> {
        self { .init() }
            .cached
    }
    
}
