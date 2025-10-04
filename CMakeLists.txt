#定义 CMake 最低版本要求
cmake_minimum_required(VERSION 3.31)

#设置项目名称
project(Data_Structures_Group_Course)

#设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#查找 Qt6 依赖包
find_package(Qt6 REQUIRED COMPONENTS Core Quick Qml)

#委托给子目录处理具体构建
add_subdirectory(src ./build)

