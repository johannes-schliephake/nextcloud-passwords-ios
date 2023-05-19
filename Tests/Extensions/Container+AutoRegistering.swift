import Factory
@testable import Passwords


extension Container: AutoRegistering {
    
    public func autoRegister() {
        Self.shared.configurationType.register { ConfigurationMock.self }
        Self.shared.editFolderViewModelType.register { EditFolderViewModelMock.self }
        Self.shared.editOTPViewModelType.register { EditOTPViewModelMock.self }
        Self.shared.folderValidationService.register { FolderValidationServiceMock() }
        Self.shared.foldersService.register { FoldersServiceMock() }
        Self.shared.logger.register { LoggerMock() }
        Self.shared.logViewModelType.register { LogViewModelMock.self }
        Self.shared.otpService.register { OTPServiceMock() }
        Self.shared.otpValidationService.register { OTPValidationServiceMock() }
        Self.shared.pasteboardService.register { PasteboardServiceMock() }
        Self.shared.qrCodeGenerator.cached.register { QRCodeGeneratorMock() }
        Self.shared.qrCodeService.register { QRCodeServiceMock() }
        Self.shared.selectTagsViewModelType.register { SelectTagsViewModelMock.self }
        Self.shared.shareOTPViewModelType.register { ShareOTPViewModelMock.self }
        Self.shared.tagValidationService.register { TagValidationServiceMock() }
        Self.shared.tagsService.register { TagsServiceMock() }
        
        // TODO: remove
        Self.shared.entriesController.register { .mock }
    }
    
}
