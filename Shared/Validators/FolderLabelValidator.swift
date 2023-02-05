protocol FolderLabelValidating: Validating where Entity == String {}


struct FolderLabelValidator: FolderLabelValidating { // swiftlint:disable:this file_types_order
    
    func validate(_ entity: String) -> Bool {
        1...48 ~= entity.count
    }
    
}


#if DEBUG

final class FolderLabelValidatorMock: FolderLabelValidating, Mock, FunctionCallLogging {
    
    var functionCallLog = [(functionName: String, parameters: [Any])]()
    
    var _validateEntity = false // swiftlint:disable:this identifier_name
    func validate(_ entity: String) -> Bool {
        logFunctionCall(parameters: [entity])
        return _validateEntity
    }
    
}

#endif
