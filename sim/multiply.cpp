#include <memory>
#include <utility>
#include <random>
#include <iostream>
#include <chrono>
#include <limits>

#include "absl/strings/str_format.h"

#include "Vmultiply.h"
#include "verilated_fst_c.h"

using std::chrono::nanoseconds;

using Module = Vmultiply;

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
    dut.open_trace("simout/multiply.fst");

    dut.reset();

    std::random_device rd;
    std::mt19937 rng(rd());
    std::uniform_int_distribution<int32_t> dist(
        std::numeric_limits<int32_t>::min(),
        std::numeric_limits<int32_t>::max()
    );

    std::uniform_int_distribution<uint32_t> udist(
        std::numeric_limits<uint32_t>::min(),
        std::numeric_limits<uint32_t>::max()
    );

    std::uniform_int_distribution<int> bdist(0, 1);


    for (size_t T = 0; T < 20; T ++) {
        dut->is_signed = bdist(rng);
        dut->stb = 1;

        if (dut->is_signed) {
            int32_t a = dist(rng), b = dist(rng);
            dut->a = a;
            dut->b = b;
        } else {
            uint32_t a = udist(rng), b = udist(rng);
            dut->a = a;
            dut->b = b;
        }

        while (true) {
            dut.tick();
            dut->stb = 0;
            if (dut->ack) {
                if (dut->is_signed) {
                    int64_t correct = int64_t(int32_t(dut->a)) * int64_t(int32_t(dut->b));

                    std::cout << absl::StreamFormat(
                        "[%9d]   signed [%8s] %d * %d = %d (correct is %d)\n",
                        dut.counter(),
                        (int64_t(dut->o) == correct ? "OK" : "NOT OK"),
                        dut->a, dut->b, int64_t(dut->o), correct
                    );
                } else {
                    uint64_t correct = uint64_t(dut->a) * uint64_t(dut->b);

                    std::cout << absl::StreamFormat(
                        "[%9d] unsigned [%8s] %d * %d = %d (correct is %d)\n",
                        dut.counter(),
                        (uint64_t(dut->o) == correct ? "OK" : "NOT OK"),
                        dut->a, dut->b, uint64_t(dut->o), correct
                    );
                }
                break;
            }
        }
    }
}
