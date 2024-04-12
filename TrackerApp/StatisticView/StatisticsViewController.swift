//
//  StatisticsViewController.swift
//  TrackerApp
//
//  Created by Александр Акимов on 05.04.2024.
//

import UIKit

protocol StatisticsViewControllerDelegate {
    func hideImage()
}

final class StatisticsViewController: UIViewController, StatisticsViewControllerDelegate {
    
    private var titleLabel: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.text = NSLocalizedString("statisticView.title", comment: "title on Statistic page")
        text.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        text.textColor = UIColor(named: "Black [day]")
        return text
    }()
    
    private var completedDays: Int = {
        let num = UserDefaults.standard.integer(forKey: "Completed")
        return num
    }()
    
    private let numberText1: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.text = "0"
        text.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        text.textColor = UIColor(named: "Black [day]")
        text.textAlignment = .left
        return text
    }()
    
    private let descrText1: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.text = NSLocalizedString("statisticView.first", comment: "")
        text.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        text.textColor = UIColor(named: "Black [day]")
        text.textAlignment = .left
        return text
    }()
    
    private let numberText2: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.text = "0"
        text.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        text.textColor = UIColor(named: "Black [day]")
        text.textAlignment = .left
        return text
    }()
    
    private let descrText2: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.text = NSLocalizedString("statisticView.second", comment: "")
        text.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        text.textColor = UIColor(named: "Black [day]")
        text.textAlignment = .left
        return text
    }()
    
    private let numberText3: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.text = "0"
        text.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        text.textColor = UIColor(named: "Black [day]")
        text.textAlignment = .left
        return text
    }()
    
    private let descrText3: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.text = NSLocalizedString("statisticView.third", comment: "")
        text.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        text.textColor = UIColor(named: "Black [day]")
        text.textAlignment = .left
        return text
    }()
    
    private let numberText4: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.text = "0"
        text.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        text.textColor = UIColor(named: "Black [day]")
        text.textAlignment = .left
        return text
    }()
    
    private let descrText4: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.text = NSLocalizedString("statisticView.fourth", comment: "")
        text.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        text.textColor = UIColor(named: "Black [day]")
        text.textAlignment = .left
        return text
    }()
    
    private let mainView1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let mainView2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let mainView3: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let mainView4: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "StatisticImage.png")
        return image
    }()
    
    private let textNotFoundLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.text = NSLocalizedString("statisticView.textNotFound", comment: "")
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(named: "Black [day]")
        return label
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = UIColor(named: "White")
        view.layer.cornerRadius = 16
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureConstraits()
        hideImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideImage()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hideImage()
    }
    
    override func viewDidLayoutSubviews() {
       addGradient()
    }
    
    
    func hideImage(){
        if UserDefaults.standard.integer(forKey: "Completed") == 0 {
            mainView1.isHidden = true
            mainView2.isHidden = true
            mainView3.isHidden = true
            mainView4.isHidden = true
            imageView.isHidden = false
            textNotFoundLabel.isHidden = false
            numberText3.text = String(UserDefaults.standard.integer(forKey: "Completed"))
        } else {
            mainView1.isHidden = false
            mainView2.isHidden = false
            mainView3.isHidden = false
            mainView4.isHidden = false
            imageView.isHidden = true
            textNotFoundLabel.isHidden = true
            numberText3.text = String(UserDefaults.standard.integer(forKey: "Completed"))
        }
    }
    
    func addGradient() {
        mainView1.gradientBorder(colors: [.systemRed, .systemGreen, .systemBlue], isVertical: false)
        mainView2.gradientBorder(colors: [.systemRed, .systemGreen, .systemBlue], isVertical: false)
        mainView3.gradientBorder(colors: [.systemRed, .systemGreen, .systemBlue], isVertical: false)
        mainView4.gradientBorder(colors: [.systemRed, .systemGreen, .systemBlue], isVertical: false)
    }
    
    private func configure() {
        [titleLabel,
         imageView,
         textNotFoundLabel,
         mainView1,
         mainView2,
         mainView3,
         mainView4
        ].forEach {
            view.addSubview($0)
        }
        [numberText1,
         descrText1].forEach{
            mainView1.addSubview($0)
        }
        [numberText2,
         descrText2].forEach{
            mainView2.addSubview($0)
        }
        [numberText3,
         descrText3].forEach{
            mainView3.addSubview($0)
        }
        [numberText4,
         descrText4].forEach{
            mainView4.addSubview($0)
        }
    }
    
    private func configureConstraits() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.heightAnchor.constraint(equalToConstant: 41),
            
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textNotFoundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textNotFoundLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            
            mainView1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            mainView1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainView1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainView1.heightAnchor.constraint(equalToConstant: 90),
            
            numberText1.leadingAnchor.constraint(equalTo: mainView1.leadingAnchor, constant: 12),
            numberText1.trailingAnchor.constraint(equalTo: mainView1.trailingAnchor, constant: -12),
            numberText1.topAnchor.constraint(equalTo: mainView1.topAnchor, constant: 12),
            
            descrText1.topAnchor.constraint(equalTo: numberText1.bottomAnchor, constant: 7),
            descrText1.leadingAnchor.constraint(equalTo: mainView1.leadingAnchor, constant: 12),
            descrText1.trailingAnchor.constraint(equalTo: mainView1.trailingAnchor, constant: -12),
            descrText1.bottomAnchor.constraint(equalTo: mainView1.bottomAnchor, constant: -12),
            
            mainView2.topAnchor.constraint(equalTo: mainView1.bottomAnchor, constant: 12),
            mainView2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainView2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainView2.heightAnchor.constraint(equalToConstant: 90),
            
            numberText2.leadingAnchor.constraint(equalTo: mainView2.leadingAnchor, constant: 12),
            numberText2.trailingAnchor.constraint(equalTo: mainView2.trailingAnchor, constant: -12),
            numberText2.topAnchor.constraint(equalTo: mainView2.topAnchor, constant: 12),
            
            descrText2.topAnchor.constraint(equalTo: numberText2.bottomAnchor, constant: 7),
            descrText2.leadingAnchor.constraint(equalTo: mainView2.leadingAnchor, constant: 12),
            descrText2.trailingAnchor.constraint(equalTo: mainView2.trailingAnchor, constant: -12),
            descrText2.bottomAnchor.constraint(equalTo: mainView2.bottomAnchor, constant: -12),
            
            mainView3.topAnchor.constraint(equalTo: mainView2.bottomAnchor, constant: 12),
            mainView3.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainView3.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainView3.heightAnchor.constraint(equalToConstant: 90),
            
            numberText3.leadingAnchor.constraint(equalTo: mainView3.leadingAnchor, constant: 12),
            numberText3.trailingAnchor.constraint(equalTo: mainView3.trailingAnchor, constant: -12),
            numberText3.topAnchor.constraint(equalTo: mainView3.topAnchor, constant: 12),
            
            descrText3.topAnchor.constraint(equalTo: numberText3.bottomAnchor, constant: 7),
            descrText3.leadingAnchor.constraint(equalTo: mainView3.leadingAnchor, constant: 12),
            descrText3.trailingAnchor.constraint(equalTo: mainView3.trailingAnchor, constant: -12),
            descrText3.bottomAnchor.constraint(equalTo: mainView3.bottomAnchor, constant: -12),
            
            mainView4.topAnchor.constraint(equalTo: mainView3.bottomAnchor, constant: 12),
            mainView4.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainView4.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainView4.heightAnchor.constraint(equalToConstant: 90),
            
            numberText4.leadingAnchor.constraint(equalTo: mainView4.leadingAnchor, constant: 12),
            numberText4.trailingAnchor.constraint(equalTo: mainView4.trailingAnchor, constant: -12),
            numberText4.topAnchor.constraint(equalTo: mainView4.topAnchor, constant: 12),
            
            descrText4.topAnchor.constraint(equalTo: numberText4.bottomAnchor, constant: 7),
            descrText4.leadingAnchor.constraint(equalTo: mainView4.leadingAnchor, constant: 12),
            descrText4.trailingAnchor.constraint(equalTo: mainView4.trailingAnchor, constant: -12),
            descrText4.bottomAnchor.constraint(equalTo: mainView4.bottomAnchor, constant: -12)
        ])
        
    }
}
