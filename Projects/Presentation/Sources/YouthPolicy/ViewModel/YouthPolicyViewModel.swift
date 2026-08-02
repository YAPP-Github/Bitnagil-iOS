//
//  YouthPolicyViewModel.swift
//  Presentation
//
//  Created by 이동현 on 7/19/26.
//

import Combine
import Domain
import Foundation

final class YouthPolicyViewModel: ViewModel {
    enum Input {
        case fetchPolicies
        case selectTab(tab: YouthPolicyTab)
        case loadNextPage
        case toggleBookmark(policyNumber: String)
    }

    struct Output {
        let tabsPublisher: AnyPublisher<[YouthPolicyTabItem], Never>
        let policiesPublisher: AnyPublisher<[YouthPolicyItem], Never>
        let isEmptyPublisher: AnyPublisher<Bool, Never>
        let networkErrorPublisher: AnyPublisher<(() -> Void)?, Never>
    }

    /// 탭 하나의 목록과 커서 상태입니다.
    private struct TabState {
        var items: [YouthPolicyItem] = []
        var totalCount: Int = 0
        var nextCursor: String?
        var hasNext: Bool = true
        var isLoading: Bool = false
        /// 다른 탭에서의 찜 변경으로 목록이 낡았는지 여부입니다. true면 탭 진입 시 다시 받아옵니다.
        var isStale: Bool = false
        /// 첫 페이지를 한 번이라도 받아왔는지 여부입니다.
        var hasLoadedOnce: Bool = false
    }

    /// 서버가 허용하는 최대 페이지 크기입니다. 한 번에 최대한 많이 받아 요청 횟수를 줄입니다.
    private static let pageSize = 50

    private(set) var output: Output
    private(set) var selectedTab: YouthPolicyTab = .entire

    private let youthPolicyUseCase: YouthPolicyUseCaseProtocol
    private let networkRetryHandler: NetworkRetryHandler

    private let tabsSubject = CurrentValueSubject<[YouthPolicyTabItem], Never>([])
    private let policiesSubject = CurrentValueSubject<[YouthPolicyItem], Never>([])
    private let isEmptySubject = CurrentValueSubject<Bool, Never>(false)

    private var entireState = TabState()
    private var bookmarkedState = TabState()

    init(youthPolicyUseCase: YouthPolicyUseCaseProtocol) {
        self.youthPolicyUseCase = youthPolicyUseCase
        self.networkRetryHandler = NetworkRetryHandler()

        self.output = Output(
            tabsPublisher: tabsSubject.eraseToAnyPublisher(),
            policiesPublisher: policiesSubject.eraseToAnyPublisher(),
            isEmptyPublisher: isEmptySubject.eraseToAnyPublisher(),
            networkErrorPublisher: networkRetryHandler.networkErrorActionSubject.eraseToAnyPublisher())

        sendTabs()
    }

    func action(input: Input) {
        switch input {
        case .fetchPolicies:
            fetchFirstPage(tab: selectedTab)
        case .selectTab(let tab):
            selectTab(tab: tab)
        case .loadNextPage:
            fetchNextPage(tab: selectedTab)
        case .toggleBookmark(let policyNumber):
            toggleBookmark(policyNumber: policyNumber)
        }
    }

    private func selectTab(tab: YouthPolicyTab) {
        guard tab != selectedTab else { return }

        selectedTab = tab
        sendTabs()

        let state = state(of: tab)
        sendPolicies(state: state)

        // 아직 안 받았거나, 다른 탭에서의 찜 변경으로 낡았으면 다시 받아옵니다.
        if !state.hasLoadedOnce || state.isStale {
            fetchFirstPage(tab: tab)
        }
    }

    private func fetchFirstPage(tab: YouthPolicyTab) {
        var state = state(of: tab)
        guard !state.isLoading else { return }

        state.isLoading = true
        updateState(state, of: tab)

        Task { [weak self] in
            guard let self else { return }

            do {
                let page = try await self.fetchPage(tab: tab, cursor: nil)

                var state = self.state(of: tab)
                state.items = page?.policies.compactMap { YouthPolicyItem(entity: $0) } ?? []
                state.totalCount = page?.totalCount ?? 0
                state.nextCursor = page?.nextCursor
                state.hasNext = page?.hasNext ?? false
                state.isLoading = false
                state.isStale = false
                state.hasLoadedOnce = true
                self.updateState(state, of: tab)

                self.networkRetryHandler.clearRetryState()
            } catch {
                var state = self.state(of: tab)
                state.isLoading = false
                state.hasLoadedOnce = true
                self.updateState(state, of: tab)

                self.networkRetryHandler.handleNetworkError(error) { [weak self] in
                    self?.fetchFirstPage(tab: tab)
                }
            }
        }
    }

