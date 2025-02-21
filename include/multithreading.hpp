//
//  multithreading.cpp
//  objectiveoop
//
//  Created by Kianna on 2025/2/18.
//

#ifndef MULTITHREADINH_HPP
#define MULTITHREADINH_HPP

#include <string>
#include <vector>
#include <boost/json.hpp>
#include <unordered_map>
#include "../include/schedual.hpp"



namespace Multithreaded {

typedef struct {
    std::string eventTile;  // 事件的标题
    std::string eventStartDate;  // 事件的开始时间
    std::string eventEndDate;  // 事件的结束时间
    std::string eventLocation;  // 事件的发生地址
    std::string deadline;  // 事件的结束时间
}schedualInformation_Struct;

/**
 *@class ThreadedTasks 定义多线程中的执行任务
 */
class ThreadedTasks {
public:
    ThreadedTasks() = default;
    virtual ~ThreadedTasks() = default;
    
    /**
     *@brief ThreadedTasks类的静态方法，指定分组的数量可以用于分组。
     *@param originalVector 进行分组的数组。
     *@param n 分组数量。
     *@return 返回分组后的std::vector<std::vector<std::string>>类型的容器。
     **/
    static std::vector<std::vector<std::string>> splitIntoNGroups(std::vector<std::string> originalVector, const size_t n);
    
    /**
     *@brief 用于执行向日历中添加日程信息的线程任务。
     *@param singleDayCourseInformation Json文件中的键。
     *@param hashTable 传入存储键值对的HashTable。
     *@param ValueCapacity 传入Json文件中的元素容量
     */
    static  void executeWriteScheduleTask(const std::vector<std::string> &singleDayCourseInformation, std::unordered_map<std::string, boost::json::value> &hashTable, std::unordered_map<std::string, int> &ValueCapacity);
};

} /**namespace Multithreaded**/

#endif // MULTITHREADINH_HPP
