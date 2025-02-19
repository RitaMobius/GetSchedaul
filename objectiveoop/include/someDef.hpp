//
//  someDef.mm
//  objectiveoop
//
//  Created by Dengjizhang on 2025/2/15.
//  该文件用于GetSchedual项目的配置检查及其常量定义

#ifndef _SET_SCHEDUAL_DEFINE_HPP_
#define _SET_SCHEDUAL_DEFINE_HPP_

#if defined(__cplusplus) && (__cplusplus >= 201103L && !defined(SCHEDUAL_OVERRIDE))  // 检查override是否可用
    #define SCHEDUAL_OVERRIDE override
#else
    #define SCHEDUAL_OVERRIDE
#endif

#if defined(__cplusplus) && (__cplusplus >= 201103L && !defined(SCHEDUAL_NOEXCEPT))  // 检查noexcept是否可用
    #define SCHEDUAL_NOEXCEPT noexcept
#else
    #define SCHEDUAL_NOEXCEPT
#endif

#if defined(__cplusplus) && (__cplusplus >= 201103L && !defined(SCHEDUAL_CONSTEXPR))  // 检查constexpr是否可用
    #define SCHEDUAL_CONSTEXPR constexpr
#else
    #define SCHEDUAL_CONSTEXPR
#endif

#if (defined(__cplusplus) && __cplusplus >= 201703L) && defined(__has_cpp_attribute) && __has_cpp_attribute(nodiscard)  // 检查nodiscard是否可用
    #define SUPPORTS_NODISCARD 1
#else
    #define SUPPORTS_NODISCARD 0
#endif

#if defined(__GNUC__) && __GNUC__ >= 2  // 检查GCC扩展语句是否可用
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

#ifndef GETSCHEDUAL_SOFTWARE_VERSION  // 定义GetSchedual版本信息
    #define GETSCHEDUAL_SOFTWARE_VERSION "GetSchedual Version 1.0"
#endif // GETSCHEDUAL_SOFTWARE_VERSION

#if !defined(SCHEDUAL_COMMAND_HELP) && !defined(SCHEDUAL_COMMAND_P_)  // 定义帮助命令 -h
    #define SCHEDUAL_COMMAND_HELP "help,h"
    #define SCHEDUAL_COMMAND_H_ "help"
#endif  // !defined(SCHEDUAL_COMMAND_HELP) && !defined(SCHEDUAL_COMMAND_P_)

#if !defined(SCHEDUAL_COMMAND_VERSION) && !defined(SCHEDUAL_COMMAND_V_)  // 定义版本信息命令 -v
    #define SCHEDUAL_COMMAND_VERSION "version,v"
    #define SCHEDUAL_COMMAND_V_ "version"
#endif  // !defined(SCHEDUAL_COMMAND_VERSION) && !defined(SCHEDUAL_COMMAND_V_)

#if !defined(SCHEDUAL_COMMAND_TITLE) && !defined(SCHEDUAL_COMMAND_T_)  // 定义设置日程标题命令 -t
    #define SCHEDUAL_COMMAND_TITLE "title,t"
    #define SCHEDUAL_COMMAND_T_ "title"
#endif  // !defined(SCHEDUAL_COMMAND_TITLE) && !defined(SCHEDUAL_COMMAND_T_)

#if !defined(SCHEDUAL_COMMAND_START) && !defined(SCHEDUAL_COMMAND_S_)  // 设置日程开始时间命令 -s
    #define SCHEDUAL_COMMAND_START "start,s"
    #define SCHEDUAL_COMMAND_S_ "start"
#endif  // !defined(SCHEDUAL_COMMAND_START) && !defined(SCHEDUAL_COMMAND_S_)

#if !defined(SCHEDUAL_COMMAND_END) && !defined(SCHEDUAL_COMMAND_E_)  // 设置日程结束时间命令
    #define SCHEDUAL_COMMAND_END "end,e"
    #define SCHEDUAL_COMMAND_E_ "end"
#endif  // !defined(SCHEDUAL_COMMAND_END) && !defined(SCHEDUAL_COMMAND_E_)

#if !defined(SCHEDUAL_COMMAND_LOCATE) && !defined(SCHEDUAL_COMMAND_L_)  // 设置日程发生地命令
    #define SCHEDUAL_COMMAND_LOCATE "locate,l"
    #define SCHEDUAL_COMMAND_L_ "locate"
#endif  //  !defined(SCHEDUAL_COMMAND_LOCATE) && !defined(SCHEDUAL_COMMAND_L_)

#if !defined(SCHEDUAL_COMMAND_DEADLINE) && !defined(SCHEDUAL_COMMAND_D_)  // 设置日程截止时间命令
    #define SCHEDUAL_COMMAND_DEADLINE "deadline,d"
    #define SCHEDUAL_COMMAND_D_ "deadline"
#endif // !defined(SCHEDUAL_COMMAND_DEADLINE) && !defined(SCHEDUAL_COMMAND_D_)

#if !defined(SCHEDUAL_COMMAND_FILE) && !defined(SCHEDUAL_COMMAND_F_)  // 设置通过Json文件配置日程命令
    #define SCHEDUAL_COMMAND_FILE "file,f"
    #define SCHEDUAL_COMMAND_F_ "file"
#endif
#endif // _SET_SCHEDUAL_DEFINE_HPP_
