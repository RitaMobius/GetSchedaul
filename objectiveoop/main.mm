#include <iostream>
#include <thread>
#include <mutex>
#include <queue>
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

namespace Multithreaded {

class ThreadPools {
public:
    ThreadPools() = default;
    virtual ~ThreadPools() = default;
    static void schedualWorkerThread();
    static void stopPool();
    static void addExecutionTask(const std::function<void(std::function<void()>)>& task);
};

}  // namespace Multithreaded



// note : 接下来的内容，能够输出帮助文档，并且展示Json文件的配置方式。 单个日程的添加办法，做好维护代码的注释，增加处理命令行空参数的情况

int main(int argc, const char * argv[]) {

    @autoreleasepool {
        std::string filename;
        try {
            boost::program_options::options_description commandLineProcessing("GetSchedual帮助文档");
            commandLineProcessing.add_options()
            ("help,h", "显示帮助信息")
            ("file,f", boost::program_options::value<std::string>(&filename), "指定要处理的Json文件");
            
            boost::program_options::variables_map parameterOption;
            boost::program_options::store(boost::program_options::parse_command_line(argc, argv, commandLineProcessing), parameterOption);
            boost::program_options::notify(parameterOption);
            
            if (parameterOption.contains("help")) {
                std::cout << commandLineProcessing << std::endl;
                return EXIT_SUCCESS;
            }
            
            if (parameterOption.contains("file")) {
                schedual::Json getJson(filename);
                const boost::json::value jsonValue = boost::json::parse(getJson.getJsonFileContents());
                getJson.sortJsonToSchedualMap(jsonValue);
                std::unordered_map<std::string, boost::json::value> hashTable = getJson.getSchedualMap();
                
                SCHEDUAL_CONSTEXPR int numThreads = NUMBER_OF_THREADS;
                std::vector<std::thread> threads;

                threads.reserve(numThreads);
                for (int i = 0; i < numThreads; ++i) {
                    threads.emplace_back(Multithreaded::ThreadPools::schedualWorkerThread);
                }

                Multithreaded::ThreadPools::addExecutionTask([&hashTable](const std::function<void()> &func) {
                    Multithreaded::ThreadedTasks::executeWriteScheduleTask(schedualPrefix::mondayLesson, hashTable, TOTAL_NUMBER_OF_COURSES);
                    func();
                });
                
                Multithreaded::ThreadPools::addExecutionTask([&hashTable](const std::function<void()> &func) {
                    Multithreaded::ThreadedTasks::executeWriteScheduleTask(schedualPrefix::TuesdayLesson, hashTable, TOTAL_NUMBER_OF_COURSES);
                    func();
                });
                
                Multithreaded::ThreadPools::addExecutionTask([&hashTable](const std::function<void()> &func) {
                    Multithreaded::ThreadedTasks::executeWriteScheduleTask(schedualPrefix::WednesdayLesson, hashTable, TOTAL_NUMBER_OF_COURSES);
                    func();
                });
                
                Multithreaded::ThreadPools::addExecutionTask([&hashTable](const std::function<void()> &func) {
                    Multithreaded::ThreadedTasks::executeWriteScheduleTask(schedualPrefix::ThursdayLesson, hashTable, TOTAL_NUMBER_OF_COURSES);
                    func();
                });
                
                Multithreaded::ThreadPools::addExecutionTask([&hashTable](const std::function<void()> &func) {
                    Multithreaded::ThreadedTasks::executeWriteScheduleTask(schedualPrefix::FridayLesson, hashTable, TOTAL_NUMBER_OF_COURSES);
                    func();
                });
                
                Multithreaded::ThreadPools::addExecutionTask([&hashTable](const std::function<void()> &func) {
                    Multithreaded::ThreadedTasks::executeWriteScheduleTask(schedualPrefix::SaturdayLesson, hashTable, TOTAL_NUMBER_OF_COURSES);
                    func();
                });
                
                Multithreaded::ThreadPools::addExecutionTask([&hashTable](const std::function<void()> &func) {
                    Multithreaded::ThreadedTasks::executeWriteScheduleTask(schedualPrefix::SundayLesson, hashTable, TOTAL_NUMBER_OF_COURSES);
                    func();
                });
                Multithreaded::ThreadPools::stopPool();

                for (auto& thread : threads) {
                    if (thread.joinable()) {
                        thread.join();
                    }
                }
            } else {
                std::cerr << "未提供 -f 选项和文件名称。使用 -h 获取帮助。" << std::endl;
                return EXIT_SUCCESS;
            }
        } catch (const std::exception& e) {
            std::cerr << "错误: " << e.what() << std::endl;
            return EXIT_SUCCESS;
        }
    }
    return EXIT_SUCCESS;
}


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

void Multithreaded::ThreadPools::addExecutionTask(const std::function<void(std::function<void()>)>& task) {
    {
        std::lock_guard<std::mutex> lock(taskQueueMutex);
        taskQueue.push(task);
    }
    taskQueueCV.notify_one();
}


void Multithreaded::ThreadPools::stopPool() {
    stopThreadPool = true;
    taskQueueCV.notify_all();
}
