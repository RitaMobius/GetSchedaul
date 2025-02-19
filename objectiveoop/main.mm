/**
 *
 *             @file main.h    main（）函数入口所在文件。
 *             @Date 2025-02-19
 *             @author Dengjizhang  catrinadk@outlook.com
 *
 *             @brief GetSchedual项目本项目EventKit框架、Boost库开发。是一款用于在系统日历中添加日程信息的程序，用户可以通过GetSchedual向MacOS系统默认日历中输入单个日程的标题、
 *             日程开始时间、日程结束时间、日程目的地、日程截止时间等信息。同时，用户也可以通过简单地配置Json文件批量向系统日历中写入日程信息。其中会向用户申请对系统日历的访问权限。
 *
 *
 */





#include <iostream>
#include <thread>
#include <mutex>
#include <queue>
#include <regex>
#include <functional>
#include <dispatch/dispatch.h>
#include <boost/program_options.hpp>
#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#include "include/schedual.hpp"
#include "include/jsonParsing.hpp"
#include "include/features.hpp"
#include "include/multithreading.hpp"


std::queue<std::function<void(std::function<void()>)>> taskQueue;
std::mutex taskQueueMutex;
std::condition_variable taskQueueCV;
std::atomic<bool> stopThreadPool(false);

/**
 *    @brief main函数，首先会解析用户输入的命令，根据用户输入的命令执行相应的操作。如果用户指定-f/--file命令，则需要指定Json文件的地址，GetSchedual会通过解析用户配置的Json文件
 *    配置日程信息。用户定义的Json文件需要遵守一定的规则，一个对象中可以存在多个数组，数组之中即可以存在任意个数的数组元素，也可以是字符、数字等元素，但是对象中不能再出现对象，
 *    否则GetSchedual无法解析Json文件。除此之外，用户还可以指定参数设置单个日程信息，-t 设置日程标题，-s 设置日程的开始时间，-e 设置日程的结束时间，-l 设置日程的目的地，-d 设置日
 *    程的截止时间。设置单个日程信息必须同时指定 -t , -s参数，-e ，-l ，-d参数可以自由组合排列。如果用户没有指定 -e 参数，则该日程设置为全天。
 */

