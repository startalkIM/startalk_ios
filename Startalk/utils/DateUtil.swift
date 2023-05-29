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
    
    static private let yesterdayWithTimeFormatter = makeYesterdayFormatter(withTime: true)
    static private let thisYearWithTimeFormatter = makeThisYearFormatter(withTime: true)
    static private let generalWithTimeFormatter = makeGeneralFormatter(withTime: true)
    
    
    static private func makeTodayFormatter() -> DateFormatter{
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    static func makeYesterdayFormatter(withTime: Bool = false) -> DateFormatter{
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .medium
        if withTime{
            formatter.timeStyle = .short
        }else{
            formatter.timeStyle = .none
        }
        return formatter
    }
    
    static func makeThisYearFormatter(withTime: Bool = false) -> DateFormatter{
        let formatter = DateFormatter()
        if withTime{
            formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMdd HH:mm", options: 0, locale: .current)
        }else{
            formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMdd", options: 0, locale: .current)
        }
        return formatter
    }
    
    static func makeGeneralFormatter(withTime: Bool = false) -> DateFormatter{
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        if withTime{
            formatter.timeStyle = .short
        }else{
            formatter.timeStyle = .none
        }
        return formatter
    }
    
    class func readable(_ date: Date, withTime: Bool = false) -> String{
        let formatter: DateFormatter
        if calendar.isDateInToday(date){
            formatter = todayFormatter
        }else if calendar.isDateInYesterday(date){
            if withTime{
                formatter = yesterdayWithTimeFormatter
            }else{
                formatter = yesterdayFormatter
            }
        }else if calendar.isDate(date, equalTo: Date(), toGranularity: .year){
            if withTime{
                formatter = thisYearWithTimeFormatter
            }else{
                formatter = thisYearFormatter
            }
        }else{
            if withTime{
                formatter = generalWithTimeFormatter
            }else{
                formatter = generalFormatter
            }
        }
        return formatter.string(from: date)
    }
}
