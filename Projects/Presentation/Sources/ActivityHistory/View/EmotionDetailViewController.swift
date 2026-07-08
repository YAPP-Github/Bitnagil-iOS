//
//  EmotionDetailViewController.swift
//  Presentation
//
//  Created by 최정인 on 7/7/26.
//

import SnapKit
import UIKit

final class EmotionDetailViewController: UIViewController {
    private let date: Date
    private let emotion: Marble
    private let label = UILabel()

    init(date: Date, emotion: Marble) {
        self.date = date
        self.emotion = emotion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(emotion.koreanDescription)")
        view.backgroundColor = .white
    }


}
