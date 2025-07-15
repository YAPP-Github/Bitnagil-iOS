//
//  BaseViewController.swift
//  Presentation
//
//  Created by 최정인 on 6/26/25.
//

import Foundation
import UIKit

public class BaseViewController<T: ViewModel>: UIViewController {
    public let viewModel: T

    init(viewModel: T) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        configureAttribute()
        configureLayout()

        bind()
    }

    /// 뷰의 속성(스타일, 컬러, 폰트 등)을 설정합니다.
    func configureAttribute() { }

    /// 뷰의 계층 구조를 구성하고 Auto Layout 제약을 설정합니다.
    func configureLayout() { }

    /// ViewModel의 데이터를 구독하고 UI에 바인딩합니다.
    func bind() { }
}
