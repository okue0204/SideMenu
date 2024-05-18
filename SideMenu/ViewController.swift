//
//  ViewController.swift
//  SideMenu
//
//  Created by 奥江英隆 on 2024/05/17.
//

import UIKit

class ViewController: UIViewController {
    
    private enum SideMenuAppearance {
        case open
        case close
    }
    
    private enum PanGestureType {
        case normal
        case edge
    }

    @IBOutlet weak var sideMenuView: SideMenuView!
    @IBOutlet weak var backgroundButton: UIButton!
    
    private static let maxSwipeVelocity: CGFloat = 500
    private static let maxAlpha: CGFloat = 0.3
    private static let animationDuration: CGFloat = 0.25
    
    private var sideMenuAppearance: SideMenuAppearance = .open {
        didSet {
            UIView.animate(withDuration: Self.animationDuration,
                           delay: 0,
                           options: .curveEaseIn) { [weak self] in
                guard let self else {
                    return
                }
                switch sideMenuAppearance {
                case .open:
                    backgroundButton.alpha = Self.maxAlpha
                    sideMenuView.transform = .identity
                case .close:
                    backgroundButton.alpha = 0
                    sideMenuView.transform = CGAffineTransform(translationX: -sideMenuView.bounds.width, y: 0)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    private func setupLayout() {
        backgroundButton.alpha = 0
        sideMenuView.transform = CGAffineTransform(translationX: -sideMenuView.bounds.width, y: 0)
        sideMenuView.layer.cornerRadius = 30
        sideMenuView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        sideMenuView.clipsToBounds = true
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pangesture(_:)))
        let screenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgePanGesture(_:)))
        screenEdgePanGestureRecognizer.edges = .left
        sideMenuView.addGestureRecognizer(panGestureRecognizer)
        view.addGestureRecognizer(screenEdgePanGestureRecognizer)
    }
    
    private func calculateMovement(type: PanGestureType, translation: CGFloat) -> CGFloat {
        // 移動量の割合を求める
        switch type {
        case .normal:
            return min(Self.maxAlpha, ((sideMenuView.bounds.width - -translation) / sideMenuView.bounds.width) * Self.maxAlpha)
        case .edge:
            return min(Self.maxAlpha, (-(-translation - sideMenuView.bounds.width) / sideMenuView.bounds.width) * Self.maxAlpha)
        }
    }
    
    @objc
    private func pangesture(_ sender: UIPanGestureRecognizer) {
        let translationX = sender.translation(in: sideMenuView).x
        switch sender.state {
        case .changed:
            backgroundButton.alpha = calculateMovement(type: .normal, translation: translationX)
            sideMenuView.transform = CGAffineTransform(translationX: min(0, translationX), y: 0)
        case .ended:
            if sender.velocity(in: sideMenuView).x < -Self.maxSwipeVelocity {
                sideMenuAppearance = .close
                return
            } else {
                sideMenuAppearance = {
                    return switch translationX {
                    case ..<(-sideMenuView.bounds.width * 0.5):
                            .close
                    case (-sideMenuView.bounds.width * 0.5)...:
                            .open
                    default:
                            .close
                    }
                }()
            }
        default:
            break
        }
    }
    
    @objc
    private func screenEdgePanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = -sideMenuView.bounds.width - -sender.translation(in: sideMenuView).x
        switch sender.state {
        case .changed:
            sideMenuView.transform = CGAffineTransform(translationX: min(0, translation), y: 0)
            backgroundButton.alpha = calculateMovement(type: .edge, translation: translation)
        case .ended:
            if sender.velocity(in: sideMenuView).x > Self.maxSwipeVelocity {
                sideMenuAppearance = .open
            } else {
                sideMenuAppearance = {
                    return switch translation {
                    case ..<(-sideMenuView.bounds.width * 0.5):
                            .close
                    case (-sideMenuView.bounds.width * 0.5)...:
                            .open
                    default:
                            .close
                    }
                }()
            }
        default:
            break
        }
    }
    
    @IBAction func didTapBackgroundButton(_ sender: Any) {
        sideMenuAppearance = .close
    }
    
    @IBAction func didTapSideMenuButton(_ sender: Any) {
        sideMenuAppearance = .open
    }
}

