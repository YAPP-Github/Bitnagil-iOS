//
//  TabBarView.swift
//  Presentation
//
//  Created by 최정인 on 7/16/25.
//

import Shared
import UIKit

final public class TabBarView: UITabBarController {
    /// Called after the controller's view is loaded into memory.
    /// 
    /// Performs initial setup for the tab bar controller by calling `super.viewDidLoad()` and configuring tab bar appearance and child view controllers (via `configureAttribute()`).
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
    }

    /// Configures the tab bar appearance, resolves required view models, creates the three tab views, and embeds them in navigation controllers as the tab bar's viewControllers.
    /// 
    /// - Appearance: sets a white background, shadow color, title text attributes and icon colors for normal and selected states, and applies the appearance to both `standardAppearance` and `scrollEdgeAppearance`. Also sets `tintColor` and `unselectedItemTintColor`.
    /// - Dependency resolution: resolves `HomeViewModel`, `RecommendedRoutineViewModel`, and `MypageViewModel` from `DIContainer.shared`; if any resolution fails the app terminates with `fatalError`.
    /// - View setup: instantiates `HomeView`, `RecommendedRoutineView`, and `MypageView` with their view models, configures each view's `tabBarItem` (title and icon), and assigns three `UINavigationController` instances (one per view) to `viewControllers`.
    /// 
    /// Side effects: mutates the controller's `tabBar` appearance and `viewControllers`, and can terminate the process via `fatalError` if dependencies are missing.
    private func configureAttribute() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = BitnagilColor.gray98

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: BitnagilColor.gray90 ?? .systemGray,
            .font: BitnagilFont(style: .caption2, weight: .medium).font
        ]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.normal.iconColor = BitnagilColor.gray90

        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: BitnagilColor.gray10 ?? .systemGray,
            .font: BitnagilFont(style: .caption2, weight: .semiBold).font
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.stackedLayoutAppearance.selected.iconColor = BitnagilColor.gray10

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = BitnagilColor.gray10
        tabBar.unselectedItemTintColor = BitnagilColor.gray90

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
            image: BitnagilIcon.homeIcon,
            selectedImage: BitnagilIcon.homeIcon)

        recommendView.tabBarItem = UITabBarItem(
            title: "추천루틴",
            image: BitnagilIcon.recommendIcon,
            selectedImage: BitnagilIcon.recommendIcon)

        mypageView.tabBarItem = UITabBarItem(
            title: "마이페이지",
            image: BitnagilIcon.mypageIcon,
            selectedImage: BitnagilIcon.mypageIcon)

        viewControllers = [
            UINavigationController(rootViewController: homeView),
            UINavigationController(rootViewController: recommendView),
            UINavigationController(rootViewController: mypageView)
        ]
    }
}
