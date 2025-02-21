# GetSchedaul
By writing a Json file to write course information to the MacOS system calendar, I can sync the course information of a semester to my iPhone through iCloud, and reduce the number of times I see ads before viewing course information through third-party apps.

## 库引用说明
GetSchedual在开发过程中使用到的第三方库：
- Boost ： <boost/program_options.hpp>、 <boost/json.hpp>
- <EventKit/EventKit.h>

## 命令行描述

- 获取帮助信息：

~~~bash
GetSchedual -h
GetSchedual --hple
~~~

- 获取版本信息：

~~~bash
GetSchedual -v
GetShcedual --version
~~~

- 向日历中写入单个全天日程信息：

~~~bash
GetSchedual -t "事件标题" -s "2077-01-01 8:30"
~~~

- 向日历中写入当天时间段内的日程信息：

~~~bash
GetSchedual -t "事件标题" -s "2077-01-01 8:30" -e "2077-01-01 12:00" -l "事件地点"
~~~

- 向日历中写入按星期重复的事件：

~~~bash
GetSchedual -t "事件标题" -s "2077-01-01 8:30" -e "2077-01-01 12:00" -l "事件地点" -d 1 // 重复一周
~~~

- 通过JSON文件批量导入日程：

~~~bash
GetShcedual -f filename.json
Getschedual --file filename.json
~~~

## JSON文件编写约定

~~~json
{
  "Monday" :{
    "first" :["计算机科学与技术","2077-01-01 08:30","2077-01-01 10:05", "第一教学楼", 8],
    "second":["土木工程","2077-01-01 08:30","2077-01-01 10:05", "第一教学楼",null]
  },
  
  "Monday" :{
    "first" :[],
    "second":[],
    ... ...
  }
}
~~~

一个对象中可以包含多个数组，每个数组可以包含多个元素。对象名称、数组名称可以是任意的字母组合。在你编写JSON中，不要出现嵌套对象、嵌套数组的情况。
