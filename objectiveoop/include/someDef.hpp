//
//  someDef.mm
//  objectiveoop
//
//  Created by Kianna on 2025/2/15.
//

#ifndef _SET_SCHEDUAL_DEFINE_HPP_
#define _SET_SCHEDUAL_DEFINE_HPP_

#if defined(__cplusplus) && (__cplusplus >= 201103L && !defined(SCHEDUAL_OVERRIDE))
    #define SCHEDUAL_OVERRIDE override
#else
    #define SCHEDUAL_OVERRIDE
#endif

#if defined(__cplusplus) && (__cplusplus >= 201103L && !defined(SCHEDUAL_NOEXCEPT))
    #define SCHEDUAL_NOEXCEPT noexcept
#else
    #define SCHEDUAL_NOEXCEPT
#endif

#if defined(__cplusplus) && (__cplusplus >= 201103L && !defined(SCHEDUAL_CONSTEXPR))
    #define SCHEDUAL_CONSTEXPR constexpr
#else
    #define SCHEDUAL_CONSTEXPR
#endif

#if (defined(__cplusplus) && __cplusplus >= 201703L) && defined(__has_cpp_attribute) && __has_cpp_attribute(nodiscard)
    #define SUPPORTS_NODISCARD 1
#else
    #define SUPPORTS_NODISCARD 0
#endif

#if defined(__GNUC__) && __GNUC__ >= 2
    #define GCC_EXTENSIONS_AVAILABLE 1
#else
    #define GCC_EXTENSIONS_AVAILABLE 0
#endif

// 宏GET_CURRENT_TIME() 用于获取系统当前时间
#if defined(GCC_EXTENSIONS_AVAILABLE) && GCC_EXTENSIONS_AVAILABLE == 1
#define GET_CURRENT_TIME() ({\
    auto now = std::chrono::system_clock::now();\
    std::time_t currentTime = std::chrono::system_clock::to_time_t(now);\
    std::tm* localTime = std::localtime(&currentTime);\
    std::ostringstream oss;\
    oss << std::put_time(localTime, "%Y-%m-%d %H:%M:%S");\
    oss.str();\
})
#endif // defined(GCC_EXTENSIONS_AVAILABLE)

#ifndef SCHEDUAL_ESSENTIAL
#define SCHEDUAL_ESSENTIAL
#endif

#if defined(SUPPORTS_NODISCARD) && SUPPORTS_NODISCARD == 1
#    define SCHEDUAL_NODISCARD [[nodiscard]]
#else
#    define SCHEDUAL_NODISCARD
#endif // SUPPORTS_NODISCARD

#ifndef JSON_FILE_EMPTY_ERROR_CODE
    #define JSON_FILE_EMPTY_ERROR_CODE "00"
#endif // JSON_FILE_EMPTY_ERROR_CODE

#ifndef JSON_FILE_OPEN_ERROR
    #define JSON_FILE_OPEN_ERROR
#endif // JSON_FILE_OPEN_ERROR

#ifndef JSON_FILE_IS_EMPTY
    #define JSON_FILE_IS_EMPTY
#endif // JSON_FILE_IS_EMPTY

// 宏TOTAL_NUMBER_OF_COURSES用于标记Json标识的容量
#ifndef TOTAL_NUMBER_OF_COURSES
    #define TOTAL_NUMBER_OF_COURSES 4
#endif // TOTAL_NUMBER_OF_COURSES

#ifndef NUMBER_OF_THREADS
    #define NUMBER_OF_THREADS 7
#endif // NUMBER_OF_THREADS

#endif // _SET_SCHEDUAL_DEFINE_HPP_
