//
//  BaseViewController.swift
//  Presentation
//
//  Created by 최정인 on 6/26/25.
//

import Combine
import SnapKit
import UIKit

public class BaseViewController<T: ViewModel>: UIViewController {
    let viewModel: T
    private var baseCancellables = Set<AnyCancellable>()
    private lazy var networkErrorView = NetworkErrorView()
    var isShowingTabBar: Bool { true }

    init(viewModel: T) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        guard isShowingTabBar else { return }

        DispatchQueue.main.async { [weak tabBarController = self.tabBarController] in
            tabBarController?.tabBar.isHidden = false
        }
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
    func configureAttribute() {
        networkErrorView.isHidden = true
    }

    /// 뷰의 계층 구조를 구성하고 Auto Layout 제약을 설정합니다.
    func configureLayout() {
        view.addSubview(networkErrorView)

        networkErrorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    /// ViewModel의 데이터를 구독하고 UI에 바인딩합니다.
    func bind() { }

    /// 네트워크 재시도 기능이 필요할 경우 BaseViewController의 subclass 내의 bind() 함수 내에서 호출합니다.
    /// 네트워크 재시도 화면의 '다시 시도하기' 버튼의 재시도 action을 설정합니다.
    /// - Parameter publisher: ViewModel의 Output에서 제공하는 네트워크 에러 Publisher
    func bindNetworkError(from publisher: AnyPublisher<(() -> Void)?, Never>) {
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] retryAction in
                if let action = retryAction {
                    self?.handleNetworkErrorView(show: true)
                    self?.networkErrorView.onRetry = action
                } else {
                    self?.handleNetworkErrorView(show: false)
                }
            }
            .store(in: &baseCancellables)
    }

    /// 네트워크 에러 뷰 를 보이거나 숨깁니다.
    private func handleNetworkErrorView(show: Bool) {
        if show {
            view.bringSubviewToFront(networkErrorView)
            networkErrorView.isHidden = false
            tabBarController?.tabBar.isHidden = true
        } else {
            networkErrorView.isHidden = true
            if isShowingTabBar {
                tabBarController?.tabBar.isHidden = false
            }
        }
    }
}
