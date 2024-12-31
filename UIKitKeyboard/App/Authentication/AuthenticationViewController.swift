//
//  AuthenticationViewController.swift
//  UIKitKeyboard
//
//  Created by Hoorad on 12/30/24.
//

import UIKit
import Combine

class AuthenticationViewController: UIViewController {

    
    // MARK: Dependency
    var viewModel = AuthenticationViewModel()
    var cancellables = Set<AnyCancellable>()
    
    private let scrollView: UIScrollView = {
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let scrollViewContainer: UIStackView = {
        
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Oops, incorrect email or password!"
        label.textColor = .white
        label.backgroundColor = .red
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        return label
    }()
    
    private var emailTextField: UITextField = {
        let textField = UITextField()
        textField.textContentType = .emailAddress
        textField.keyboardType = .emailAddress
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter email.."
        return textField
    }()
    
    private var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter password.."
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        return button
    }()
    
    
    private let headerView: UIImageView = {
        let view = UIImageView()
        view.heightAnchor.constraint(equalToConstant: 350).isActive = true
        view.image = UIImage(named: "login_image")
        view.contentMode = .scaleAspectFit
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .systemBackground
        self.setupUIViews()
        self.setupPublisher()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    

    private func setupUIViews(){
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(scrollViewContainer)
        
        self.scrollViewContainer.addArrangedSubview(self.headerView)
        self.scrollViewContainer.addArrangedSubview(self.emailTextField)
        self.scrollViewContainer.addArrangedSubview(self.passwordTextField)
        self.scrollViewContainer.addArrangedSubview(self.submitButton)
        self.scrollViewContainer.addArrangedSubview(self.errorLabel)

        self.scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        self.scrollViewContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        self.scrollViewContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        self.scrollViewContainer.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        self.scrollViewContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        self.scrollViewContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AuthenticationViewController.backgroundTap))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(AuthenticationViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AuthenticationViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.submitButton.addTarget(self, action: #selector(onSubmit), for: .touchUpInside)

    }
    
    private func setupPublisher(){
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: emailTextField)
            .map { ($0.object as! UITextField).text ?? "" }
            .assign(to: \.email, on: self.viewModel)
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: passwordTextField)
            .map { ($0.object as! UITextField).text ?? "" }
            .assign(to: \.password, on: self.viewModel)
            .store(in: &cancellables)
        
        // 2
        self.viewModel.isSubmitEnabled
            .assign(to: \.isEnabled, on: submitButton)
            .store(in: &cancellables)

        // 3
        self.viewModel.$state
            .sink { [weak self] state in
                switch state {
                case .loading:
                    self?.submitButton.isEnabled = false
                    self?.submitButton.setTitle("Loading..", for: .normal)
                    self?.hideError(true)
                case .success:
                    self?.resetButton()
                    self?.hideError(true)
                case .failed:
                    self?.resetButton()
                    self?.hideError(false)
                case .none:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    
    @objc func onSubmit() {

        self.viewModel.submitLogin()
    }

    func resetButton() {

        self.submitButton.setTitle("Login", for: .normal)
        self.submitButton.isEnabled = true
    }

    func hideError(_ isHidden: Bool) {
        
        self.errorLabel.alpha = isHidden ? 0 : 1
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height , right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func backgroundTap(_ sender: UITapGestureRecognizer) {
        
        // go through all of the textfield inside the view, and end editing thus resigning first responder
        // ie. it will trigger a keyboardWillHide notification
        self.view.endEditing(true)
    }
 
}
