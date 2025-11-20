//
//  ReportHistoryItem.swift
//  Presentation
//
//  Created by 이동현 on 11/19/25.
//

import Domain

struct ReportHistoryItem: Hashable {
    let id: Int
    let title: String
    let thumbnailUrl: String
    let date: String
    let type: ReportType
    let progress: ReportProgress
    let location: String
}

extension ReportHistoryItem {
    static var dummyData: [ReportHistoryItem] {
        let types = ReportType.allCases
        let progresses = ReportProgress.allCases.filter { $0 != .entire }

        func makeItem(
            id: Int,
            title: String,
            date: String,
            location: String,
            typeIndex: Int,
            progressIndex: Int
        ) -> ReportHistoryItem {
            let type = types[typeIndex % types.count]
            let progress = progresses[progressIndex % progresses.count]

            return ReportHistoryItem(
                id: id,
                title: title,
                thumbnailUrl: "https://picsum.photos/200",
                date: date,
                type: type,
                progress: progress,
                location: location
            )
        }

        return [
            makeItem(
                id: 1,
                title: "횡단보도 앞 가로등 불이 꺼져 있어요",
                date: "2025-11-19월",
                location: "서울시 강남구 삼성동",
                typeIndex: 0,
                progressIndex: 0
            ),
            makeItem(
                id: 2,
                title: "지하철 역사 계단 난간이 파손되었어요",
                date: "2025-11-19월",
                location: "서울시 송파구 잠실동",
                typeIndex: 1,
                progressIndex: 1
            ),

            // 다른 날짜
            makeItem(
                id: 3,
                title: "공원 놀이터 바닥이 파여 있어 위험해요",
                date: "2025-11-18월",
                location: "서울시 마포구 상암동",
                typeIndex: 2,
                progressIndex: 2
            ),
            makeItem(
                id: 4,
                title: "버스 정류장 안내판 조명이 나갔습니다",
                date: "2025-11-18월",
                location: "서울시 서초구 서초동",
                typeIndex: 3,
                progressIndex: 0
            ),

            makeItem(
                id: 5,
                title: "자전거 도로에 불법 주차된 차량이 있어요",
                date: "2025-11-17월",
                location: "서울시 노원구 공릉동",
                typeIndex: 1,
                progressIndex: 1
            ),
            makeItem(
                id: 6,
                title: "보도블럭이 들떠서 걸려 넘어질 위험이 있어요",
                date: "2025-11-16월",
                location: "서울시 종로구 종로1가",
                typeIndex: 0,
                progressIndex: 2
            ),

            makeItem(
                id: 7,
                title: "교차로 신호등이 고장난 것 같습니다",
                date: "2025-11-16월",
                location: "서울시 동작구 사당동",
                typeIndex: 2,
                progressIndex: 0
            ),
            makeItem(
                id: 8,
                title: "지하차도에 물이 고여 있어요",
                date: "2025-11-15월",
                location: "서울시 영등포구 영등포동",
                typeIndex: 3,
                progressIndex: 1
            )
        ]
    }
}
