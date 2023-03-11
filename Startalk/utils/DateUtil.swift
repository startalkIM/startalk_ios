//
//  DateUtil.swift
//  Startalk
//
//  Created by lei on 2023/3/9.
//

import Foundation

class DateUtil{
    static private let calendar = Calendar.autoupdatingCurrent
    
    static private let todayFormatter =  makeTodayFormatter()
    static private let yesterdayFormatter = makeYesterdayFormatter()
    static private let thisYearFormatter = makeThisYearFormatter()
    static private let generalFormatter = makeGeneralFormatter()
    
    
    static private func makeTodayFormatter() -> DateFormatter{
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    static func makeYesterdayFormatter() -> DateFormatter{
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    static func makeThisYearFormatter() -> DateFormatter{
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMdd", options: 0, locale: .current)
        return formatter
    }
    
    static func makeGeneralFormatter() -> DateFormatter{
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    class func readable(_ date: Date) -> String{
        let formatter: DateFormatter
        if calendar.isDateInToday(date){
            formatter = todayFormatter
        }else if calendar.isDateInYesterday(date){
            formatter = yesterdayFormatter
        }else if calendar.isDate(date, equalTo: Date(), toGranularity: .year){
            formatter = thisYearFormatter
        }else{
            formatter = generalFormatter
        }
        return formatter.string(from: date)
    }
}
