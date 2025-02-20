/**
 *
 *@file schedual.hpp    定multithreading.hpp文件中定义的函数。
 *@Date 创建时间2025/2/15    最后修改时间2025/2/17
 *
 *@author Dengjizhang  catrinadk@outlook.com
 *
 *@brief GetSchedual通过线程池的方式向系统日历写入日程信息的方法。
 */

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


/**
 @class Schedual 定义配置日程信息并向系统日历中写入日程信息的方法。
 */
class SCHEDUAL_ESSENTIAL Schedual {
private:
    
    NSString* m_eventTitle;  // 日程标题
    NSString* m_eventStartDate; // 该日程在当天的开始事件
    NSString* m_eventEndDate;   // 该日程在当天的结束时间
    NSString* m_eventLocation;  // 该日程发生的地址
    NSInteger m_interval;  // 该日程的重复频率
    NSString* m_deadline;  // 该日程的截止时间  @"2025-03-01"
    
    bool deadlineEmptySatus;
    std::string* logBuffer;   // 日志内容存储缓冲区
    NSDate* eventStartDate_;   // 转换后的事件开始事件
    NSDate* eventEndDate_;    // 转换后的事件结束时间
    EKRecurrenceEnd* theEndTimeSchedual;  //转换后的截止时间
    std::ofstream* logfile;   // 日志文件
    
    /**@brief Schedual的private属性方法，用于将NSString类型转换成NSDate类型。在类的构造函数中会调用**/
    NSDate* convertStringToDate(NSString* dateString, NSString* format) SCHEDUAL_NOEXCEPT;
    
    /**@brief Schedual的private属性方法，在调用addEventToCalendar函数时会自动调用该方法将日程配置信息写入系统日历中**/
    void addEventToCalendarWithStore(EKEventStore *eventStore, dispatch_semaphore_t semaphore) SCHEDUAL_NOEXCEPT;
    
public:
    ~Schedual();
    
    /**
     *@brief Schedual的静态方法，用于计算日期，例如输入日期为2024-02-11，加上3周，计算结果为2024-03-04。
     *@param startDateStr 开始时间，格式2024-02-11。
     *@param weeks   相隔的时间，单位为一周。
     *@return 返回当前日期与相隔时间做加法运算后的日期，格式为2024-02-11。
     */
    static std::string calculateDateAfterWeeks(const std::string& startDateStr, int weeks);
    
    /**
     *@brief Schedual类的构造函数，用于初始化写入日历的日程信息。
     *@param eventTitle  事件的标题。
     *@param eventStartDate  事件的开始时间。
     *@param eventEndDate  事件的结束时间。
     *@param eventLocation  事件的发生地址。
     *@param deadline 事件的截止时间。
     */
    Schedual(NSString* eventTitle, NSString* eventStartDate, NSString* eventEndDate = nil, NSString* eventLocation = nil, NSString* deadline = nil) SCHEDUAL_NOEXCEPT;
    
    /**@brief 向系统日历中写入配置好的日程信息  **/
    void addEventToCalendar() SCHEDUAL_NOEXCEPT;
};
}  /**namespace SetSchedual **/

#endif
