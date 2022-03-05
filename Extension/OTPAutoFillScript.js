var ExtensionPreprocessingJS = {
    
    run: function(arguments) {
        arguments.completionFunction({"url": document.URL})
    },
    
    finalize: function(arguments) {
        var currentOtp = arguments["currentOtp"]
        var otpField = document.querySelector("input[type=tel]") ?? document.querySelector("input[type=text]") ?? document.querySelector("input[type=password]") ?? document.querySelector("input[type=number]")
        if (currentOtp && otpField) {
            otpField.value = currentOtp
        }
    }
    
}
