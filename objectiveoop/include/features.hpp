//
//  features.hpp
//  objectiveoop
//
//  Created by Kianna on 2025/2/17.
//

//
// Created by Kianna on 25-2-17.
//

#ifndef FEATURES_H
#define FEATURES_H

#include <string>
#include <array>
#include "someDef.hpp"

namespace schedualPrefix {

// 周一课程Json标识符
const std::string mondayLesson[TOTAL_NUMBER_OF_COURSES] = {
    "Monday.firstLesson",
    "Monday.secondLesson",
    "Monday.thirdLesson",
    "Monday.fourthLesson"
};

// 周二课程Json标识符
const std::string TuesdayLesson[TOTAL_NUMBER_OF_COURSES] = {
    "Tuesday.firstLesson",
    "Tuesday.secondLesson",
    "Tuesday.thirdLesson",
    "Tuesday.fourthLesson"
};

// 周三课程Json标识符
const std::string WednesdayLesson[TOTAL_NUMBER_OF_COURSES] = {
    "Wednesday.firstLesson",
    "Wednesday.secondLesson",
    "Wednesday.thirdLesson",
    "Wednesday.fourthLesson"
};

// 周四课程Json标识符
const std::string ThursdayLesson[TOTAL_NUMBER_OF_COURSES] = {
    "Thursday.firstLesson",
    "Thursday.secondLesson",
    "Thursday.thirdLesson",
    "Thursday.fourthLesson"
};

// 周五课程Json标识符
const std::string FridayLesson[TOTAL_NUMBER_OF_COURSES] = {
    "Friday.firstLesson",
    "Friday.secondLesson",
    "Friday.thirdLesson",
    "Friday.fourthLesson"
};

// 周六课程Json标识符
const std::string SaturdayLesson[TOTAL_NUMBER_OF_COURSES] = {
    "Saturday.firstLesson",
    "Saturday.secondLesson",
    "Saturday.thirdLesson",
    "Saturday.fourthLesson"
};

// 周日课程Json标识符
const std::string SundayLesson[TOTAL_NUMBER_OF_COURSES] = {
    "Sunday.firstLesson",
    "Sunday.secondLesson",
    "Sunday.thirdLesson",
    "Sunday.fourthLesson"
};


}
#endif //FEATURES_H
