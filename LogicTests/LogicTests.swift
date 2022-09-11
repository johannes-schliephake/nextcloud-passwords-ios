import XCTest


class LogicTests: XCTestCase {
    
    func test_stringScoreSearchTerm_emptyString() {
        XCTAssertEqual(0.0, "".score(searchTerm: ""))
        XCTAssertEqual(0.0, " ".score(searchTerm: " "))
        XCTAssertEqual(0.0, "string with multiple words".score(searchTerm: ""))
        XCTAssertEqual(0.0, "".score(searchTerm: "string with multiple words"))
    }
    
    func test_stringScoreSearchTerm_startOfString() {
        XCTAssertDescendingOrder(
            "string with multiple words".score(searchTerm: "string with multiple words"),
            "string with multiple words".score(searchTerm: "tring with multiple words"),
            "string with multiple words".score(searchTerm: "tring ith ultiple ords"),
            "string with multiple words".score(searchTerm: "")
        )
        XCTAssertEqual(1.0, "string with multiple words".score(searchTerm: "string with multiple words"))
        XCTAssertEqual(0.9, "string with multiple words".score(searchTerm: "tring with multiple words"), accuracy: 0.1)
        XCTAssertEqual(0.6, "string with multiple words".score(searchTerm: "tring ith ultiple ords"), accuracy: 0.1)
    }
    
    func test_stringScoreSearchTerm_consecutiveLetters() {
        XCTAssertDescendingOrder(
            "string with multiple words".score(searchTerm: "string with multiple words"),
            "string with multiple words".score(searchTerm: "string with multiple word"),
            "string with multiple words".score(searchTerm: "strng with multiple words"),
            "string with multiple words".score(searchTerm: "strng wth mltpl wrds"),
            "string with multiple words".score(searchTerm: "")
        )
        XCTAssertEqual(1.0, "string with multiple words".score(searchTerm: "string with multiple words"))
        XCTAssertEqual(0.9, "string with multiple words".score(searchTerm: "string with multiple word"), accuracy: 0.1)
        XCTAssertEqual(0.9, "string with multiple words".score(searchTerm: "strng with multiple words"), accuracy: 0.1)
        XCTAssertEqual(0.5, "string with multiple words".score(searchTerm: "strng wth mltpl wrds"), accuracy: 0.1)
    }
    
    func test_stringScoreSearchTerm_sameCase() {
        XCTAssertDescendingOrder(
            "String With Multiple WORDS".score(searchTerm: "String With Multiple WORDS"),
            "String With Multiple WORDS".score(searchTerm: "String With Multiple Words"),
            "String With Multiple WORDS".score(searchTerm: "String With Multiple words"),
            "String With Multiple WORDS".score(searchTerm: "String with multiple words"),
            "String With Multiple WORDS".score(searchTerm: "string with multiple words")
        )
        XCTAssertEqual(1.0, "String With Multiple WORDS".score(searchTerm: "String With Multiple WORDS"))
        XCTAssertEqual(0.925, "String With Multiple WORDS".score(searchTerm: "String With Multiple Words"), accuracy: 0.05)
        XCTAssertEqual(0.9, "String With Multiple WORDS".score(searchTerm: "String With Multiple words"), accuracy: 0.05)
        XCTAssertEqual(0.85, "String With Multiple WORDS".score(searchTerm: "String with multiple words"), accuracy: 0.05)
        XCTAssertEqual(0.825, "String With Multiple WORDS".score(searchTerm: "string with multiple words"), accuracy: 0.05)
    }
    
    func test_stringScoreSearchTerm_diacritics() {
        XCTAssertDescendingOrder(
            "string with multiple words".score(searchTerm: "string with multiple words"),
            "string with multiple wörds".score(searchTerm: "string with multiple words"),
            "string with multiplé wörds".score(searchTerm: "string with multiple words"),
            "strïng wíth mùltîple words".score(searchTerm: "string with multiple words")
        )
        XCTAssertEqual(1.0, "string with multiple words".score(searchTerm: "string with multiple words"))
        XCTAssertEqual(0.975, "string with multiple wörds".score(searchTerm: "string with multiple words"), accuracy: 0.05)
        XCTAssertEqual(0.95, "string with multiplé wörds".score(searchTerm: "string with multiple words"), accuracy: 0.05)
        XCTAssertEqual(0.9, "strïng wíth mùltîple words".score(searchTerm: "string with multiple words"), accuracy: 0.05)
    }
    
