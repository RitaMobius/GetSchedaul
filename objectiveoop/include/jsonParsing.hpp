//
//  json.hpp
//  objectiveoop
//
//  Created by Kianna on 2025/2/16.
//

//
// Created by Kianna on 25-2-16.
//

#ifndef JSONPARSING_H
#define JSONPARSING_H


#include <fstream>
#include <string>
#include <boost/json.hpp>
#include "someDef.hpp"

namespace schedual {
class Json {
private:
    typedef std::unordered_map<std::string, boost::json::value> schedual_Map;
    typedef std::pair<boost::json::value, std::string> stackEntry_pair;
    typedef std::unordered_map<std::string, int> valueCapacity;

    std::string jsonFileName;
    std::ifstream jsonFileOpen;
    std::string jsonFileContents;
    schedual_Map schedualMap;
    valueCapacity arrayKeyValue;

public:
    explicit Json(std::string path) SCHEDUAL_NOEXCEPT;

    virtual ~Json();

    SCHEDUAL_NODISCARD std::string &getJsonFileContents() SCHEDUAL_NOEXCEPT;

    SCHEDUAL_NODISCARD schedual_Map &getSchedualMap()  SCHEDUAL_NOEXCEPT;
    
    [[nodiscard]] const valueCapacity &getValueCapacity()  noexcept;

    void sortJsonToSchedualMap(const boost::json::value &jsonValue, const std::string &parentKey = "") SCHEDUAL_NOEXCEPT;
};
}


#endif //JSONPARSING_H
