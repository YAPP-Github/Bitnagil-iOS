//
//  UIImage+.swift
//  Presentation
//
//  Created by 최정인 on 7/17/25.
//

import UIKit

extension UIImage {
    // 받은 크기로 이미지 크기를 변경합니다. (원본 비율을 무시될 수 있습니다.)
    func resize(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    // 원본 비율 유지하면서 이미지 크기를 변경합니다. (aspect fit)
    func resizeAspectFit(to size: CGSize) -> UIImage? {
        let aspectRatio = self.size.width / self.size.height
        let targetRatio = size.width / size.height

        var newSize: CGSize
        if aspectRatio > targetRatio {
            newSize = CGSize(width: size.width, height: size.width / aspectRatio)
        } else {
            newSize = CGSize(width: size.height * aspectRatio, height: size.height)
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    // 원본 비율 유지하면서 이미지 크기를 변경합니다. (aspect fill)
    func resizeAspectFill(to size: CGSize) -> UIImage? {
        let aspectRatio = self.size.width / self.size.height
        let targetRatio = size.width / size.height

        var newSize: CGSize
        if aspectRatio > targetRatio {
            newSize = CGSize(width: size.height * aspectRatio, height: size.height)
        } else {
            newSize = CGSize(width: size.width, height: size.width / aspectRatio)
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    // 이미지를 회전합니다.
    func rotate(radians: Float) -> UIImage? {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size

        let renderer = UIGraphicsImageRenderer(size: rotatedSize)
        return renderer.image { context in
            context.cgContext.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
            context.cgContext.rotate(by: CGFloat(radians))
            draw(in: CGRect(origin: CGPoint(x: -size.width / 2, y: -size.height / 2), size: size))
        }
    }

    func rotate(degrees: Float) -> UIImage? {
        return rotate(radians: degrees * .pi / 180)
    }
}