    func test_stringScoreSearchTerm_partialWords() {
        XCTAssertDescendingOrder(
            "string with multiple words".score(searchTerm: "string with multiple words"),
            "string with multiple words".score(searchTerm: "string with multiple wor"),
            "string with multiple words".score(searchTerm: "string w multiple words"),
            "string with multiple words".score(searchTerm: "str w multiple words"),
            "string with multiple words".score(searchTerm: "str w multiple wo"),
            "string with multiple words".score(searchTerm: "s w m w"),
            "string with multiple words".score(searchTerm: "")
        )
        XCTAssertEqual(1.0, "string with multiple words".score(searchTerm: "string with multiple words"))
        XCTAssertEqual(0.95, "string with multiple words".score(searchTerm: "string with multiple wor"), accuracy: 0.1)
        XCTAssertEqual(0.9, "string with multiple words".score(searchTerm: "string w multiple words"), accuracy: 0.1)
        XCTAssertEqual(0.75, "string with multiple words".score(searchTerm: "str w multiple words"), accuracy: 0.1)
        XCTAssertEqual(0.6, "string with multiple words".score(searchTerm: "str w multiple wo"), accuracy: 0.1)
        XCTAssertEqual(0.4, "string with multiple words".score(searchTerm: "s w m w"), accuracy: 0.1)
    }
    
    func test_stringScoreSearchTerm_wordCount() {
        XCTAssertDescendingOrder(
            "string with multiple words".score(searchTerm: "string with multiple words"),
            "string with multiple words".score(searchTerm: "string with multiple"),
            "string with multiple words".score(searchTerm: "string with"),
            "string with multiple words".score(searchTerm: "string"),
            "string with multiple words".score(searchTerm: "")
        )
        XCTAssertEqual(1.0, "string with multiple words".score(searchTerm: "string with multiple words"))
        XCTAssertEqual(0.85, "string with multiple words".score(searchTerm: "string with multiple"), accuracy: 0.1)
        XCTAssertEqual(0.7, "string with multiple words".score(searchTerm: "string with"), accuracy: 0.1)
        XCTAssertEqual(0.55, "string with multiple words".score(searchTerm: "string"), accuracy: 0.1)
    }
    
    func test_stringScoreSearchTerm_wordOrder() {
        XCTAssertDescendingOrder(
            "string with multiple words".score(searchTerm: "string with multiple words"),
            "string with multiple words".score(searchTerm: "string with words multiple"),
            "string with multiple words".score(searchTerm: "multiple words with string"),
            "string with multiple words".score(searchTerm: "words multiple with string")
        )
        XCTAssertEqual(1.0, "string with multiple words".score(searchTerm: "string with multiple words"))
        XCTAssertEqual(0.85, "string with multiple words".score(searchTerm: "string with words multiple"), accuracy: 0.1)
        XCTAssertEqual(0.7, "string with multiple words".score(searchTerm: "multiple words with string"), accuracy: 0.1)
        XCTAssertEqual(0.55, "string with multiple words".score(searchTerm: "words multiple with string"), accuracy: 0.1)
    }
    
    func test_stringScoreSearchTerm_acronym() {
        XCTAssertDescendingOrder(
            "string with multiple words".score(searchTerm: "swmw"),
            "string with multiple words".score(searchTerm: "swm"),
            "string with multiple words".score(searchTerm: "sw"),
            "string with multiple words".score(searchTerm: "")
        )
        XCTAssertEqual(0.7, "string with multiple words".score(searchTerm: "swmw"), accuracy: 0.1)
        XCTAssertEqual(0.5, "string with multiple words".score(searchTerm: "swm"), accuracy: 0.1)
        XCTAssertEqual(0.45, "string with multiple words".score(searchTerm: "sw"), accuracy: 0.1)
        
        XCTAssertDescendingOrder(
            "string with multiple words".score(searchTerm: "s"),
            "string with multiple words".score(searchTerm: "swmws"),
            "string with multiple words".score(searchTerm: "swmwsw")
        )
        XCTAssertEqual(0.2, "string with multiple words".score(searchTerm: "swmws"), accuracy: 0.1)
        XCTAssertEqual(0.1, "string with multiple words".score(searchTerm: "swmwsw"), accuracy: 0.1)
    }
    
