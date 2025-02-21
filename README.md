# GetSchedaul

By writing a Json file to write course information to the MacOS system calendar, I can sync the course information of a semester to my iPhone through iCloud, and reduce the number of times I see ads before viewing course information through third-party apps.

@author Dengjizhang  catrinadk@outlook.com

## 库引用说明

GetSchedual在开发过程中使用到的第三方库：

- Boost ： <boost/program_options.hpp>、 <boost/json.hpp>
- MacOS 15.1 SDK ：<EventKit/EventKit.h>

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
    "first" :["计算机科学与技术","2077-01-01 08:30","2077-01-01 10:05", "第一教学楼", “8”],
    "second":["土木工程","2077-01-01 08:30","2077-01-01 10:05", "第一教学楼",null]
  },
  
  "Tuesday" :{
    "first" :["电力电子技术","2077-01-01 08:30","2077-01-01 10:05","第一教楼"，"3-4,8-9"],
    "second":[],
    ... ...
  }
}
~~~

一个对象中可以包含多个数组，每个数组可以包含多个元素。对象名称、数组名称可以是任意的字母组合。但是在你编写JSON中，不要出现嵌套对象、嵌套数组的情况。对象之间不能重名，对象内的数组不能重名。每一个JSON对象的数组中接受4个元素，依次为日程的标题、日程的开始时间、日程的结束时间、日程的发生地址、日程的周期。如果JSON对象中的数组元素个数超过4个元素，哪个超过的部分将会被忽略。

~~~json
"first" :["计算机科学与技术","2077-01-01 08:30","2077-01-01 10:05", "第一教学楼", "8"]
~~~

如上述所示，如果通过这样的方式配置JSON文件，那么GetSchedual会设置日程的标题为`计算机科学与技术`，日程的开始时间为`2077-01-01 08:30`，日程的结束时间为`2077-01-01 10:05`，日程的发生地`第一教学楼`。这里的8代表从当前日期开始，此事件会每周重复一次，重复8次。注意，这里的8是字符串`"8"`。

如果你想通过配置JSON的方式配置一个全天的日程，那么你的JSON文件中应该存在这样的语句：

~~~json
"first" :["计算机科学与技术","2077-01-01 08:30",null, "第一教学楼", "8"]
~~~

这个语句会将日程从当前开始重复8周。请注意，第一个元素和第二个元素是必须填写的。

如果你不希望日程重复，且不设置日程的发生地，那么在地址和重复数处用`null`替代：

~~~json
"first" :["计算机科学与技术","2077-01-01 08:30",null, null, null]
~~~

在实际应用中这样配置日程信息特别麻烦，这款工具的开发最初想法是便捷地向系统默认日历中添加课程信息。但是，你会发现实际上教务系统的课程信息通过这种方式配置非常复杂。例如，电气工程专业英语开设在第3周到第9周，同样的在第11周到第16周也有这节课。针对这样的方式，GetSchedual提供了另一种配置JSON文件的办法：

~~~json
"first" :["计算机科学与技术","2077-01-01 08:30","2077-01-01 10:05", "第一教学楼", "3-9,11-16"]
~~~

这里的`2077-01-01`表示本学期的第一周，该课程位于星期几。`08:30`和`10:05`代表这节课的上课时间和下课时间，`"3-9"`表示改课程在第三周到第九周发生，依次类推。你可以定义多个类似的字符串`"3-4,8-10,12-15,……"`来定义日程的多个间隔时间段。

