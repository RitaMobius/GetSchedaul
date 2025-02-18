//
//  schedual.mm
//  objectiveoop
//
//  Created by Kianna on 2025/2/15.
//

#ifndef _SCHEDUAL_H_
#define _SCHEDUAL_H_

#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <iomanip>
#include <chrono>
#include <ctime>
#include <boost/json.hpp>
#include <dispatch/dispatch.h>
#include "someDef.hpp"
#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>


namespace SetSchedual {

typedef struct {
    std::string eventTile;
    std::string eventStartDate;
    std::string eventEndDate;
    std::string eventLocation;
    std::string deadline;
}schedualInformation_Struct;

class SCHEDUAL_ESSENTIAL Schedual {
private:
    
    NSString* m_eventTitle;  // 日程标题
    NSString* m_eventStartDate; // 该日程在当天的开始事件
    NSString* m_eventEndDate;   // 该日程在当天的结束时间
    NSString* m_eventLocation;  // 该日程发生的地址
    NSInteger m_interval;  // 该日程的重复频率
    NSString* m_deadline;  // 该日程的截止时间  @"2025-03-01"
    
    bool deadlineEmptySatus;
    std::string* logBuffer;
    NSDate* eventStartDate_;
    NSDate* eventEndDate_;
    EKRecurrenceEnd* theEndTimeSchedual;  //转换后的截止时间
    std::ofstream* logfile;
    
    NSDate* convertStringToDate(NSString* dateString, NSString* format) SCHEDUAL_NOEXCEPT;
    void addEventToCalendarWithStore(EKEventStore *eventStore, dispatch_semaphore_t semaphore) SCHEDUAL_NOEXCEPT;
    
public:
    Schedual();
    ~Schedual();
    static std::string calculateDateAfterWeeks(const std::string& startDateStr, int weeks);
    Schedual(NSString* eventTitle, NSString* eventStartDate, NSString* eventEndDate = nil, NSString* eventLocation = nil, NSString* deadline = nil) SCHEDUAL_NOEXCEPT;
    void addEventToCalendar() SCHEDUAL_NOEXCEPT;
};
}

#endif
