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

        guard let homeViewModel = DIContainer.shared.resolve(type: HomeViewModel.self)
        else { fatalError("homeViewModel 의존성이 등록되지 않았습니다.") }

        guard let recommendedRoutineViewModel = DIContainer.shared.resolve(type: RecommendedRoutineViewModel.self)
        else { fatalError("recommendedRoutineViewModel 의존성이 등록되지 않았습니다.") }

        guard let mypageViewModel = DIContainer.shared.resolve(type: MypageViewModel.self)
        else { fatalError("mypageViewModel 의존성이 등록되지 않았습니다.") }

        let homeView = HomeView(viewModel: homeViewModel)
        let recommendView = RecommendedRoutineView(viewModel: recommendedRoutineViewModel)
        let mypageView = MypageView(viewModel: mypageViewModel)

        homeView.tabBarItem = UITabBarItem(
            title: "홈",
            image: BitnagilIcon.homeEmptyIcon,
            selectedImage: BitnagilIcon.homeFillIcon)

        recommendView.tabBarItem = UITabBarItem(
            title: "추천루틴",
            image: BitnagilIcon.recommendEmptyIcon,
            selectedImage: BitnagilIcon.recommendFillIcon)

        mypageView.tabBarItem = UITabBarItem(
            title: "마이페이지",
            image: BitnagilIcon.mypageEmptyIcon,
            selectedImage: BitnagilIcon.mypageFillIcon)

        viewControllers = [
            UINavigationController(rootViewController: homeView),
            UINavigationController(rootViewController: recommendView),
            UINavigationController(rootViewController: mypageView)
        ]
    }
}
