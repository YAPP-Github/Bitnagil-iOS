//
//  TabBarView.swift
//  Presentation
//
//  Created by 최정인 on 7/16/25.
//

import Shared
import UIKit

final public class TabBarView: UITabBarController {

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
    }

    private func configureAttribute() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .systemBackground

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: BitnagilColor.navy100 ?? .systemGray,
            .font: BitnagilFont(style: .caption2, weight: .medium).font
        ]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.normal.iconColor = BitnagilColor.navy100

        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: BitnagilColor.navy600 ?? .systemGray,
            .font: BitnagilFont(style: .caption2, weight: .medium).font
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.stackedLayoutAppearance.selected.iconColor = BitnagilColor.navy600

        tabBar.standardAppearance = appearance
        tabBar.tintColor = BitnagilColor.navy600
        tabBar.unselectedItemTintColor = BitnagilColor.navy100


        guard let viewModel = DIContainer.shared.resolve(type: RecommendedRoutineViewModel.self) else {
            fatalError("RecommendedViewModel 의존성이 등록되지 않았습니다.")
        }

        guard let mypageViewModel = DIContainer.shared.resolve(type: MypageViewModel.self) else {
            fatalError("mypageViewModel 의존성이 등록되지 않았습니다.")
        }
        
        let homeView = HomeView()
        let recommendView = RecommendedRoutineView(viewModel: viewModel)
        let reportView = ReportView()
        let mypageView = MypageView(viewModel: mypageViewModel)

        homeView.tabBarItem = UITabBarItem(
            title: "홈",
            image: BitnagilIcon.homeEmptyIcon,
            selectedImage: BitnagilIcon.homeFillIcon)

        recommendView.tabBarItem = UITabBarItem(
            title: "추천루틴",
            image: BitnagilIcon.recommendEmptyIcon,
            selectedImage: BitnagilIcon.recommendFillIcon)

        reportView.tabBarItem = UITabBarItem(
            title: "리포트",
            image: BitnagilIcon.reportEmptyIcon,
            selectedImage: BitnagilIcon.reportFillIcon)

        mypageView.tabBarItem = UITabBarItem(
            title: "마이페이지",
            image: BitnagilIcon.mypageEmptyIcon,
            selectedImage: BitnagilIcon.mypageFillIcon)

        viewControllers = [
            UINavigationController(rootViewController: homeView),
            UINavigationController(rootViewController: recommendView),
            UINavigationController(rootViewController: reportView),
            UINavigationController(rootViewController: mypageView)
        ]
    }
}

// TODO: - 홈, 추천, 마이페이지 생성 후 지워주세요
final class HomeView: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}

final class ReportView: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}
