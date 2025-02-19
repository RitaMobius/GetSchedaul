/**
 *
 *@file multithreading.mm    定multithreading.hpp文件中定义的函数。
 *@Date 创建时间2025/2/18    最后修改时间2025/2/19
 *@author Dengjizhang  catrinadk@outlook.com
 *
 *@brief GetSchedual通过线程池的方式向系统日历写入日程信息的方法。
 */

#include <iostream>
#include <cassert>
#include "../include/multithreading.hpp"
#include "../include/schedual.hpp"

using namespace Multithreaded;

/*！
 @brief 该方法用于整理解析后的Json文件信息，并根据星系配置日历日程信息，写入日历。设计的目的是用于多线程写入。
 @param singleDayCourseInformation Json标识数组的地址
 @param hashTable 传入哈希表
 @size 设置Json标识数组的大小
 */

void Multithreaded::ThreadedTasks::executeWriteScheduleTask(const std::vector<std::string> &singleDayCourseInformation, std::unordered_map<std::string, boost::json::value> &hashTable, std::unordered_map<std::string, int> &ValueCapacity) {
    int capacity = 0;
    std::string eventDate, hashTableKey;
     schedualInformation_Struct event = {};

     for (const auto & i : singleDayCourseInformation) {
             hashTableKey = i;
             capacity = ValueCapacity[hashTableKey];
             if (const auto it = hashTable.find(hashTableKey); it != hashTable.end()) {
                 std::vector<std::string> scheduleInformation;
                 /*读取目前Json标识符对应的标题、开始事件、结束时间、周期次数、地址等信息*/
                 for (int jsonArrayIndex = 0; jsonArrayIndex < capacity; ++jsonArrayIndex) {
                     hashTableKey.append("." + std::to_string(jsonArrayIndex));
                     if (const auto iter = hashTable.find(hashTableKey); iter != hashTable.end()) {
                         /* 在这里定义插入需要写入日历的内容，循环的结果依次为日程标题、开始时间、结束时间、地址、截止时间*/
                         if (iter->second.kind() == boost::json::kind::string) {
                              eventDate = iter->second.as_string().c_str();
                             scheduleInformation.emplace_back(eventDate);
                         } else if (iter->second.kind() == boost::json::kind::null) {
                             eventDate = "null";
                             scheduleInformation.emplace_back(eventDate);
                         }
                         hashTableKey.erase(hashTableKey.length() - 2, 2);
                     } else {
                         /*这里判断Json数尊格式是否错误，一般的，执行这里的语句为JSON格式错误
                          * 我们定义的Json格式，单个日程的选项最对填入5个选项，如果超过5个则识别为Json格式错误*/
                         std::cerr << "The JSON format is incorrect" << std::endl;
                     }
                 }
                 /*处理完单个Json数组后执行系统日历的写入操作*/
                 for (size_t scheduleInformationIndex = 0; scheduleInformationIndex < scheduleInformation.size(); ++scheduleInformationIndex) {
                     switch (scheduleInformationIndex) {
                         case 0: event.eventTile = scheduleInformation[scheduleInformationIndex]; break;
                         case 1: event.eventStartDate = scheduleInformation[scheduleInformationIndex]; break;
                         case 2: event.eventEndDate = scheduleInformation[scheduleInformationIndex]; break;
                         case 3: event.eventLocation = scheduleInformation[scheduleInformationIndex];break;
                         case 4: event.deadline = scheduleInformation[scheduleInformationIndex]; break;
                         default:
                             std::cout << "GetSchedual 提示：只会向日历中写入：事件标题、开始事件、结束时间、事件地点、事件截止时间，其余的选项将自动忽略！" << std::endl;
                             break;
                     }
                 }
                 
                 std::string startDate = event.eventStartDate;
                 /*从事件开始事件2024-10-10 8:30截取前10个字符得到日期2024-10-10*/
                 startDate.substr(0,10);
                 /*通过事件开始事件计算出事件截止时间*/
                 std::string deadLine = SetSchedual::Schedual::calculateDateAfterWeeks(startDate, std::stoi(event.deadline));
                 
                 NSString *nsStrTile = [[NSString alloc] initWithUTF8String:event.eventTile.c_str()];
                 NSString *nsStrStartDate = [[NSString alloc] initWithUTF8String:event.eventStartDate.c_str()];
                 NSString *nsStrEndDate = [[NSString alloc] initWithUTF8String:event.eventEndDate.c_str()];
                 NSString *nsStrLocation = [[NSString alloc] initWithUTF8String:event.eventLocation.c_str()];
                 NSString *nsStrDeadLine = [[NSString alloc] initWithUTF8String:deadLine.c_str()];
                 
                 /* 重构这里的if-elseif-else语句，这样看着很没水平*/
                 if (event.eventEndDate != "null" && event.eventLocation != "null" && event.deadline != "null") {
                     SetSchedual::Schedual targetSchedual(nsStrTile,nsStrStartDate,nsStrEndDate,nsStrLocation,nsStrDeadLine);
                     targetSchedual.addEventToCalendar();
                 }
                 else if (event.eventEndDate == "null") {
                     if (event.eventLocation == "null") {
                         SetSchedual::Schedual targetSchedual(nsStrTile,nsStrStartDate, nil, nil, nsStrDeadLine);
                         targetSchedual.addEventToCalendar();
                     }
                     else if (event.deadline == "null") {
                         SetSchedual::Schedual targetSchedual(nsStrTile,nsStrStartDate, nil, nsStrLocation,nil);
                         targetSchedual.addEventToCalendar();
                     }
                     else {
                         SetSchedual::Schedual targetSchedual(nsStrTile,nsStrStartDate, nil, nsStrLocation,nsStrDeadLine);
                         targetSchedual.addEventToCalendar();
                     }
                 }
                 else if (event.eventLocation == "null") {
                     if (event.deadline == "null") {
                         SetSchedual::Schedual targetSchedual(nsStrTile,nsStrStartDate, nsStrEndDate, nil, nil);
                         targetSchedual.addEventToCalendar();
                     }
                     else {
                         SetSchedual::Schedual targetSchedual(nsStrTile,nsStrStartDate, nsStrEndDate, nil,nsStrDeadLine);
                         targetSchedual.addEventToCalendar();
                     }
                 }
                 else if (event.deadline == "null") {
                     SetSchedual::Schedual targetSchedual(nsStrTile,nsStrStartDate,nsStrEndDate,nsStrLocation,nil);
                     targetSchedual.addEventToCalendar();
                 }
                 else {
                     SetSchedual::Schedual targetSchedual(nsStrTile,nsStrStartDate,nil,nil,nil);  // 结束时间、地点、截止时间为空
                     targetSchedual.addEventToCalendar();
                 }
                 scheduleInformation.clear();
         }
     }
}


std::vector<std::vector<std::string>> Multithreaded::ThreadedTasks::splitIntoNGroups(std::vector<std::string> originalVector, const size_t n) {
    
    assert(n != 0 && "The number of groups cannot be zero!");
    if (originalVector.empty()) {
        /*如果用户配置的Json文件错误会导致无法被正则表达式匹配，这里会出现空*/
        return {};
    }

    std::vector<std::vector<std::string>> groupedVectors(n);
    const size_t totalSize = originalVector.size();
    const size_t baseSize = totalSize / n;
    const size_t remainder = totalSize % n;

    for (size_t i = 0; i < n; ++i) {
        const size_t groupSize = baseSize + (i < remainder ? 1 : 0);
        groupedVectors[i].reserve(groupSize);
    }

    size_t groupIndex = 0;
    for (auto & it : originalVector) {
        groupedVectors[groupIndex].push_back(std::move(it));
        groupIndex = (groupIndex + 1) % n;
    }

    return groupedVectors;
}
