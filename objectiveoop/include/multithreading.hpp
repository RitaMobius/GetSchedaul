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
    std::string eventTile;
    std::string eventStartDate;
    std::string eventEndDate;
    std::string eventLocation;
    std::string deadline;
}schedualInformation_Struct;

class ThreadedTasks {
public:
    ThreadedTasks() = default;
    virtual ~ThreadedTasks() = default;
    static  void executeWriteScheduleTask(const std::string *singleDayCourseInformation, std::unordered_map<std::string, boost::json::value> &hashTable, std::unordered_map<std::string, int> &ValueCapacity, const size_t size);
};

}

#endif // MULTITHREADINH_HPP
