#include <memory>
#include <utility>
#include <random>
#include <iostream>
#include <chrono>

#include "absl/strings/str_format.h"

#include "Vriscarlet.h"
#include "verilated_fst_c.h"

using std::chrono::nanoseconds;

using Module = Vriscarlet;

template<typename Rep, typename Period>
nanoseconds::rep to_ns(
    std::chrono::duration<Rep, Period> dur
) {
    return std::chrono::duration_cast<nanoseconds>(dur).count();
}

class DUT {
private:
    std::unique_ptr<Module> module;
    std::unique_ptr<VerilatedFstC> trace;
    nanoseconds clock_period;
    vluint64_t m_counter;

public:
    DUT(nanoseconds clock_period):
        module(std::make_unique<Module>()),
        trace(),
        clock_period(clock_period),
        m_counter(0) {
        module->clk = 0;
        module->rst = 1;
    }

    vluint64_t counter() {
        return m_counter;
    }

    nanoseconds time() {
        return clock_period * counter();
    }

    void open_trace(const char *filename) {
        Verilated::traceEverOn(true);
        trace = std::make_unique<VerilatedFstC>();
        module->trace(trace.get(), 0);
        trace->open(filename);
    }

    void tick() {
        const auto period = to_ns(clock_period);

        if (trace)
            trace->dump(period * m_counter);

        module->clk = 0;
        module->eval();

        if (trace)
            trace->dump(period * m_counter + period / 2);

        module->clk = 1;
        module->eval();

        m_counter ++;
    }

    void reset() {
        module->rst = 1;
        tick();
        module->rst = 0;
    }

    virtual ~DUT() {
        module->final();
    }

    Module* operator->() {
        return module.get();
    }
};

int main(int argc, char *argv[]) {
    using namespace std::chrono_literals;

    Verilated::commandArgs(argc, argv);

    auto clock_period = 1ms;
    DUT dut(clock_period);

    Verilated::mkdir("simout");
    dut.open_trace("simout/dump.fst");

    dut.reset();

    std::random_device rd;
    std::mt19937 rng(rd());
    std::uniform_int_distribution<uint32_t> dist(4, 10);

    for (size_t i = 0; i < 10; i ++) {
        uint32_t num = dist(rng);
        std::cout << absl::StreamFormat("a = %d\n", num);
        dut->a = num;
        dut.tick();
        std::cout << absl::StreamFormat("b = %d\n", dut -> b);
    }
}
