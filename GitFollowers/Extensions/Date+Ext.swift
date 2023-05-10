//
//  Date+Ext.swift
//  GitFollowers
//
//  Created by Daniel Priestley on 01/04/2023.
//

import Foundation

extension Date {
    func convertToMonthYearFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        return dateFormatter.string(from: self)
    }
}
