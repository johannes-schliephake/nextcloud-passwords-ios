import SwiftUI
import Combine


final class SessionController: ObservableObject {
    
    static let `default` = SessionController()
    
    @Published private(set) var state: State = .loading
    @Published var session: Session? {
        didSet {
            guard let session = session else {
                Keychain.default.remove(key: "server")
                Keychain.default.remove(key: "user")
                Keychain.default.remove(key: "password")
                state = .loading
                challenge = nil
                cachedChallengePassword = nil
                keepaliveTimer?.invalidate()
                keepaliveTimer = nil
                subscriptions.removeAll()
                Keychain.default.remove(key: "challengePassword")
                Keychain.default.remove(key: "offlineKeychain")
                return
            }
            Keychain.default.store(key: "server", value: session.server)
            Keychain.default.store(key: "user", value: session.user)
            Keychain.default.store(key: "password", value: session.password)
            
            session.$pendingRequestsAvailable
                .sink {
                    [weak self] pendingRequestsAvailable in
                    if pendingRequestsAvailable {
                        self?.requestSession()
                    }
                }
                .store(in: &subscriptions)
            session.$pendingCompletionsAvailable
                .sink {
                    [weak self] pendingCompletionsAvailable in
                    if pendingCompletionsAvailable {
                        self?.requestKeychain()
                    }
                }
                .store(in: &subscriptions)
            session.$invalidationReason
                .sink {
                    [weak self] invalidationReason in
                    guard let invalidationReason = invalidationReason else {
                        return
                    }
                    self?.session = nil
                    switch invalidationReason {
                    case .logout:
                        break
                    case .deauthorization:
                        AuthenticationChallengeController.default.clearAcceptedCertificateHash()
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                            UIAlertController.presentGlobalAlert(title: "_appDeauthorized".localized, message: "_appDeauthorizedMessage".localized)
                        }
                    case .noConnection:
                        AuthenticationChallengeController.default.clearAcceptedCertificateHash()
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                            UIAlertController.presentGlobalAlert(title: "_noConnection".localized, message: "_noConnectionMessage".localized)
                        }
                    }
                }
                .store(in: &subscriptions)
        }
    }
    
    private var challenge: Crypto.PWDv1r1.Challenge?
    private var cachedChallengePassword: String? {
        willSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(15)) {
                [weak self] in
                guard newValue == self?.cachedChallengePassword else {
                    return
                }
                self?.cachedChallengePassword = nil
            }
        }
    }
    private var keepaliveTimer: Timer?
    private var subscriptions = Set<AnyCancellable>()
    
    private init() {
        guard let server = Keychain.default.load(key: "server"),
              let user = Keychain.default.load(key: "user"),
              let password = Keychain.default.load(key: "password") else {
            return
        }
        session = Session(server: server, user: user, password: password)
    }
    
    private init(session: Session) {
        self.session = session
        state = .online
    }
    
    func attachSessionPublisher(_ sessionPublisher: AnyPublisher<Session, Never>) {
        sessionPublisher
            .sink { [weak self] in self?.session = $0 }
            .store(in: &subscriptions)
    }
    
    private func requestSession() {
        guard let session = session else {
            return
        }
        
        session.sessionID = nil
        if state == .error {
            state = .loading
        }
        
        RequestSessionRequest(session: session).send {
            [weak self] response in
            guard let response = response else {
                if self?.state != .offline && self?.state != .offlineChallengeAvailable {
                    self?.state = .error
                }
                session.runPendingRequestFailures()
                return
            }
            
            guard let challenge = response.challenge else {
                self?.openSession()
                return
            }
            self?.challenge = challenge
            
            if let challengePassword = Keychain.default.load(key: "challengePassword") ?? self?.cachedChallengePassword {
                self?.solveChallenge(password: challengePassword)
            }
            else {
                self?.state = .onlineChallengeAvailable
            }
        }
    }
    
    private func requestKeychain() {
        guard let session = session else {
            return
        }
        
        guard state != .onlineChallengeAvailable else {
            return
        }
        guard state != .online else {
            session.runPendingCompletions()
            return
        }
        guard session.keychain == nil,
              Keychain.default.load(key: "offlineKeychain") != nil else {
            state = .offline
            session.runPendingCompletions()
            return
        }
        
        if let challengePassword = Keychain.default.load(key: "challengePassword") ?? cachedChallengePassword {
            solveChallenge(password: challengePassword)
        }
        else {
            state = .offlineChallengeAvailable
        }
    }
    
    func solveChallenge(password: String, store: Bool = false) {
        guard let session = session else {
            return
        }
        
        state = .loading
        
        if let challenge = challenge {
            guard let solution = Crypto.PWDv1r1.solve(challenge: challenge, password: password) else {
                state = .error
                session.runPendingRequestFailures()
                return
            }
            openSession(password: password, solution: solution, store: store)
        }
        else if let offlineKeychain = Keychain.default.load(key: "offlineKeychain") {
            guard let keychain = Crypto.CSEv1r1.decrypt(keys: offlineKeychain, password: password) else {
                state = .offlineChallengeAvailable
                Keychain.default.remove(key: "challengePassword")
                UIAlertController.presentGlobalAlert(title: "_incorrectPassword".localized, message: "_incorrectPasswordMessage".localized)
                return
            }
            session.keychain = keychain
            cachedChallengePassword = password
            if store {
                Keychain.default.store(key: "challengePassword", value: password)
            }
            
            state = .offline
            session.runPendingCompletions()
        }
    }
    
    private func openSession(password: String? = nil, solution: String? = nil, store: Bool? = nil) {
        guard let session = session else {
            return
        }
        
        OpenSessionRequest(session: session, solution: solution).send {
            [weak self] response in
            guard let response = response else {
                if self?.state != .offline && self?.state != .offlineChallengeAvailable {
                    self?.state = .error
                }
                session.runPendingRequestFailures()
                return
            }
            
            if let password = password,
               solution != nil,
               let store = store {
                guard response.success,
                      let keys = response.keys["CSEv1r1"] else {
                    self?.state = .onlineChallengeAvailable
                    Keychain.default.remove(key: "challengePassword")
                    UIAlertController.presentGlobalAlert(title: "_incorrectPassword".localized, message: "_incorrectPasswordMessage".localized)
                    return
                }
                Keychain.default.store(key: "offlineKeychain", value: keys)
                let keychain = Crypto.CSEv1r1.decrypt(keys: keys, password: password)
                session.keychain = keychain
                self?.cachedChallengePassword = password
                if store {
                    Keychain.default.store(key: "challengePassword", value: password)
                }
                self?.challenge = nil
            }
            else {
                guard response.success else {
                    self?.state = .error
                    session.runPendingRequestFailures()
                    return
                }
            }
            
            self?.state = .online
            self?.keepaliveSession()
            session.runPendingRequests()
        }
    }
    
    private func keepaliveSession() {
        keepaliveTimer?.invalidate()
        keepaliveTimer = Timer.scheduledTimer(withTimeInterval: 9 * 60, repeats: false) {
            [weak self] _ in
            guard let session = self?.session else {
                return
            }
            KeepaliveSessionRequest(session: session).send {
                [weak self] response in
                guard let response = response,
                      response.success else {
                    return
                }
                self?.keepaliveSession()
            }
        }
    }
    
    func logout() {
        guard let session = session else {
            return
        }
        CloseSessionRequest(session: session).send { _ in AuthenticationChallengeController.default.clearAcceptedCertificateHash() }
        session.invalidate(reason: .logout)
    }
    
}


extension SessionController {
    
    enum State {
        
        case loading
        case offlineChallengeAvailable
        case onlineChallengeAvailable
        case offline
        case online
        case error
        
        var isChallengeAvailable: Bool {
            [.offlineChallengeAvailable, .onlineChallengeAvailable].contains(self)
        }
        
    }
    
}


extension SessionController: MockObject {
    
    static var mock: SessionController {
        SessionController(session: Session.mock)
    }
    
}
