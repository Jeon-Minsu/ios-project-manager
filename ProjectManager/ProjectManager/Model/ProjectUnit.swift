//
//  ProjectUnit.swift
//  ProjectManager
//
//  Created by 수꿍, 휴 on 2022/09/07.
//

import Foundation

struct ProjectUnit: Hashable, Codable {
    let id: UUID
    var title: String
    var body: String
    var section: String
    var deadLine: Date
    
    var isDeadlinePassed: Bool {
        return self.deadLine < Date()
    }
    
    init(
        id: UUID,
        title: String,
        body: String,
        section: String,
        deadLine: Date
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.section = section
        self.deadLine = deadLine
    }
    
    func convertToDictionary() -> [String: Any]? {
        return JSONManager.shared.encodeToDictionary(data: self)
    }
    
    // MARK: Test Data

    static let sample = ProjectUnit(
        id: UUID(),
        title: "쥬스 메이커",
        body: "쥬스 메이커 프로젝트입니다",
        section: "TODO",
        deadLine: Date()
    )

    static let sample2 = ProjectUnit(
        id: UUID(),
        title: "은행 창구 매니저",
        body: "은행 창구 매니저 프로젝트입니다",
        section: "TODO",
        deadLine: Date()
    )
}
