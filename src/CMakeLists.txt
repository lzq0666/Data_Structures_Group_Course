# 查找当前目录下的所有源文件
aux_source_directory(. SRC_LIST)

# 添加 include 目录
include_directories(${PROJECT_SOURCE_DIR}/include)

# 添加 Qt6 的模块
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick)

# 添加资源文件
set(RESOURCES ${PROJECT_SOURCE_DIR}/resources.qrc)

# 定义可执行文件
add_executable(main ${SRC_LIST} ${RESOURCES})

# 链接 Qt6 库
target_link_libraries(main
	Qt6::Core
	Qt6::Quick
	Qt6::Qml
)

# 设置输出路径
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/bin)
