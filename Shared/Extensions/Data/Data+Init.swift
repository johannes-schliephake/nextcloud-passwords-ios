import Foundation


extension Data {
    
    static private let base32Alphabet: [Character: UInt8] = ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4, "F": 5, "G": 6, "H": 7, "I": 8, "J": 9, "K": 10, "L": 11, "M": 12, "N": 13, "O": 14, "P": 15, "Q": 16, "R": 17, "S": 18, "T": 19, "U": 20, "V": 21, "W": 22, "X": 23, "Y": 24, "Z": 25, "2": 26, "3": 27, "4": 28, "5": 29, "6": 30, "7": 31, "=": 0]
    
    init?(base32Encoded base32String: String) {
        let base32String = base32String.uppercased()
        guard (base32String.count * 5).isMultiple(of: 8),
              base32String.allSatisfy({ Data.base32Alphabet[$0] != nil }) else {
            return nil
        }
        
        var bytes = [UInt8](repeating: 0, count: base32String.count * 5 / 8)
        base32String
            .enumerated()
            .map {
                (index: Int, character: Character) in
                (index * 5 / 8, index * 5 % 8, (Data.base32Alphabet[character] ?? 0) << 3)
            }
            .forEach {
                byteIndex, bitIndex, bits in
                bytes[byteIndex] |= bits >> bitIndex
                if bitIndex + 5 > 8 {
                    bytes[byteIndex + 1] |= bits << (8 - bitIndex)
                }
            }
        
        self.init(bytes)
    }
    
}
