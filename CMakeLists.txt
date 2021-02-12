cmake_minimum_required(VERSION 3.18.0)

project(riscarlet)
find_package(verilator HINTS $ENV{VERILATOR_ROOT})
find_package(absl REQUIRED)

add_executable(Vriscarlet sim/riscarlet.cpp)
set(verilate_args
    INCLUDE_DIRS rtl
    TRACE_FST
    VERILATOR_ARGS --trace-params --trace-structs -Wall -O3)

verilate(Vriscarlet
    TOP_MODULE riscarlet
    PREFIX Vriscarlet
    SOURCES rtl/top/riscarlet.sv
    ${verilate_args})

target_link_libraries(Vriscarlet PRIVATE absl::strings absl::str_format)

add_executable(Vmultiply sim/multiply.cpp)

verilate(Vmultiply
    TOP_MODULE multiply
    PREFIX Vmultiply
    SOURCES rtl/top/multiply.sv
    ${verilate_args})

target_link_libraries(Vmultiply PRIVATE absl::strings absl::str_format)
