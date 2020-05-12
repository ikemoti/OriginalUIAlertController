//
//  ViewController.swift
//  OriginalUIAlertController
//
//  Created by Sousuke Ikemoto on 2020/05/11.
//  Copyright © 2020 Sousuke Ikemoto. All rights reserved.
//

import UIKit
import Foundation
public class DialogAction: NSObject {
    public enum ActionStyle {
        case `default`
        case cancel
        case destructive
        case custom(color: UIColor, font:UIFont)
    }
    private var handler: ((_ action: DialogAction) -> Void)?
    fileprivate var style: ActionStyle
    fileprivate var title: String
    //titleCoorの初期値設定
    fileprivate var titleColor: UIColor {
        switch self.style {
        case .default: return UIColor.black
        case .cancel:  return UIColor.black
        case .destructive:return  UIColor.red
        case let .custom(color, _):return color
        }
    }
    //titleFontの初期値設定
    fileprivate var titleFont: UIFont {
        switch self.style {
        case .default: return UIFont.boldSystemFont(ofSize: 14)
        case .cancel:  return UIFont.systemFont(ofSize: 14)
        case .destructive:return  UIFont.boldSystemFont(ofSize: 14)
        case let .custom(_ ,font):return font
        }
    }
    public init(title: String, style: ActionStyle, handler: ((_ action: DialogAction) -> Void)?) {
        self.handler = handler
        self.style = style
        self.title = title
    }
}

public class DialogController: UIViewController, UIViewControllerTransitioningDelegate {
    private let titleLabel: AppLabel = .init(appearance: .headline(lang: .ja, textColor: Color.Text.w100))
    private let messageLabel: AppLabel = .init(appearance: .body2(lang:.ja, textColor: Color.Text.w70))
    private let buttonStackview: UIStackView = .init()
    private let topBorder: UIView = .init()
    private let bannerView: UIImageView = .init()
    internal let dialogStackView: UIStackView = .init()
    private var actions = [DialogAction]()
    //土台のUIView
    lazy var baseView: UIView = {
        let view = UIView()
        view.backgroundColor =  UIColor.black.withAlphaComponent(0.15)
        view.isOpaque = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    //表示される土台のview
    lazy var alertView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        providesPresentationContextTransitionStyle = true
        definesPresentationContext = true
        modalPresentationStyle = UIModalPresentationStyle.custom
        transitioningDelegate = self
    }
    //簡易イニシャライザ
    public convenience init(title: String, message: String, banner: UIImage?) {
        self.init(nibName: nil, bundle: nil)
        titleLabel.text = title
        messageLabel.text = message
        bannerView.image = banner
        bannerView.isHidden = banner == nil
        alertView.cornerRadius = 10
        if banner != nil {
            alertView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
        }
    }
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        setAttrributes()
    }
    //ボタンタップ時の挙動
    @objc private func buttonEvent(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    //出現時
    public func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DialogAnimation(isPresent: true)
    }
    public func add(action: DialogAction) {
        let button = UIButton()
        button.setTitle(action.title, for: UIControl.State())
        button.setTitleColor(action.titleColor, for: .normal)
        button.titleLabel?.font = action.titleFont
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.addTarget(self, action: #selector(buttonEvent(sender:)), for: UIControl.Event.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        if actions.count > 0 {
            let border = UIView()
            border.translatesAutoresizingMaskIntoConstraints = false
            border.widthAnchor.constraint(equalToConstant: 1).isActive = true
            border.heightAnchor.constraint(equalToConstant: 44).isActive = true
            border.backgroundColor = UIColor.gray
            buttonStackview.addArrangedSubview(border)
        }
        buttonStackview.addArrangedSubview(button)
        if let alertView = buttonStackview.arrangedSubviews.first {
            button.widthAnchor.constraint(equalTo: alertView.widthAnchor ).isActive = true
        }
        actions.append(action)
    }
    //消失時
    public func animationController(
        forPresented _: UIViewController,
        presenting _: UIViewController,
        source _: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return DialogAnimation(isPresent: false)
    }
}
extension DialogController {
    private func setLayout() {
        view.addSubview(baseView)
        view.addSubview(dialogStackView)
        view.addSubview(alertView)
        view.addSubview(bannerView)
        alertView.addSubview(buttonStackview)
        alertView.addSubview(titleLabel)
        alertView.addSubview(messageLabel)
        alertView.addSubview(topBorder)
        dialogStackView.addArrangedSubview(bannerView)
        dialogStackView.addArrangedSubview(alertView)
        activateAutolayout()
        NSLayoutConstraint.activate([
            dialogStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            dialogStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            dialogStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            baseView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            baseView.topAnchor.constraint(equalTo: view.topAnchor),
            baseView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            baseView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        NSLayoutConstraint.activate([
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
        NSLayoutConstraint.activate([
            buttonStackview.leadingAnchor.constraint(equalTo: alertView.leadingAnchor),
            buttonStackview.bottomAnchor.constraint(equalTo: alertView.bottomAnchor),
            buttonStackview.widthAnchor.constraint(equalToConstant: 366 )
        ])
        NSLayoutConstraint.activate([
            topBorder.widthAnchor.constraint(equalTo: buttonStackview.widthAnchor),
            topBorder.heightAnchor.constraint(equalToConstant: 0.5),
            topBorder.bottomAnchor.constraint(equalTo: buttonStackview.topAnchor),
            topBorder.leadingAnchor.constraint(equalTo: buttonStackview.leadingAnchor)
        ])
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20),
            titleLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20 ),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20),
            messageLabel.bottomAnchor.constraint(equalTo: buttonStackview.topAnchor, constant: -40),
            messageLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        NSLayoutConstraint.activate([
            bannerView.widthAnchor.constraint(equalToConstant: 366),
            bannerView.heightAnchor.constraint(equalToConstant: 140)
        ])
    }
    private func setAttrributes() {
        buttonStackview.axis = .horizontal
        buttonStackview.alignment = .center
        buttonStackview.distribution = .fill
        buttonStackview.spacing = 0
        buttonStackview.backgroundColor = .red
        dialogStackView.axis = .vertical
        dialogStackView.alignment = .fill
        dialogStackView.distribution = .equalSpacing
        dialogStackView.spacing = 0
        topBorder.backgroundColor = UIColor.black
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        bannerView.clipsToBounds = true
        bannerView.cornerRadius = 10
        bannerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}
