//
//  someDef.mm
//  objectiveoop
//
//  Created by Kianna on 2025/2/15.
//

#ifndef _SET_SCHEDUAL_DEFINE_HPP_
#define _SET_SCHEDUAL_DEFINE_HPP_

#if __cplusplus >= 201103L || !defined(SCHEDUAL_OVERRIDE)
#define SCHEDUAL_OVERRIDE override
#else
    #define SCHEDUAL_OVERRIDE
#endif

#if __cplusplus >= 201103L || !defined(SCHEDUAL_NOEXCEPT)
#define SCHEDUAL_NOEXCEPT noexcept
#else
    #define SCHEDUAL_NOEXCEPT
#endif

#ifndef SCHEDUAL_ESSENTIAL
#define SCHEDUAL_ESSENTIAL
#endif

#ifdef __GNUC__
    #if __GNUC__ >= 2
        #define GCC_EXTENSIONS_AVAILABLE 1
    #endif
#endif

#if defined(GCC_EXTENSIONS_AVAILABLE)
#define GET_CURRENT_TIME() ({\
    auto now = std::chrono::system_clock::now();\
    std::time_t currentTime = std::chrono::system_clock::to_time_t(now);\
    std::tm* localTime = std::localtime(&currentTime);\
    std::ostringstream oss;\
    oss << std::put_time(localTime, "%Y-%m-%d %H:%M:%S");\
    oss.str();\
})
#endif

#endif // _SET_SCHEDUAL_DEFINE_HPP_
