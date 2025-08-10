//
//  Date+Extension.swift
//  Movie Explorer
//
//  Created by Brijesh Ajudia on 09/08/25.
//

import Foundation

extension Date {
    func convertDateToString(serverFormate:String = "yyyy-MM-dd", convertForm: String = "yyyy") -> String {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = serverFormate
        let myString = formatter.string(from: self) // string purpose I add here
        // convert your string to date
        if let yourDate = formatter.date(from: myString){
            //then again set the date format whhich type of output you need
            formatter.dateFormat = convertForm
            // again convert your date to string
            return formatter.string(from: yourDate)
        }
        return ""
    }
    
}
