//
//  schedualCPP.mm
//  objectiveoop
//
//  Created by Kianna on 2025/2/15.
//


#include <chrono>
#include <ctime>
#include <iomanip>
#include <sstream>
#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#include "../include/schedual.hpp"

using namespace SetSchedual;


// 辅助函数：将 NSString 转换为 NSDate
NSDate* Schedual::convertStringToDate(NSString* dateString, NSString* format) SCHEDUAL_NOEXCEPT {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString:dateString];
}

/*！
 @brief 该函数为Schedual类的构造函数，用于初始化日程信息，默认日程为每周重复一次
 @param eventTile 日程标题
 @param eventStartDate 日程的开始时间，格式 2024-10-11 08:30
 @param eventEndDate 日程的结束时间, 格式 2024-10-11 10:05，如果为nil，则设置日期为全天
 @param eventLocation 日程的发生地址，格式 艾欧尼亚
 @param 日程的结束时间，格式 2024-11-07
 */
Schedual::Schedual(NSString* eventTitle, NSString* eventStartDate, NSString* eventEndDate, NSString* eventLocation, NSString* deadline) SCHEDUAL_NOEXCEPT
    : m_eventTitle(eventTitle), m_eventStartDate(eventStartDate), m_eventEndDate(eventEndDate),
m_eventLocation(eventLocation), m_interval(1), m_deadline(deadline), deadlineEmptySatus(true), logBuffer(new std::string()) {
          if (deadline == nil) {
              deadlineEmptySatus = false;
          }else {
              NSDate *date = convertStringToDate(m_deadline, @"yyyy-MM-dd");
              theEndTimeSchedual = [EKRecurrenceEnd recurrenceEndWithEndDate:date];
          }
    
    eventStartDate_ = convertStringToDate(m_eventStartDate, @"yyyy-MM-dd HH:mm");
    
    if (m_eventEndDate == nil) {
        eventEndDate_ = [eventStartDate_ dateByAddingTimeInterval:24 * 60 * 60];
    }
    else {
        eventEndDate_ = convertStringToDate(m_eventEndDate, @"yyyy-MM-dd HH:mm");
    }
          
          do {
              
              logfile = new std::ofstream("/Users/dengjizhang/Schedual.log", std::ios::app);
              std::cout << "文件打开成功！" << std::endl;
          } while (!logfile->is_open());
          
    logBuffer->append(GET_CURRENT_TIME() + "\tSetSchedual程序启动成功.\n");
    
}

Schedual::~Schedual() {
    *logfile << *logBuffer + "\n";
    NSLog(@"文件写入成功！");
    logfile->close();
    delete logfile;
    delete logBuffer;
}
    
void Schedual::addEventToCalendarWithStore(EKEventStore *eventStore, dispatch_semaphore_t semaphore) SCHEDUAL_NOEXCEPT {
    EKCalendar *defaultCalendar = [eventStore defaultCalendarForNewEvents];
    if (!defaultCalendar) {
        NSLog(@"未找到默认日历");
        logBuffer->append(GET_CURRENT_TIME() + "\t未找到默认日历程序 ------> 程序退出.\n");
        dispatch_semaphore_signal(semaphore);
        return;
    }
        
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    event.title = m_eventTitle;
    event.startDate = eventStartDate_;
    event.endDate = eventEndDate_;
    event.location = m_eventLocation;
    event.calendar = defaultCalendar;
    if (m_eventEndDate == nil) {
        event.allDay = YES;
    }
    else
    {
        event.allDay = NO;
    }

    if (!event.startDate || !event.endDate) {
        NSLog(@"日程开始或结束日期无效，无法保存事件");
        logBuffer->append(GET_CURRENT_TIME() + "\t日程开始或结束日期无效，无法保存事件 ------> 程序退出.\n");
        dispatch_semaphore_signal(semaphore);
        return;
    }
    
    if (deadlineEmptySatus == true) {
        EKRecurrenceRule *schedualRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly interval:m_interval end:theEndTimeSchedual];  // 设置日程结束规则
        event.recurrenceRules = @[schedualRule];
    }
    
    NSError *saveError = nil;
    if ([eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&saveError]) {
        NSLog(@"日程事件保存成功，事件标识符: %@", event.eventIdentifier);
        logBuffer->append(GET_CURRENT_TIME() + "\t日程事件保存成功，事件标识符：" + [event.eventIdentifier UTF8String] +"\n");
    } else {
        NSLog(@"日程事件保存失败，错误信息: %@", saveError.localizedDescription);
        logBuffer->append(GET_CURRENT_TIME() + "\t日程事件保存成功，事件标识符：" + [saveError.localizedDescription UTF8String] + "\n");
    }
    dispatch_semaphore_signal(semaphore);
}

/*!
 @brief 该函数用于向系统日历添加日程信息，该方法首先会进行权限判断，如果用户给予权限则以只读的方式向其中系统日历中添加日程信息。
 */
void Schedual::addEventToCalendar() noexcept {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];

    auto handleAuthorization = [this, eventStore, semaphore](BOOL granted, NSError *error) {
        if (granted) {
            addEventToCalendarWithStore(eventStore, semaphore);
        } else {
            NSLog(@"日历访问权限被拒绝，错误信息: %@", error ? error.localizedDescription : @"无具体错误信息");
            logBuffer->append(GET_CURRENT_TIME() + "\t日志访问权限被拒绝，错误星系：" + [error.localizedDescription UTF8String] + "\n");
            dispatch_semaphore_signal(semaphore);
        }
    };
    
    if (@available(iOS 17.0, macOS 14.0, *)) {
        if (status == EKAuthorizationStatusWriteOnly) {
            addEventToCalendarWithStore(eventStore, semaphore);
        } else {
            [eventStore requestWriteOnlyAccessToEventsWithCompletion:handleAuthorization];
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (status == EKAuthorizationStatusAuthorized) {
            addEventToCalendarWithStore(eventStore, semaphore);
        } else if (status == EKAuthorizationStatusNotDetermined) {
            [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:handleAuthorization];
        } else {
            NSLog(@"日历访问权限已被拒绝，请在系统设置中更改权限。");
            logBuffer->append(GET_CURRENT_TIME() + "\t日历访问权限已被拒绝，请在系统设置中更改权限.\n");
            dispatch_semaphore_signal(semaphore);
        }
#pragma clang diagnostic pop
    }
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

/*！
 @brief 该函数用于计算间隔日期，例如传入当前时间2024-10-11，间隔4周（28），计算得出相加后的结果。
 @param satrtDateStr 传入当前时间，格式2024-10-11
 @weeks 传入间隔的周数，例如6周
 @return 返回计算后的时间，格式2024-10-11
 */
std::string Schedual::calculateDateAfterWeeks(const std::string& startDateStr, int weeks) {
     std::tm tm = {};
     std::istringstream ss(startDateStr);
     ss >> std::get_time(&tm, "%Y-%m-%d");
     std::chrono::system_clock::time_point startDate = std::chrono::system_clock::from_time_t(std::mktime(&tm));
     auto daysToAdd = std::chrono::weeks(weeks);
     auto endDate = startDate + daysToAdd;
     const std::time_t tt = std::chrono::system_clock::to_time_t(endDate);
     const std::tm* tmEnd = std::localtime(&tt);
     std::ostringstream oss;
     oss << std::put_time(tmEnd, "%Y-%m-%d");
     return oss.str();
}