int main(int argc, const char * argv[]) {

    @autoreleasepool {
        std::string filename;
        try {
            boost::program_options::options_description commandLineProcessing("GetSchedual帮助文档");
            commandLineProcessing.add_options()	
            (SCHEDUAL_COMMAND_HELP, "获取帮助信息")
            (SCHEDUAL_COMMAND_VERSION, "获取GetSchedual版本信息")
            (SCHEDUAL_COMMAND_TITLE, boost::program_options::value<std::string>(), "设置日程信息的标题")
            (SCHEDUAL_COMMAND_START, boost::program_options::value<std::string>(), "设置日程的开始时间")
            (SCHEDUAL_COMMAND_END, boost::program_options::value<std::string>(), "设置日程的结束时间")
            (SCHEDUAL_COMMAND_LOCATE, boost::program_options::value<std::string>(), "设置日程的发生地")
            (SCHEDUAL_COMMAND_DEADLINE,boost::program_options::value<std::string>(), "设置日程的截止时间")
            (SCHEDUAL_COMMAND_FILE, boost::program_options::value<std::string>(&filename), "指定要处理的Json文件");
            
            boost::program_options::variables_map parameterOption;
            boost::program_options::store(boost::program_options::parse_command_line(argc, argv, commandLineProcessing), parameterOption);
            boost::program_options::notify(parameterOption);
            
            /*如果使用了-h/--helpe参数，不能混合其他参数使用*/
            if (parameterOption.contains(SCHEDUAL_COMMAND_H_)) {
                if (parameterOption.contains(SCHEDUAL_COMMAND_V_) || parameterOption.contains(SCHEDUAL_COMMAND_T_) || parameterOption.contains(SCHEDUAL_COMMAND_S_ ) || parameterOption.contains(SCHEDUAL_COMMAND_E_ ) || parameterOption.contains(SCHEDUAL_COMMAND_L_) || parameterOption.contains(SCHEDUAL_COMMAND_D_) || parameterOption.contains(SCHEDUAL_COMMAND_F_ )) {
                    std::cerr << "Option -h,--help must be used alone." << std::endl;
                    return EXIT_SUCCESS;
                }
                std::cout << commandLineProcessing << std::endl;
                return EXIT_SUCCESS;
            }
            
            /*Version 参数不能与其他参数一起使用*/
            if (parameterOption.contains(SCHEDUAL_COMMAND_V_ )) {
                if (parameterOption.contains(SCHEDUAL_COMMAND_H_ ) || parameterOption.contains(SCHEDUAL_COMMAND_T_) || parameterOption.contains(SCHEDUAL_COMMAND_S_) || parameterOption.contains(SCHEDUAL_COMMAND_E_) || parameterOption.contains(SCHEDUAL_COMMAND_L_) || parameterOption.contains(SCHEDUAL_COMMAND_D_) || parameterOption.contains(SCHEDUAL_COMMAND_F_ )) {
                    std::cerr << "Option -v,--Version must be used alone." << std::endl;
                    return EXIT_SUCCESS;
                }
                std::cout << GETSCHEDUAL_SOFTWARE_VERSION << std::endl;
                /*可以考虑在这里插入ASCII字符画，比如广告招租*/
                return EXIT_SUCCESS;
            }
            
            /*参数-e、-l、-d必须与-t、-s同时使用。"end,e", locate,l“， "deadline,d"，他们之间可以排列组合或者单个使用 */
            if (parameterOption.contains(SCHEDUAL_COMMAND_E_) || parameterOption.contains(SCHEDUAL_COMMAND_L_) || parameterOption.contains(SCHEDUAL_COMMAND_D_)) {
                if (!parameterOption.contains(SCHEDUAL_COMMAND_T_) || !parameterOption.contains(SCHEDUAL_COMMAND_S_)) {
                    std::cerr << "Options -e, -T, -d must be used together with -t and -s." << std::endl;
                    return EXIT_SUCCESS;
                }
            }
            /*File参数不能与其他参数一起使用*/
            if (parameterOption.contains(SCHEDUAL_COMMAND_F_ )) {
                if (parameterOption.contains(SCHEDUAL_COMMAND_V_) || parameterOption.contains(SCHEDUAL_COMMAND_T_) || parameterOption.contains(SCHEDUAL_COMMAND_S_) || parameterOption.contains(SCHEDUAL_COMMAND_E_) || parameterOption.contains(SCHEDUAL_COMMAND_L_) || parameterOption.contains(SCHEDUAL_COMMAND_D_) || parameterOption.contains(SCHEDUAL_COMMAND_H_)) {
                    std::cerr << "Option -f,--file must be used alone." << std::endl;
                    return EXIT_SUCCESS;
                }
                
                const std::regex pattern(R"([a-zA-Z]+\.[a-zA-Z]+)");
                std::vector<std::string>  featureKey;
                
                schedual::Json getJson(filename);
                const boost::json::value jsonValue = boost::json::parse(getJson.getJsonFileContents());
                getJson.sortJsonToSchedualMap(jsonValue);
                std::unordered_map<std::string, boost::json::value> hashTable = getJson.getSchedualMap();
                
                for (auto &[fst, snd] : hashTable) {
                    if (std::regex_match(fst, pattern)) {
                        featureKey.emplace_back(fst);
                    }
                }
                
                // 分组
                const std::vector<std::vector<std::string>> resul = Multithreaded::ThreadedTasks::splitIntoNGroups(std::move(featureKey),NUMBER_OF_THREADS);
                if (resul.empty()) {
                    /*这里为空的原因，用户配置Json文件错误找不到对应的字符串，要么文件为空*/
                    return EXIT_SUCCESS;
                }
                std::unordered_map<std::string, int> jsonValueCapacity = getJson.getValueCapacity();
                SCHEDUAL_CONSTEXPR int numThreads = NUMBER_OF_THREADS;
                std::vector<std::thread> threads;

                threads.reserve(numThreads);
                for (int i = 0; i < numThreads; ++i) {
                    threads.emplace_back(Multithreaded::ThreadPools::schedualWorkerThread);
                }
                if(!resul[0].empty()) {
                    Multithreaded::ThreadPools::addExecutionTask([&hashTable,&jsonValueCapacity,&resul](const std::function<void()> &func) {
                        Multithreaded::ThreadedTasks::executeWriteScheduleTask(resul[0], hashTable,jsonValueCapacity);
                        func();
                    });
                }
                if (!resul[1].empty()) {
                    Multithreaded::ThreadPools::addExecutionTask([&hashTable,&jsonValueCapacity,&resul](const std::function<void()> &func) {
                        Multithreaded::ThreadedTasks::executeWriteScheduleTask(resul[1], hashTable, jsonValueCapacity);
                        func();
                    });
                }
                if (!resul[2].empty()) {
                    Multithreaded::ThreadPools::addExecutionTask([&hashTable,&jsonValueCapacity,&resul](const std::function<void()> &func) {
                        Multithreaded::ThreadedTasks::executeWriteScheduleTask(resul[2], hashTable, jsonValueCapacity);
                        func();
                    });
                }
                if (!resul[3].empty()) {
                    Multithreaded::ThreadPools::addExecutionTask([&hashTable,&jsonValueCapacity,&resul](const std::function<void()> &func) {
                        Multithreaded::ThreadedTasks::executeWriteScheduleTask(resul[3], hashTable, jsonValueCapacity);
                        func();
                    });
                }
                if (!resul[4].empty()) {
                    Multithreaded::ThreadPools::addExecutionTask([&hashTable,&jsonValueCapacity,&resul](const std::function<void()> &func) {
                        Multithreaded::ThreadedTasks::executeWriteScheduleTask(resul[4], hashTable, jsonValueCapacity);
                        func();
                    });
                }
                
                if (!resul[5].empty()) {
                    Multithreaded::ThreadPools::addExecutionTask([&hashTable,&jsonValueCapacity,&resul](const std::function<void()> &func) {
                        Multithreaded::ThreadedTasks::executeWriteScheduleTask(resul[5], hashTable, jsonValueCapacity);
                        func();
                    });
                }
                if (!resul[6].empty()) {
                    Multithreaded::ThreadPools::addExecutionTask([&hashTable,&jsonValueCapacity,&resul](const std::function<void()> &func) {
                        Multithreaded::ThreadedTasks::executeWriteScheduleTask(resul[6], hashTable, jsonValueCapacity);
                        func();
                    });
                }
                Multithreaded::ThreadPools::stopPool();

                for (auto& thread : threads) {
                    if (thread.joinable()) {
                        thread.join();
                    }
                }
            } else {
                /*修改这里的错误提示，2025/2/19*/
                std::cerr << "未提供 -f 选项和文件名称。使用 -h 获取帮助。" << std::endl;
                return EXIT_SUCCESS;
            }
            
            
            /*参数-t、-s必须同时使用，设置日程的标题、开始时间*/
            if (parameterOption.contains(SCHEDUAL_COMMAND_T_) || parameterOption.contains(SCHEDUAL_COMMAND_S_)) {
                if (!parameterOption.contains(SCHEDUAL_COMMAND_T_) || !parameterOption.contains(SCHEDUAL_COMMAND_S_)) {
                    std::cerr << "Both -t and -s options are required when using them." << std::endl;
                    return EXIT_SUCCESS;
                }
                Multithreaded::schedualInformation_Struct event = {};
                /*设置插入选项*/
                event.eventTile = parameterOption[SCHEDUAL_COMMAND_T_].as<std::string>();
                event.eventStartDate = parameterOption[SCHEDUAL_COMMAND_S_].as<std::string>();
                NSString *nsStrTile = [[NSString alloc] initWithUTF8String:event.eventTile.c_str()];
                NSString *nsStrStartDate = [[NSString alloc] initWithUTF8String:event.eventStartDate.c_str()];
                
                NSString *nsStrEndDate = nil;
                NSString *nsStrLocation = nil;
                NSString *nsStrDeadLine = nil;
                
                if(parameterOption.contains(SCHEDUAL_COMMAND_E_)) {
                    event.eventEndDate = parameterOption[SCHEDUAL_COMMAND_E_].as<std::string>();
                    nsStrEndDate = [[NSString alloc] initWithUTF8String:event.eventEndDate.c_str()];
                }
                if (parameterOption.contains(SCHEDUAL_COMMAND_L_)) {
                    event.eventLocation = parameterOption[SCHEDUAL_COMMAND_L_].as<std::string>();
                    nsStrLocation = [[NSString alloc] initWithUTF8String:event.eventLocation.c_str()];
                }
                if (parameterOption.contains(SCHEDUAL_COMMAND_D_)) {
                    event.deadline = parameterOption[SCHEDUAL_COMMAND_D_].as<std::string>();
                    std::string startDate = event.eventStartDate;
                    startDate.substr(0,10);
                    std::string deadLine = SetSchedual::Schedual::calculateDateAfterWeeks(startDate, std::stoi(event.deadline));
                    nsStrDeadLine = [[NSString alloc] initWithUTF8String:deadLine.c_str()];
                    
                }
                SetSchedual::Schedual targetSchedual(nsStrTile,nsStrStartDate,nsStrEndDate,nsStrLocation,nsStrDeadLine);
                targetSchedual.addEventToCalendar(); // 写入
            }
            
            
        } catch (const std::exception& e) {
            /*修改这里的错误信息*/
            std::cerr << "错误: " << e.what() << std::endl;
            return EXIT_SUCCESS;
        }
    }
    return EXIT_SUCCESS;
}


/** @brief 创建工作线程*/
void  Multithreaded::ThreadPools::schedualWorkerThread() {
    while (!stopThreadPool) {
        std::function<void(std::function<void()>)> task;
        {
            std::unique_lock<std::mutex> lock(taskQueueMutex);
            taskQueueCV.wait(lock, [] { return!taskQueue.empty() || stopThreadPool; });
            if (stopThreadPool && taskQueue.empty()) {
                return;
            }
            task = std::move(taskQueue.front());
            taskQueue.pop();
        }
        task([]() {});
    }
}

/** @brief 用于向线程池中添加任务*/
void Multithreaded::ThreadPools::addExecutionTask(const std::function<void(std::function<void()>)>& task) {
    {
        std::lock_guard<std::mutex> lock(taskQueueMutex);
        taskQueue.push(task);
    }
    taskQueueCV.notify_one();
}

/**@brief 用于停止线程池**/
void Multithreaded::ThreadPools::stopPool() {
    stopThreadPool = true;
    taskQueueCV.notify_all();
}
