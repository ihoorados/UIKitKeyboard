//
//  AuthenticationViewModel.swift
//  UIKitKeyboard
//
//  Created by Hoorad on 12/30/24.
//

import Combine
import Foundation

class AuthenticationViewModel: ObservableObject {
    
    // MARK: View State
    enum ViewState {
        case loading
        case success
        case failed
        case none
    }

    // MARK: Published properties
    @Published var email = ""
    @Published var password = ""
    @Published var state: ViewState = .none
    
    // MARK: Publisher
    var modelPubliser: Published<[ViewState]>.Publisher { $model }
    @Published private var model: [ViewState] = []

    var isValidUsernamePublisher: AnyPublisher<Bool, Never> {
        $email
            .map { $0.isValidEmail }
            .eraseToAnyPublisher()
    }

    var isValidPasswordPublisher: AnyPublisher<Bool, Never> {
        $password
            .map { !$0.isEmpty }
            .eraseToAnyPublisher()
    }

    var isSubmitEnabled: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isValidUsernamePublisher, isValidPasswordPublisher)
            .map { $0 && $1 }
            .eraseToAnyPublisher()
    }

    // MARK: Public Methode
    
    func submitLogin() {
        
        state = .loading
        // hardcoded 2 seconds delay, to simulate request
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
            guard let self = self else { return }
            // 7
            if self.isCorrectLogin() {
                self.state = .success
            } else {
                self.state = .failed
            }
        }
    }
    
    func isCorrectLogin() -> Bool {
        
        // hardcoded example
        return email == "hooradramezani@gmail.com" && password == "123456"
    }
}

extension String {

    var isValidEmail: Bool {
        return NSPredicate(
            format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        )
        .evaluate(with: self)
    }
}