    private func fetchNextPage(tab: YouthPolicyTab) {
        var state = state(of: tab)

        guard
            !state.isLoading,
            state.hasNext,
            let cursor = state.nextCursor
        else { return }

        state.isLoading = true
        updateState(state, of: tab)

        Task { [weak self] in
            guard let self else { return }

            do {
                let page = try await self.fetchPage(tab: tab, cursor: cursor)

                var state = self.state(of: tab)
                let newItems = page?.policies.compactMap { YouthPolicyItem(entity: $0) } ?? []

                // 같은 공고가 두 번 들어오면 diffable data source가 크래시하므로 중복을 걸러냅니다.
                let existingNumbers = Set(state.items.map { $0.policyNumber })
                state.items += newItems.filter { !existingNumbers.contains($0.policyNumber) }

                state.totalCount = page?.totalCount ?? state.totalCount
                state.nextCursor = page?.nextCursor
                state.hasNext = page?.hasNext ?? false
                state.isLoading = false
                self.updateState(state, of: tab)

                self.networkRetryHandler.clearRetryState()
            } catch {
                var state = self.state(of: tab)
                state.isLoading = false
                self.updateState(state, of: tab)

                self.networkRetryHandler.handleNetworkError(error) { [weak self] in
                    self?.fetchNextPage(tab: tab)
                }
            }
        }
    }

    private func fetchPage(tab: YouthPolicyTab, cursor: String?) async throws -> YouthPolicyPageEntity? {
        switch tab {
        case .entire:
            return try await youthPolicyUseCase.fetchPolicies(cursor: cursor, size: Self.pageSize)
        case .bookmarked:
            return try await youthPolicyUseCase.fetchBookmarkedPolicies(cursor: cursor, size: Self.pageSize)
        }
    }

    private func toggleBookmark(policyNumber: String) {
        guard let currentItem = state(of: selectedTab).items.first(where: { $0.policyNumber == policyNumber })
        else { return }

        let targetIsBookmarked = !currentItem.isBookmarked

        let previousEntireState = entireState
        let previousBookmarkedState = bookmarkedState

        applyBookmarkChange(policyNumber: policyNumber, isBookmarked: targetIsBookmarked)

        Task { [weak self] in
            guard let self else { return }

            do {
                try await self.youthPolicyUseCase.updateBookmark(
                    policyNumber: policyNumber,
                    isBookmarked: targetIsBookmarked)
            } catch {
                // 실패하면 낙관적으로 반영했던 변경을 되돌립니다.
                self.entireState = previousEntireState
                self.bookmarkedState = previousBookmarkedState
                self.sendTabs()
                self.sendPolicies(state: self.state(of: self.selectedTab))
            }
        }
    }

    private func applyBookmarkChange(policyNumber: String, isBookmarked: Bool) {
        if let index = entireState.items.firstIndex(where: { $0.policyNumber == policyNumber }) {
            entireState.items[index].isBookmarked = isBookmarked
        }

        if isBookmarked {
            // 찜 목록의 정렬 순서는 서버가 정하므로 직접 끼워넣지 않고 다음 진입 시 다시 받아옵니다.
            bookmarkedState.isStale = true
        } else {
            bookmarkedState.items.removeAll { $0.policyNumber == policyNumber }
            bookmarkedState.totalCount = max(0, bookmarkedState.totalCount - 1)
        }

        sendTabs()
        sendPolicies(state: state(of: selectedTab))
    }

    private func state(of tab: YouthPolicyTab) -> TabState {
        switch tab {
        case .entire:
            return entireState
        case .bookmarked:
            return bookmarkedState
        }
    }

    private func updateState(_ state: TabState, of tab: YouthPolicyTab) {
        switch tab {
        case .entire:
            entireState = state
        case .bookmarked:
            bookmarkedState = state
        }

        sendTabs()

        guard tab == selectedTab else { return }
        sendPolicies(state: state)
    }

    private func sendTabs() {
        let tabItems = YouthPolicyTab.allCases.map { tab in
            YouthPolicyTabItem(
                tab: tab,
                count: state(of: tab).totalCount,
                isSelected: tab == selectedTab)
        }

        tabsSubject.send(tabItems)
    }

    private func sendPolicies(state: TabState) {
        policiesSubject.send(state.items)

        // 첫 응답이 오기 전에는 빈 화면 문구가 스쳐 보이지 않도록 감춥니다.
        isEmptySubject.send(state.items.isEmpty && state.hasLoadedOnce)
    }
}
