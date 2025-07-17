//
//  CustomBottomSheet.swift
//  Presentation
//
//  Created by 최정인 on 7/14/25.
//

import SnapKit
import UIKit

final class CustomBottomSheet: UIViewController {

    private enum Layout {
        static let bottomSheetCornerRadius: CGFloat = 20
        static let dragHandleTopSpacing: CGFloat = 16
        static let dragHandleCornerRadius: CGFloat = 2
        static let dragHandleHeight: CGFloat = 4
        static let dragHandleWidth: CGFloat = 32
        static let contentViewTopSpacing: CGFloat = 16
    }

    private let maxHeight: CGFloat
    private let contentViewController: UIViewController

    private let dimmedView = UIView()
    private let bottomSheetView = UIView()
    private let dragHandle = UIView()
    private let contentView = UIView()
    private var bottomSheetBottomConstraint: Constraint?

    init(contentViewController: UIViewController, maxHeight: CGFloat = 300) {
        self.contentViewController = contentViewController
        self.maxHeight = maxHeight
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
        setupContent()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBottomSheet()
    }

    private func configureAttribute() {
        dimmedView.do {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            $0.alpha = 0
        }

        bottomSheetView.do {
            $0.backgroundColor = UIColor.systemBackground
            $0.layer.cornerRadius = Layout.bottomSheetCornerRadius
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }

        dragHandle.do {
            $0.backgroundColor = UIColor.systemGray4
            $0.layer.cornerRadius = Layout.dragHandleCornerRadius
        }
        
        contentView.do {
            $0.backgroundColor = .clear
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissBottomSheet))
        dimmedView.addGestureRecognizer(tapGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        bottomSheetView.addGestureRecognizer(panGesture)
    }

    private func configureLayout() {
        view.addSubview(dimmedView)
        view.addSubview(bottomSheetView)
        bottomSheetView.addSubview(dragHandle)
        bottomSheetView.addSubview(contentView)

        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bottomSheetView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(maxHeight)
            self.bottomSheetBottomConstraint = make.bottom.equalToSuperview().offset(maxHeight).constraint
        }

        dragHandle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.dragHandleTopSpacing)
            make.centerX.equalToSuperview()
            make.width.equalTo(Layout.dragHandleWidth)
            make.height.equalTo(Layout.dragHandleHeight)
        }

        contentView.snp.makeConstraints { make in
            make.top.equalTo(dragHandle.snp.bottom).offset(Layout.contentViewTopSpacing)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func setupContent() {
        addChild(contentViewController)
        contentView.addSubview(contentViewController.view)
        contentViewController.didMove(toParent: self)

        contentViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func showBottomSheet() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.dimmedView.alpha = 1
            self.bottomSheetBottomConstraint?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }

    @objc private func dismissBottomSheet() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.dimmedView.alpha = 0
            self.bottomSheetBottomConstraint?.update(offset: self.maxHeight)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)

        switch gesture.state {
        case .changed:
            let offset = max(0, translation.y)
            bottomSheetBottomConstraint?.update(offset: offset)

            let progress = min(1, offset / maxHeight)
            dimmedView.alpha = 1 - progress

        case .ended:
            let shouldDismiss = translation.y > maxHeight * 0.3 || velocity.y > 1000
            if shouldDismiss {
                dismissBottomSheet()
            } else {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                    self.bottomSheetBottomConstraint?.update(offset: 0)
                    self.dimmedView.alpha = 1
                    self.view.layoutIfNeeded()
                }
            }

        default:
            break
        }
    }
}
