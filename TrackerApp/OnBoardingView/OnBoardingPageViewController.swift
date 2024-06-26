//
//  OnBoardingViewController.swift
//  TrackerApp
//
//  Created by Александр Акимов on 03.04.2024.
//

import UIKit

final class OnBoardingPageViewController: UIViewController {
    
    private let imageName: String
    private let labelText: String
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = UIColor(named: "Black 1")
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    private lazy var buttonNext: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "Black 1")
        button.layer.cornerRadius = 16
        button.setTitle(NSLocalizedString("onboarding.button", comment: "text for the button on onboarding page"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(pushButtonNext), for: .touchUpInside)
        return button
    }()
    
    init(imageName: String, labelText: String) {
        self.imageName = imageName
        self.labelText = labelText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    @objc private func pushButtonNext() {
        UserDefaults.standard.set("true", forKey: "Logined")
        let tabBarView = TabBarController()
        tabBarView.modalPresentationStyle = .fullScreen
        present(tabBarView, animated: true, completion: nil)
    }
    
    private func configure() {
        backgroundImageView.image = UIImage(named: imageName)
        view.addSubview(backgroundImageView)
        view.addSubview(textLabel)
        view.addSubview(buttonNext)
        
        NSLayoutConstraint.activate([
            buttonNext.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            buttonNext.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonNext.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonNext.heightAnchor.constraint(equalToConstant: 60),
            
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        textLabel.text = labelText
    }
}
