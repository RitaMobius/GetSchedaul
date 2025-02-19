/**
 *
 *@file features.hpp    定features.mm文件中定义的函数。
 *@Date 创建时间2025/2/17    最后修改时间2025/2/18
 *
 *@author Dengjizhang  catrinadk@outlook.com
 *
 *@brief GetSchedual通过线程池的方式向系统日历写入日程信息的方法。
 */

#ifndef FEATURES_H
#define FEATURES_H

#include <string>
#include <array>
#include "someDef.hpp"

namespace Multithreaded {

class ThreadPools {
public:
    ThreadPools() = default;
    virtual ~ThreadPools() = default;
    /**@brief ThreadPools类的静态方法，创建工作线程。**/
    static void schedualWorkerThread();
    
    /**@brief ThreadPools类的静态方法。**/
    static void stopPool();
    
    /**@brief 向线程中添加任务。**/
    static void addExecutionTask(const std::function<void(std::function<void()>)>& task);
};

}  // namespace Multithreaded

#endif //FEATURES_H
