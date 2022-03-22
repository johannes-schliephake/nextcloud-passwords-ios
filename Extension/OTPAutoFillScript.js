var ExtensionPreprocessingJS = {
    
    otpFields: function() {
        const queries = ["input[id*=otp]", "input[name*=otp]", "input[inputmode=numeric]", "input[maxlength=1]", "input[type=tel]", "input[type=text]", "input[type=password]", "input[type=number]"]
        return queries
            .map(query => document.querySelectorAll(query))
            .map(nodeList => Array.from(nodeList))
            .map(nodes => nodes.filter(node => node.type != "hidden"))
            .map(nodes => nodes.filter(node => node.value.length == 0))
            .filter(nodes => nodes.length > 0)
    }(),
    
    run: function(arguments) {
        arguments.completionFunction({"url": document.URL, "hasField": this.otpFields.length > 0})
    },
    
    finalize: function(arguments) {
        const currentOtp = arguments["currentOtp"]
        const otpField = this.otpFields[0]
        if (currentOtp && otpField) {
            if (otpField.length == currentOtp.length) {
                otpField.forEach((digitField, index) => digitField.value = currentOtp[index])
            }
            else {
                otpField[0].value = currentOtp
            }
        }
    }
    
}
