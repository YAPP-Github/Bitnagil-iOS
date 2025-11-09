//
//  SelectPhotoType.swift
//  Presentation
//
//  Created by 이동현 on 11/9/25.
//

enum SelectPhotoType: String, CaseIterable {
    case camera
    case library
}

extension SelectPhotoType: SelectableItem {
    var id: Int {
        switch self {
        case .camera:
            return 0
        case .library:
            return 1
        }
    }

    var displayName: String? {
        return nil
    }

    var description: String {
        switch self {
        case .camera:
            return "직접 촬영하기"
        case .library:
            return "사진 라이브러리에서 선택"
        }
    }
}
