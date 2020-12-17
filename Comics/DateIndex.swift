//
//  DateIndex.swift
//  iOS Comics
//
//  Created by Philipp on 08.09.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation

let calendar = Calendar.current

struct DateIndex {
    let date: Date
}

extension DateIndex {
    init(_ date: Date) {
        self.date = calendar.startOfDay(for: date)
    }

    init() {
        self.init(Date())
    }
}

extension DateIndex: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(date)"
    }
}

extension DateIndex: Comparable {
    static func < (lhs: DateIndex, rhs: DateIndex) -> Bool {
        return lhs.date.compare(rhs.date) == .orderedAscending
    }
}
