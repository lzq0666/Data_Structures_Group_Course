cmake_minimum_required(VERSION 3.31)

project(Data_Structures_Group_Course)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 查找 Qt6 包
find_package(Qt6 REQUIRED COMPONENTS Core Quick)

add_subdirectory(src ./build)
