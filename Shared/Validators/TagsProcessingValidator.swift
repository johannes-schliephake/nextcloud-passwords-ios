protocol TagsProcessingValidating: Validating where Entity == [Tag] {}


struct TagsProcessingValidator: TagsProcessingValidating { // swiftlint:disable:this file_types_order
    
    func validate(_ entity: [Tag]) -> Bool {
        entity.contains { $0.state?.isProcessing == true }
    }
    
}


#if DEBUG

final class TagsProcessingValidatorMock: TagsProcessingValidating, Mock, FunctionCallLogging {
    
    var functionCallLog = [(functionName: String, parameters: [Any])]()
    
    var _validateEntity = false // swiftlint:disable:this identifier_name
    func validate(_ entity: [Tag]) -> Bool {
        logFunctionCall(parameters: [entity])
        return _validateEntity
    }
    
}

#endif
