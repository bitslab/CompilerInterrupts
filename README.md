# Compiler Interrupts

Compiler Interrupts are instrumentation-based and light-weight, allowing frequent interrupts with little performance impact. Compiler Interrupts instead enable efficient, automatic high-rate polling on a shared thread, which performs other work between polls.

This repository contains source code for Compiler Interrupts framework, its C API, examples and benchmarks. Check out the [white paper](https://dl.acm.org/doi/10.1145/3453483.3454107) for more info.

[Rust API](https://github.com/bitslab/compiler-interrupts-rs) is available. [`cargo-compiler-interrupts`](https://github.com/bitslab/cargo-compiler-interrupts) subcommand is also available for enabling seamless Compiler Interrupts integration to any Rust packages.

## Requirements

* [LLVM](https://releases.llvm.org/) 9 or later is required. You can check the LLVM version by running `llvm-config --version`.
* Linux system is required for running the benchmarks.

## Build

```sh
cd src
make
cd ../lib  # compiled artifacts are exported to `lib` directory
```

Compiler Interrupts framework (`CompilerInterrupt.so`) and its C API library (`libci.a` and `libci.so`) are exported to the `lib` directory.

## Examples

* Build and run the example:

```sh
cd example
make
./orig_demo           # original binary
./ci_llvm_demo        # CI-integrated binary
./ci_mult_files       # compiled using multiple source files
./ci_modularity_demo  # compiled using a CI-instrumented library
```

* `gcc_demo` is the original, unmodified binary. It simply spawns multiple threads to print out a thread-local counter. Check out the [`demo.c`](example/demo.c) source code for more info.
* `ci_llvm_demo` is the same as `gcc_demo`, except that it has been integrated with Compiler Interrupts. You should expect to see *a lot* of `CI: last interval = {} IR` besides ordinary counter prints. These CI prints are from `interrupt_handler` function, which is called by the Compiler Interrupts every 1000 instructions.
* `ci_mult_files` and `ci_modularity_demo` demonstrate the modularity and flexibility when integrating the Compiler Interrupts for your program. Check out the [`Makefile`](example/Makefile) for more info.

## Usage

### Register the handler

```c
#include "ci_lib.h"

void interrupt_handler(long ic) {
  static __thread long previous_ic = 0;
  printf("CI: last interval = %ld IR\n", ic - previous_ic);
  previous_ic = ic;
}

int main() {
  register_ci(1000, 1000, interrupt_handler);
  // your code
}
```

* Define a new function to handle Compiler Interrupts. The function should take one `long` integer as the parameter. Cumulative instruction count is provided through that parameter.
* Call `register_ci` with an IR interval, cycles interval and the just-defined handler.
* All Compiler Interrupts APIs are thread-specific, meaning other threads would not be interrupted if you register the handler in the main thread and vice versa. Check out the [API documentation](#api) below.

### Compilation

```sh
CI_ROOT=$(pwd) # assume we are in the root folder of the repository
gcc -S -emit-llvm -I$(CI_ROOT)/src main.c -L$(CI_ROOT)/lib -Wl,-rpath,$(CI_ROOT)/lib -o main.ll -lci # 1
opt -S -postdomtree -mem2reg -indvars -loop-simplify -branch-prob -scalar-evolution < main.ll > opt_main.ll # 2
opt -S -load CompilerInterrupt.so -logicalclock -inst-gran=2 -commit-intv=100 -all-dev=100 < opt_main.ll > ci_main.ll # 3
gcc ci_main.ll -o ci_main # 4
```

* Link the API library and emit the LLVM IR from your code.
* Run `opt` with given built-in pass for overhead optimization.
* Run `opt` with the Compiler Interrupts framework. `-logicalclock` must be provided, followed by the arguments for the framework.
* Compile the LLVM IR generated from `opt`. You will now have the binary with Compiler Interrupts integrated.

## Documentation

### API

Compiler Interrupts C API are defined in [`src/ci_lib.h`](src/ci_lib.h). All APIs are thread-specific, meaning other threads would not be interrupted if you register the handler in the main thread and vice versa.

| Function                                        | Description                                                                   |
| ----------------------------------------------- | ----------------------------------------------------------------------------- |
| `void register_ci(int, int, ci_handler)`        | Registers the Compiler Interrupts handler with given IR and cycles interval   |
| `void deregister_ci(void)`                      | De-registers the Compiler Interrupts handler                                  |
| `void register_ci_disable_hook(ci_margin_hook)` | Registers a function to be called just before Compiler Interrupts is disabled |
| `void register_ci_enable_hook(ci_margin_hook)`  | Registers a function to be called just after Compiler Interrupts is enabled   |
| `void ci_disable(void)`                         | Disables Compiler Interrupts                                                  |
| `void ci_enable(void)`                          | Enables Compiler Interrupts                                                   |
| `void instr_disable(void)`                      | Disables probe instrumentation                                                |
| `void instr_enable(void)`                       | Enables probe instrumentation                                                 |

[Rust API](https://github.com/bitslab/compiler-interrupts-rs) is also available for Rust programs.

### Framework configuration

* Compiler Interrupts leverages LLVM's analysis and transformation pass backend. Compiler Interrupts can be configured during the optimization stage. `-logicalclock` must be provided, followed by the arguments for the framework.

| Argument <img width=0/> | Type    | Description                                                                                                                                                                                                                 |
| ----------------------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `inst-gran`             | Integer | Select instrumentation granularity <br/> 0: Per instruction <br/> 1: Optimized instrumentation <br/> 2: Optimized instrumentation with statistics collection <br/> 3: Per basic block <br/> 4: Per function                 |
| `config`                | Integer | Select configuration type <br/> 0: Single-threaded thread-local logical clock <br/> 1: Single-threaded passed logical clock <br/> 2: Multi-threaded thread-local logical clock <br/> 3: Multi-threaded passed logical clock |
| `defclock`              | Boolean | Choose whether to define clock in the pass                                                                                                                                                                                  |
| `clock-type`            | Integer | Choose clock type <br/> 0: Predictive <br/> 1: Instantaneous                                                                                                                                                                |
| `mem-ops-cost`          | Integer | Interval in terms of number of instruction cost for pushing to global logical clock                                                                                                                                         |
| `target-cycles`         | Integer | Target interval in cycles                                                                                                                                                                                                   |
| `commit-intv`           | Integer | Interval in terms of number of instruction cost for committing to local counter                                                                                                                                             |
| `all-dev`               | Integer | Deviation allowed for branch costs for averaging                                                                                                                                                                            |
| `config-file`           | String  | Configuration file path for the classes and cost of instructions                                                                                                                                                            |
| `in-cost-file`          | String  | Cost file from where cost of library functions will be imported                                                                                                                                                             |
| `out-cost-file`         | String  | Cost file where cost of library functions will be exported                                                                                                                                                                  |

## Benchmarks

### Setup the environment

```sh
cd src
chmod +x ./setup.sh
sudo ./setup.sh
```

Linux system is required for running the benchmarks. The setup script will change some system settings and create some directories. You should always carefully examine the source code before running anything with `sudo`.

### List of benchmarks

* MTCP benchmarks ([benchmarks/mtcp](benchmarks/mtcp)).
* Shenango benchmarks ([benchmarks/shenango](benchmarks/shenango), [benchmarks/cpuminer-multi](benchmarks/cpuminer-multi)).
* Server delegation benchmarks ([benchmarks/server_delegation](benchmarks/server_delegation)).
* Accuracy and Overhead benchmarks ([benchmarks/accuracy_and_overhead](benchmarks/accuracy_and_overhead)).

Check out the [white paper](https://dl.acm.org/doi/10.1145/3453483.3454107) for more info about benchmarks.

## Contact

For assistance in understanding and/or using the Compiler Interrupts framework, please send an email to nbasu4@uic.edu. All issue reports and pull requests are welcomed and much appreciated.

## License

`CompilerInterrupts` is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
