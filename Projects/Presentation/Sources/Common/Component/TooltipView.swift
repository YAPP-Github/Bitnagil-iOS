//
//  ToolTipView.swift
//  Presentation
//
//  Created by 이동현 on 7/20/25.
//

import SnapKit
import UIKit

final class TooltipView: UIView {
    enum TooltipTailPosition {
        case center
        case offsetFromLeading(CGFloat)
    }

    private enum Layout {
        static let backgroundViewBottomInset: CGFloat = 8
        static let messageLabelInset: CGFloat = 10
        static let tailWidth: CGFloat = 14
        static let tailHeight: CGFloat = 8
        static let cornerRadius: CGFloat = 8
    }

    private let backgroundView = UIView()
    private let messageLabel = UILabel()
    private let tailLayer = CAShapeLayer()
    private let tailPosition: TooltipTailPosition

    init(tailPosition: TooltipTailPosition) {
       self.tailPosition = tailPosition
       super.init(frame: .zero)
       configureAttribute()
       configureLayout()
   }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        generateTail()
    }

    private func configureAttribute() {
        backgroundView.backgroundColor = BitnagilColor.navy400
        backgroundView.layer.cornerRadius = Layout.cornerRadius
        messageLabel.textColor = .white
        messageLabel.font = BitnagilFont.init(style: .caption1, weight: .medium).font
    }

    private func configureLayout() {
        addSubview(backgroundView)
        backgroundView.addSubview(messageLabel)

        backgroundView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().inset(Layout.backgroundViewBottomInset)
        }

        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Layout.messageLabelInset)
        }
    }

    func configure(message: String) {
        messageLabel.text = message
    }

    private func generateTail() {
        let startX: CGFloat
        let width = Layout.tailWidth
        let height = Layout.tailHeight
        let y = bounds.height - height

        switch tailPosition {
        case .center:
            startX = (backgroundView.bounds.width - width) / 2
        case .offsetFromLeading(let offset):
            startX = offset
        }

        let path = UIBezierPath()
        path.move(to: CGPoint(x: startX, y: y))
        path.addQuadCurve(
            to: CGPoint(x: startX + width, y: y),
            controlPoint: CGPoint(x: startX + width / 2, y: y + height * 1.5))
        path.addLine(to: CGPoint(x: startX + width, y: y))
        path.close()

        tailLayer.path = path.cgPath
        tailLayer.fillColor = backgroundView.backgroundColor?.cgColor

        if tailLayer.superlayer == nil {
            layer.addSublayer(tailLayer)
        }
    }

    func showTooltip() {
        self.alpha = 0
        self.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        self.isHidden = false

        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: [.curveEaseOut],
            animations: {
                self.alpha = 1
                self.transform = .identity
            },
            completion: nil)
    }

    func hideTooltip(completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: [.curveEaseIn],
            animations: {
                self.alpha = 0
                self.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            }) { _ in
                self.isHidden = true
                self.transform = .identity
                completion?()
        }
    }
}
