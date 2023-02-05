protocol FolderProcessingValidating: Validating where Entity == Folder {}


struct FolderProcessingValidator: FolderProcessingValidating { // swiftlint:disable:this file_types_order
    
    func validate(_ entity: Folder) -> Bool {
        entity.state?.isProcessing == true
    }
    
}


#if DEBUG

final class FolderProcessingValidatorMock: FolderProcessingValidating, Mock, FunctionCallLogging {
    
    var functionCallLog = [(functionName: String, parameters: [Any])]()
    
    var _validateEntity = false // swiftlint:disable:this identifier_name
    func validate(_ entity: Folder) -> Bool {
        logFunctionCall(parameters: [entity])
        return _validateEntity
    }
    
}

#endif