    func test_stringScoreSearchTerm_penalty() {
        XCTAssertDescendingOrder(
            "string with multiple words".score(searchTerm: "multiple word strng", penalty: 0.0),
            "string with multiple words".score(searchTerm: "multiple word strng", penalty: 0.2),
            "string with multiple words".score(searchTerm: "multiple word strng", penalty: 0.4),
            "string with multiple words".score(searchTerm: "multiple word strng", penalty: 0.6),
            "string with multiple words".score(searchTerm: "multiple word strng", penalty: 0.8),
            "string with multiple words".score(searchTerm: "multiple word strng", penalty: 1.0)
        )
        XCTAssertEqual(0.70, "string with multiple words".score(searchTerm: "multiple word strng", penalty: 0.0), accuracy: 0.1)
        XCTAssertEqual(0.62, "string with multiple words".score(searchTerm: "multiple word strng", penalty: 0.2), accuracy: 0.1)
        XCTAssertEqual(0.54, "string with multiple words".score(searchTerm: "multiple word strng", penalty: 0.4), accuracy: 0.1)
        XCTAssertEqual(0.46, "string with multiple words".score(searchTerm: "multiple word strng", penalty: 0.6), accuracy: 0.1)
        XCTAssertEqual(0.38, "string with multiple words".score(searchTerm: "multiple word strng", penalty: 0.8), accuracy: 0.1)
        XCTAssertEqual(0.30, "string with multiple words".score(searchTerm: "multiple word strng", penalty: 1.0), accuracy: 0.1)
    }
    
    func test_stringScoreSearchTerm_substrings() {
        XCTAssertEqual("string".score(searchTerm: "tri"), "string".score(searchTerm: "ing"))
        XCTAssertGreaterThan("string".score(searchTerm: "str"), "string".score(searchTerm: "ing"))
    }
    
    func test_stringScoreSearchTerm_longString() {
        XCTAssertEqual(0.6, "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. string Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.".score(searchTerm: "string", penalty: 0.02), accuracy: 0.1)
    }
    
    func test_stringScoreSearchTerm_dampening() {
        /// When combining multiple scoring results it's best to dampen them because it's likely for e.g. a password entry to score high on multiple strings during search
        let scores = ["https://instagram.com".score(searchTerm: "pin"), "instagram".score(searchTerm: "pin")]
        let dampenedScore = scores
            .sorted { $0 > $1 }
            .enumerated()
            .map { $1 * pow(0.5, Double($0)) }
            .reduce(0.0, +)
        XCTAssertGreaterThan("Account PIN".score(searchTerm: "pin"), dampenedScore)
    }
    
    func test_urlScoreSearchUrl() {
        XCTAssertEqual(1.0, URL(string: "https://cloud.example.com")!.score(searchUrl: URL(string: "https://cloud.example.com")!), accuracy: 0.05)
        XCTAssertEqual(0.75, URL(string: "https://cloud.example.com")!.score(searchUrl: URL(string: "https://example.com")!), accuracy: 0.05)
        XCTAssertEqual(0.65, URL(string: "https://example.com")!.score(searchUrl: URL(string: "https://cloud.example.com")!), accuracy: 0.05)
        
        XCTAssertEqual(1.0, URL(string: "https://cloud.example.com/index.php/login?redirect_url=/index.php/apps/files")!.score(searchUrl: URL(string: "https://cloud.example.com/index.php/login?redirect_url=/index.php/apps/files")!), accuracy: 0.05)
        XCTAssertEqual(0.8, URL(string: "https://cloud.example.com/index.php/login?redirect_url=/index.php/apps/files")!.score(searchUrl: URL(string: "https://cloud.example.com")!), accuracy: 0.05)
        XCTAssertEqual(0.7, URL(string: "https://cloud.example.com")!.score(searchUrl: URL(string: "https://cloud.example.com/index.php/login?redirect_url=/index.php/apps/files")!), accuracy: 0.05)
        
        XCTAssertEqual(0.7, URL(string: "https://cloud.example.com/index.php/login?redirect_url=/index.php/apps/files")!.score(searchUrl: URL(string: "https://example.com")!), accuracy: 0.05)
        XCTAssertEqual(0.6, URL(string: "https://cloud.example.com")!.score(searchUrl: URL(string: "https://example.com/index.php/login?redirect_url=/index.php/apps/files")!), accuracy: 0.05)
        XCTAssertEqual(0.6, URL(string: "https://example.com/index.php/login?redirect_url=/index.php/apps/files")!.score(searchUrl: URL(string: "https://cloud.example.com")!), accuracy: 0.05)
        XCTAssertEqual(0.5, URL(string: "https://example.com")!.score(searchUrl: URL(string: "https://cloud.example.com/index.php/login?redirect_url=/index.php/apps/files")!), accuracy: 0.05)
    }
    
}


extension LogicTests {
    
    func XCTAssertDescendingOrder<T>(_ expressions: T..., file: StaticString = #filePath, line: UInt = #line) where T: Comparable {
        for (index, (lhs, rhs)) in zip(expressions, expressions[1...]).enumerated() {
            guard lhs > rhs else {
                XCTFail("XCTAssertDescendingOrder: Wrong order for elements at indices \(index) and \(index + 1), (\"\(lhs)\") is not greater than (\"\(rhs)\")", file: file, line: line)
                return
            }
        }
    }
    
}
