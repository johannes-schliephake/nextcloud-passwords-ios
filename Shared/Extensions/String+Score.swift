import Foundation


private extension String {
    
    /// Modified version of https://github.com/yichizhang/SwiftyStringScore
    func score(word: String, penalty: Double = 0.5) -> Double {
        if isEmpty || word.isEmpty {
            return 0.0
        }
        if self == word {
            return 1.0
        }
        
        let penalty = penalty.clamped(to: 0.0...1.0)
        
        var score = 0.0
        var penalties = 1.0
        var startAt = startIndex
        
        for character in word {
            guard let indexInString = range(of: String(character), options: [.caseInsensitive, .diacriticInsensitive], range: startAt..<endIndex)?.lowerBound else {
                penalties += penalty
                continue
            }
            score += startAt == indexInString
                ? 0.7 /// Consecutive letter & start-of-string bonus
                : 0.1
            
            /// Same case/diacritic bonus
            if self[indexInString] == character {
                score += 0.12
            }
            
            startAt = index(after: indexInString)
        }
        
        /// Reduce penalty for longer strings
        score = (score / Double(count) + score / Double(word.count)) * 0.5 / penalties
        return score
    }
    
}


extension String {
    
    func score(searchTerm: String, penalty: Double = 0.5) -> Double {
        /// Split into words
        let punctuationAndWhitespaces = CharacterSet(charactersIn: "<>|+=~").union(.punctuationCharacters).union(.whitespacesAndNewlines)
        let stringWords = replacingOccurrences(of: "'", with: "").components(separatedBy: punctuationAndWhitespaces).filter { !$0.isEmpty }
        let searchWords = searchTerm.replacingOccurrences(of: "'", with: "").components(separatedBy: punctuationAndWhitespaces).filter { !$0.isEmpty }
        
        if stringWords.isEmpty || searchWords.isEmpty {
            return 0.0
        }
        if self == searchTerm {
            return 1.0
        }
        
        let penalty = penalty.clamped(to: 0.0...1.0)
        
        /// Build a matrix that contains a score for each search word with every string word
        var scores = searchWords.map {
            searchWord in
            stringWords.map {
                stringWord in
                stringWord.score(word: searchWord, penalty: penalty)
            }
        }
        
        /// Create an array containing the indices of maximum scores
        let maxIndices = scores.map { $0.firstIndex(of: $0.max()!)! }
        
        /// Remove bad leading and trailing matches but penalize them later
        let matchedRange = maxIndices.min()!...maxIndices.max()!
        scores = scores.map { Array($0[matchedRange]) }
        
        /// Average remaining maximum scores for each search word
        var score = scores.map { $0.max()! }.avg()!
        
        /// Penalize missing words (removed above) and excess words (matched multiple times)
        let remainingStringWordsCount = scores.first?.count ?? 0
        let missingStringWordsCount = stringWords.count - remainingStringWordsCount
        score *= pow(1.0 - penalty * 0.3, Double(missingStringWordsCount))
        let excessStringWordsCount = max(0, remainingStringWordsCount - searchWords.count)
        score *= pow(0.9 - penalty * 0.3, Double(excessStringWordsCount))
        
        /// Reduce score for every out of order search word
        let outOfOrderCount = zip(maxIndices, maxIndices[1...]).reduce(0) { $0 + ($1.0 >= $1.1 ? 1 : 0) }
        score *= pow(0.95 - penalty * 0.3, Double(outOfOrderCount))
        
        score = score.clamped(to: 0.0...1.0)
        
        /// Increase score for acronyms
        let stringAcronym = String(stringWords.map { $0.first! })
        score += stringAcronym.score(word: searchTerm, penalty: 1.0) * 0.65
        
        return score.clamped(to: 0.0...1.0)
    }
    
}
