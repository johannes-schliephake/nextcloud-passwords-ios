import Foundation


enum NCPasswordsRequestError: Error {
    case requestError
}


struct NCPasswordsRequestErrorResponse: Decodable {
    
    let status: String
    let id: String
    let message: String
    
}


struct NCPasswordsRequestMessageResponse: Decodable {
    
    let message: String
    
}


protocol NCPasswordsRequest {
    
    associatedtype ResultType
    var requiresSession: Bool { get }
    func encode() throws -> Data?
    func send(completion: @escaping (ResultType?) -> Void)
    func decode(data: Data) throws -> ResultType?
    
}


extension NCPasswordsRequest {
    
    var requiresSession: Bool {
        true
    }
    
    func encode() -> Data? {
        nil
    }
    
}


extension NCPasswordsRequest {
    
    func get(action: String, session: Session, completion: @escaping (ResultType?) -> Void) {
        send(action: action, method: "GET", session: session, completion: completion)
    }
    
    func post(action: String, session: Session, completion: @escaping (ResultType?) -> Void) {
        send(action: action, method: "POST", session: session, completion: completion)
    }
    
    func patch(action: String, session: Session, completion: @escaping (ResultType?) -> Void) {
        send(action: action, method: "PATCH", session: session, completion: completion)
    }
    
    func delete(action: String, session: Session, completion: @escaping (ResultType?) -> Void) {
        send(action: action, method: "DELETE", session: session, completion: completion)
    }
    
    private func send(action: String, method: String, session: Session, completion: @escaping (ResultType?) -> Void) {
        guard session.isValid else {
            return
        }
        DispatchQueue.global(qos: .utility).async {
            guard !requiresSession || session.sessionID != nil else {
                session.append(pendingRequest: {
                    send(completion: completion)
                }, failure: {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                })
                return
            }
            
            guard let authorizationData = "\(session.user):\(session.password)".data(using: .utf8),
                  let serverUrl = URL(string: session.server) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            let body: Data?
            do {
                body = try encode()
            }
            catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
                LoggingController.shared.log(error: error)
                return
            }
            
            let url = serverUrl.appendingPathComponent("index.php/apps/passwords/api/1.0").appendingPathComponent(action)
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Basic \(authorizationData.base64EncodedString())", forHTTPHeaderField: "Authorization")
            request.setValue(session.sessionID, forHTTPHeaderField: "X-Api-Session")
            request.httpShouldHandleCookies = false
            request.httpBody = body
            
            NetworkClient.default.dataTask(with: request) {
                [self] data, response, _ in
                guard let data,
                      let response = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    LoggingController.shared.log(error: "Failed to retrieve response")
                    return
                }
                
                if let errorResponse = try? Configuration.jsonDecoder.decode(NCPasswordsRequestErrorResponse.self, from: data) {
                    switch (errorResponse.status, errorResponse.id) {
                    case ("error", "4ad27488"): /// "Authorized session required"
                        session.append(pendingRequest: {
                            send(completion: completion)
                        }, failure: {
                            DispatchQueue.main.async {
                                completion(nil)
                            }
                        })
                        return
                    case ("error", "b927b225"): /// "Too many failed login attempts"
                        session.invalidate(reason: .deauthorization)
                        return
                    default:
                        LoggingController.shared.log(info: "Unknown error response")
                    }
                }
                else if let messageResponse = try? Configuration.jsonDecoder.decode(NCPasswordsRequestMessageResponse.self, from: data) {
                    switch messageResponse.message {
                    case "Password login forbidden, use token instead":
                        session.invalidate(reason: .deauthorization)
                        return
                    case "Current user is not logged in":
                        session.invalidate(reason: .noConnection)
                        return
                    default:
                        LoggingController.shared.log(info: "Unknown message response")
                    }
                }
                if let sessionID = response.value(forHTTPHeaderField: "X-Api-Session") {
                    session.sessionID = sessionID
                }
                
                do {
                    let result = try decode(data: data)
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
                catch {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    LoggingController.shared.log(error: error)
                }
            }
            .resume()
        }
    }
    
}
