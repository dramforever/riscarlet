cmake_minimum_required(VERSION 3.18.0)

project(riscarlet)
find_package(verilator HINTS $ENV{VERILATOR_ROOT})
find_package(absl REQUIRED)

add_executable(Vriscarlet sim/riscarlet.cpp)

verilate(Vriscarlet
    TOP_MODULE riscarlet
    PREFIX Vriscarlet
    SOURCES rtl/common/types.sv rtl/riscarlet.sv
    TRACE_FST
    VERILATOR_ARGS --trace-params --trace-structs -Wall)

target_link_libraries(Vriscarlet PRIVATE absl::strings absl::str_format)

add_executable(Vmultiply sim/multiply.cpp)

verilate(Vmultiply
    TOP_MODULE multiply
    PREFIX Vmultiply
    SOURCES rtl/prim/multiply.sv
    TRACE_FST
    VERILATOR_ARGS --trace-params --trace-structs -Wall -O3)

target_link_libraries(Vmultiply PRIVATE absl::strings absl::str_format)
