import SwiftUI
import Factory
import Combine


final class SessionController: ObservableObject {
    
    @LazyInjected(\.logger) private var logger
    
    @Published private(set) var state: State = .loading
    @Published private(set) var session: Session? {
        didSet {
            guard let session else {
                resolve(\.keychain).remove(key: "server")
                resolve(\.keychain).remove(key: "user")
                resolve(\.keychain).remove(key: "password")
                state = .loading
                challenge = nil
                cachedChallengePassword = nil
                keepaliveTimer?.invalidate()
                keepaliveTimer = nil
                subscriptions.removeAll()
                resolve(\.keychain).remove(key: "challengePassword")
                resolve(\.keychain).remove(key: "offlineKeychain")
                logger.reset()
                return
            }
            resolve(\.keychain).store(key: "server", value: session.server)
            resolve(\.keychain).store(key: "user", value: session.user)
            resolve(\.keychain).store(key: "password", value: session.password)
            
            session.$pendingRequestsAvailable
                .filter { $0 }
                .sink {
                    [weak self] _ in
                    self?.requestSession()
                }
                .store(in: &subscriptions)
            session.$pendingCompletionsAvailable
                .filter { $0 }
                .sink {
                    [weak self] _ in
                    self?.requestKeychain()
                }
                .store(in: &subscriptions)
            session.$invalidationReason
                .compactMap { $0 }
                .sink {
                    [weak self] invalidationReason in
                    self?.session = nil
                    switch invalidationReason {
                    case .logout:
                        break
                    case .deauthorization:
                        resolve(\.authenticationChallengeController).clearAcceptedCertificateHash()
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                            UIAlertController.presentGlobalAlert(title: "_appDeauthorized".localized, message: "_appDeauthorizedMessage".localized)
                        }
                    case .noConnection:
                        resolve(\.authenticationChallengeController).clearAcceptedCertificateHash()
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
    private var logoutSubscription: AnyCancellable?
    
    init() {
        guard let server = resolve(\.keychain).load(key: "server"),
              let user = resolve(\.keychain).load(key: "user"),
              let password = resolve(\.keychain).load(key: "password") else {
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
        guard let session else {
            return
        }
        
        session.sessionID = nil
        if state == .error {
            state = .loading
        }
        
        RequestSessionRequest(session: session).send {
            [weak self] response in
            guard let response else {
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
            
            if let challengePassword = resolve(\.keychain).load(key: "challengePassword") ?? self?.cachedChallengePassword {
                self?.solveChallenge(password: challengePassword)
            }
            else {
                self?.state = .onlineChallengeAvailable
            }
        }
    }
    
    private func requestKeychain() {
        guard let session else {
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
              resolve(\.keychain).load(key: "offlineKeychain") != nil else {
            state = .offline
            session.runPendingCompletions()
            return
        }
        
        if let challengePassword = resolve(\.keychain).load(key: "challengePassword") ?? cachedChallengePassword {
            solveChallenge(password: challengePassword)
        }
        else {
            state = .offlineChallengeAvailable
        }
    }
    
    func solveChallenge(password: String, store: Bool = false) {
        guard let session else {
            return
        }
        
        state = .loading
        
        if let challenge {
            guard let solution = Crypto.PWDv1r1.solve(challenge: challenge, password: password) else {
                state = .error
                session.runPendingRequestFailures()
                logger.log(error: "Failed to solve PWDv1r1 challenge")
                return
            }
            openSession(password: password, solution: solution, store: store)
        }
        else if let offlineKeychain = resolve(\.keychain).load(key: "offlineKeychain") {
            guard let keychain = Crypto.CSEv1r1.decrypt(keys: offlineKeychain, password: password) else {
                state = .offlineChallengeAvailable
                resolve(\.keychain).remove(key: "challengePassword")
                UIAlertController.presentGlobalAlert(title: "_incorrectPassword".localized, message: "_incorrectPasswordMessage".localized)
                logger.log(error: "Failed to decrypt offline keychain")
                return
            }
            session.keychain = keychain
            cachedChallengePassword = password
            if store {
                resolve(\.keychain).store(key: "challengePassword", value: password)
            }
            
            state = .offline
            session.runPendingCompletions()
        }
    }
    
    private func openSession(password: String? = nil, solution: String? = nil, store: Bool? = nil) {
        guard let session else {
            return
        }
        
        OpenSessionRequest(session: session, solution: solution).send {
            [weak self] response in
            guard let response else {
                if self?.state != .offline && self?.state != .offlineChallengeAvailable {
                    self?.state = .error
                }
                session.runPendingRequestFailures()
                return
            }
            
            if let password,
               solution != nil,
               let store {
                guard response.success,
                      let keys = response.keys["CSEv1r1"] else {
                    self?.state = .onlineChallengeAvailable
                    resolve(\.keychain).remove(key: "challengePassword")
                    UIAlertController.presentGlobalAlert(title: "_incorrectPassword".localized, message: "_incorrectPasswordMessage".localized)
                    self?.logger.log(error: "Failed to open session with client side encryption")
                    return
                }
                guard let keychain = Crypto.CSEv1r1.decrypt(keys: keys, password: password) else {
                    self?.state = .onlineChallengeAvailable
                    resolve(\.keychain).remove(key: "challengePassword")
                    UIAlertController.presentGlobalAlert(title: "_incorrectPassword".localized, message: "_incorrectPasswordMessage".localized)
                    self?.logger.log(error: "Failed to decrypt online keychain")
                    return
                }
                resolve(\.keychain).store(key: "offlineKeychain", value: keys)
                session.keychain = keychain
                self?.cachedChallengePassword = password
                if store {
                    resolve(\.keychain).store(key: "challengePassword", value: password)
                }
                self?.challenge = nil
            }
            else {
                guard response.success else {
                    self?.state = .error
                    session.runPendingRequestFailures()
                    self?.logger.log(error: "Failed to open session without client side encryption")
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
        keepaliveTimer = Timer.scheduledTimer(withTimeInterval: Double(resolve(\.settingsController).userSessionLifetime) - 30, repeats: false) {
            [weak self] _ in
            guard let session = self?.session else {
                return
            }
            KeepaliveSessionRequest(session: session).send {
                [weak self] response in
                guard let response,
                      response.success else {
                    return
                }
                self?.keepaliveSession()
            }
        }
    }
    
    func logout() {
        guard let session else {
            return
        }
        logoutSubscription = Future {
            promise in
            CloseSessionRequest(session: session).send { _ in promise(.success(())) }
            session.invalidate(reason: .logout)
        }
        .flatMapLatest {
            DeleteAppPasswordOCSRequest(session: session).publisher
                .replaceError(with: ())
        }
        .sink { resolve(\.authenticationChallengeController).clearAcceptedCertificateHash() }
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
