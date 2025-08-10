//
//  String+Extension.swift
//  Movie Explorer
//
//  Created by Brijesh Ajudia on 09/08/25.
//

import Foundation

extension String {
    func convertDateFormater(convertFrom: String = "yyyy-MM-dd" , convertTo: String = "yyyy") -> String {
        if self == "" {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = convertFrom
        let date = dateFormatter.date(from: self)
        dateFormatter.dateFormat = convertTo
        return dateFormatter.string(from: date!)
    }
}
