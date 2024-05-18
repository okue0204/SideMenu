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
    
    private var sideMenuAppearance: SideMenuAppearance = .open {
        didSet {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: .curveEaseIn) { [weak self] in
                guard let self else {
                    return
                }
                switch sideMenuAppearance {
                case .open:
                    backgroundButton.alpha = 0.3
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
        // 0.3はbackgroundのalphaを最大0.3にしたいから
        switch type {
        case .normal:
            return min(0.3, ((sideMenuView.bounds.width - -translation) / sideMenuView.bounds.width) * 0.3)
        case .edge:
            return min(0.3, (-(-translation - sideMenuView.bounds.width) / sideMenuView.bounds.width) * 0.3)
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
        default:
            break
        }
    }
    
    @objc
    private func screenEdgePanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = -sideMenuView.bounds.width - -sender.translation(in: sideMenuView).x
        switch sender.state {
        case .changed:
            backgroundButton.alpha = calculateMovement(type: .edge, translation: translation)
            sideMenuView.transform = CGAffineTransform(translationX: min(0, translation), y: 0)
        case .ended:
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

