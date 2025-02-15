#import <EventKit/EventKit.h>
#include <iostream>
#include <dispatch/dispatch.h>
#import <Foundation/Foundation.h>
#include <memory>
#include "include/schedual.hpp"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"开始事件");
        // 调用函数添加事件到日历
//        auto mySchedual = std::make_unique<Events>(nullptr);
//        mySchedual->eventTitle = @"测试日程";
//        mySchedual->eventStartDate = [NSDate date];
//        mySchedual->eventEndDate = [NSDate dateWithTimeInterval:3600 sinceDate:mySchedual->eventStartDate];
//        mySchedual->eventLocation = @"荣和林溪府";
//        addEventToCalendar(mySchedual);
        Schedual mySchedual(@"测试标题", @"2025-02-16 21:00", @"2025-02-16 23:00", @"临桂中学");
        mySchedual.addEventToCalendar();
        std::cout << "程序关闭成功" << std::endl;
        NSLog(@"结束时间");
    }
    return EXIT_SUCCESS;
}
