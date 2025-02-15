//
//  schedual.mm
//  objectiveoop
//
//  Created by Kianna on 2025/2/15.
//

#ifndef _SCHEDUAL_H_
#define _SCHEDUAL_H_
/* There is C Plus Plus hander file*/
#include "someDef.hpp"
#include <iostream>
#include <dispatch/dispatch.h>
#include <fstream>
#include <string>

/* There is Objective-C hander file*/
#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

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
    Schedual(NSString* eventTitle, NSString* eventStartDate, NSString* eventEndDate, NSString* eventLocation, NSString* deadline = nil) SCHEDUAL_NOEXCEPT;
    void addEventToCalendar() SCHEDUAL_NOEXCEPT;
};

#endif
