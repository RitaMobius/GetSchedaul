//
//  json.mm
//  objectiveoop
//
//  Created by Kianna on 2025/2/16.
//

//
// Created by Kianna on 25-2-16.
//


#include <fstream>
#include <iostream>
#include <ranges>
#include <utility>
#include <string>
#include "../include/jsonParsing.hpp"


std::string &schedual::Json::getJsonFileContents() SCHEDUAL_NOEXCEPT {
    return jsonFileContents;
}

schedual::Json::schedual_Map &schedual::Json::getSchedualMap()  SCHEDUAL_NOEXCEPT {
    return schedualMap;
}

const schedual::Json::valueCapacity &schedual::Json::getValueCapacity() noexcept {
    return arrayKeyValue;
}


void schedual::Json::sortJsonToSchedualMap(const boost::json::value &jsonValue, const std::string &parentKey) SCHEDUAL_NOEXCEPT {
    std::stack<stackEntry_pair> stack;
    stack.emplace(jsonValue, parentKey);
    while (!stack.empty()) {
        auto [jsonValue, parentKey] = stack.top();
        stack.pop();
        if (jsonValue.is_object()) {
            for (const boost::json::object &jsonObject = jsonValue.as_object();
                const auto &it: std::ranges::reverse_view(jsonObject)) {
                std::string currentKey = parentKey.empty() ? std::string(it.key()) : parentKey + "." + std::string(it.key());
                if (!schedualMap.contains(currentKey)) {
                    schedualMap[currentKey] = it.value();
                }
                stack.emplace(it.value(), currentKey);
            }
        } else if (jsonValue.is_array()) {
            const boost::json::array &jsonArr = jsonValue.as_array();
            arrayKeyValue.emplace(parentKey, jsonArr.size());
            for (size_t i = jsonArr.size(); i > 0; --i) {
                std::string currentKey = parentKey.empty() ? std::to_string(i - 1) : parentKey + "." + std::to_string(i - 1);
                if (!schedualMap.contains(currentKey)) {
                    schedualMap[currentKey] = jsonArr[i - 1];
                }
                stack.emplace(jsonArr[i - 1], currentKey);
            }
        } else {
            if (!parentKey.empty()) {
                if (!schedualMap.contains(parentKey)) {
                    schedualMap[parentKey] = jsonValue;
                }
            }
        }
    }
}



schedual::Json::Json(std::string path) SCHEDUAL_NOEXCEPT : jsonFileName(std::move(path)){
    
    jsonFileOpen.open(jsonFileName);
        
    if (!jsonFileOpen.is_open()) {
        std::cerr << "The json file cannot be opened." << std::endl;
        return JSON_FILE_OPEN_ERROR;
    }
    
    jsonFileOpen.seekg(0, std::ios::end); // 将文件指针移到文件末尾判断文件是否为空
    if (const std::streamsize jsonFileSize = jsonFileOpen.tellg(); jsonFileSize == 0) {
        
        std::cerr << "Json file is empty. error code: " << JSON_FILE_EMPTY_ERROR_CODE << std::endl;
        return JSON_FILE_IS_EMPTY;
        
    }
    jsonFileOpen.seekg(0, std::ios::beg);  // 将文件光标移动到文件开头读取文件
    std::string content((std::istreambuf_iterator<char>(jsonFileOpen)), std::istreambuf_iterator<char>());
    jsonFileContents = std::move(content);
    
    do {
        jsonFileOpen.close();
        
    } while (jsonFileOpen.is_open());

}

schedual::Json::~Json() = default;
