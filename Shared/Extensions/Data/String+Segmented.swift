extension String {
    
    var segmented: String {
        switch count {
        case 0:
            return "--- ---"
        case 5, 6, 9:
            return self
                .enumerated()
                .reduce("") { "\($0)\($1.element)\($1.offset % 3 == 2 ? " " : "")" }
                .trimmingCharacters(in: [" "])
        default:
            return self
                .enumerated()
                .reduce("") { "\($0)\($1.element)\($1.offset % 4 == 3 ? " " : "")" }
                .trimmingCharacters(in: [" "])
        }
    }
    
}
