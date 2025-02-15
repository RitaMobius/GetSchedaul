#import <EventKit/EventKit.h>
#include <iostream>
#include <dispatch/dispatch.h>
#include <Foundation/Foundation.h>
#include <memory>

typedef struct {
    NSString * eventTitle;  // 日程标题
    NSDate* eventStartDate; // 该日程在当天的开始事件
    NSDate* eventEndDate;   // 该日程在当天的结束时间
    NSString* eventLocation;  // 该日程发生的地址
//    NSInteger interval;  // 该日程的重复频率
//    NSString* deadline;  // 该日程的截止时间
}Events;

typedef std::unique_ptr<Events> schedual_ptr;
/*!
 @brief 该函数为辅助函数，用于向日历中添加日晨事件
 */
void addEventToCalendarWithStore(EKEventStore *eventStore, dispatch_semaphore_t semaphore, schedual_ptr& schedual) {
    EKCalendar *defaultCalendar = [eventStore defaultCalendarForNewEvents];
    if (!defaultCalendar) {
        NSLog(@"未找到默认日历");
        dispatch_semaphore_signal(semaphore);  //结束阻塞
        return;
    }

    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    event.title = schedual->eventTitle;  // 设置日程标题
    event.startDate = schedual->eventStartDate;  // 设置日程开始时间 event.startDate = [NSDate date];
    event.endDate = schedual->eventEndDate;  // 设置日程结束时间 event.endDate = [NSDate dateWithTimeInterval:3600 sinceDate:event.startDate];
    event.location = schedual->eventLocation;  // 设置日程发生地点 event.location = @"北京";
    event.calendar = defaultCalendar;  // 设置为默认日历
    
    /* 创建重复规则 */
    NSString *dateString = @"2025-03-01";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    EKRecurrenceEnd* theEndTimeSchedual = [EKRecurrenceEnd recurrenceEndWithEndDate:date];
    
    EKRecurrenceRule * schedualRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequency::EKRecurrenceFrequencyWeekly interval:1 end:theEndTimeSchedual];
    event.recurrenceRules = @[schedualRule];
    NSError *saveError = nil;
    if ([eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&saveError]) {
        NSLog(@"日程事件保存成功，事件标识符: %@", event.eventIdentifier);
    } else {
        NSLog(@"日程事件保存失败，错误信息: %@", saveError.localizedDescription);
    }
    dispatch_semaphore_signal(semaphore);
}

/*!
 @brief 该函数处理日历权限和添加时间。
 @note 对于MacOS14。0+，以及IOS17.0+用户，在申请访问
 @param schedual 用户需要输入的日程事件
 */
void addEventToCalendar(schedual_ptr& schedual) {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    if (@available(iOS 17.0, macOS 14.0, *)) {
        if (status == EKAuthorizationStatusWriteOnly) {
            // 已经授权，直接添加事件
            addEventToCalendarWithStore(eventStore, semaphore, schedual);
        }else{
            // 请求只写入的方法访问
            [eventStore requestWriteOnlyAccessToEventsWithCompletion:^(BOOL granted, NSError * _Nullable error) {
                if (granted) { // 权限已授予，添加事件
                    addEventToCalendarWithStore(eventStore, semaphore, schedual);
                } else {// 权限未授予，输出错误信息
                    NSLog(@"日历仅写入访问权限被拒绝，错误信息: %@", error ? error.localizedDescription : @"无具体错误信息");
                    dispatch_semaphore_signal(semaphore);
                }
            }];
        } }else {  // 旧版本系统，使用旧的权限检查方式
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (status == EKAuthorizationStatusAuthorized) {
            // 已经授权，直接添加事件
            addEventToCalendarWithStore(eventStore, semaphore, schedual);
        } else if (status == EKAuthorizationStatusNotDetermined) {
            // 请求授权
            [eventStore requestWriteOnlyAccessToEventsWithCompletion:^(BOOL granted, NSError * _Nullable error){
                if (granted) {
                    // 权限已授予，继续操作
                    addEventToCalendarWithStore(eventStore, semaphore, schedual);
                } else {
                    // 权限未授予，输出错误信息
                    NSLog(@"日历访问权限被拒绝，错误信息: %@", error ? error.localizedDescription : @"无具体错误信息");
                    dispatch_semaphore_signal(semaphore);
                }
            }];
        } else {
            // 其他状态（如被拒绝），输出错误信息
            NSLog(@"日历访问权限已被拒绝，请在系统设置中更改权限。");
            dispatch_semaphore_signal(semaphore);
        }
#pragma clang diagnostic pop
    }

    // 等待异步操作完成
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"开始事件");
        // 调用函数添加事件到日历
        auto mySchedual = std::make_unique<Events>(nullptr);
        mySchedual->eventTitle = @"测试日程";
        mySchedual->eventStartDate = [NSDate date];
        mySchedual->eventEndDate = [NSDate dateWithTimeInterval:3600 sinceDate:mySchedual->eventStartDate];
        mySchedual->eventLocation = @"荣和林溪府";
        addEventToCalendar(mySchedual);
        std::cout << "程序关闭成功" << std::endl;
        NSLog(@"结束时间");
    }
    return EXIT_SUCCESS;
}
