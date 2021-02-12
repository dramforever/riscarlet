#include <memory>
#include <utility>
#include <random>
#include <iostream>
#include <chrono>
#include <deque>

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
        tick();
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
    std::uniform_int_distribution<unsigned> bool_dist(0, 1);
    std::uniform_int_distribution<unsigned> num_dist(0, 1<<20);
    std::uniform_int_distribution<unsigned> ready_dist(0, 20);

    std::deque<IData> reqs;

    for (size_t i = 0; i < 100; i ++) {
        dut->ready = ready_dist(rng) < 5;
        dut->stall = bool_dist(rng);

        if (ready_dist(rng) < 1) {
            dut->pc_flush = 1;
            dut->ready = 1;
            dut->pc_new = num_dist(rng);
            std::cout << absl::StreamFormat("[%9d] !! Flush! %08x\n", dut.counter(), dut->pc_new);
        } else {
            dut->pc_flush = 0;
        }

        dut->eval();

        if (dut->ready && dut->valid) {
            if (dut->pc_flush)
                std::cout << absl::StreamFormat("[%9d] == Flush discard  %08x\n", dut.counter(), dut->instr);
            else
                std::cout << absl::StreamFormat("[%9d] == Fetch accepted %08x\n", dut.counter(), dut->instr);
        }

        if (dut->stb && ! dut->stall) {
            std::cout << absl::StreamFormat("[%9d] -> Req adr = %08x\n", dut.counter(), dut->adr);
            reqs.push_back(dut->adr);
        }

        if (! reqs.empty() && bool_dist(rng)) {
            dut->ack = 1;
            dut->dat_r = num_dist(rng);
            std::cout << absl::StreamFormat("[%9d] <- Ack dat_r = %08x (adr %08x)\n", dut.counter(), dut->dat_r, reqs.front());
            reqs.pop_front();
        } else {
            dut->ack = 0;
            dut->dat_r = 0;
        }

        // std::cout << absl::StreamFormat("[%9d]    outstanding = %d\n", dut.counter(), outstanding);

        dut.tick();
    }
}
