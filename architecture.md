unifiedMemoryValidator/
├── Makefile                 # Core build script (clang++ flags, dynamic linking)
├── run_umv.sh               # Execution wrapper (injects DYLD_INSERT_LIBRARIES)
├── README.md                # The "Pitch" (Methodology, graphs, instructions)
├── architecture.md
│
├── src/                     # The Bare-Metal Codebase
│   ├── injector/            # LAYER 1: The Gateway (Minimal Objective-C++)
│   │   ├── hook.mm          # Metal method swizzling (commit, on_complete)
│   │   └── trampoline.hpp   # C++ interface to pass Obj-C pointers safely
│   │
│   ├── core/                # LAYER 2: The Engine (Pure C++17/20)
│   │   ├── validator.cpp    # Main orchestration singleton
│   │   ├── validator.hpp
│   │   ├── shadow_table.cpp # Memory tracker (maps void* to Lock State)
│   │   └── shadow_table.hpp 
│   │
│   └── utils/               # LAYER 3: Tooling
│       └── logger.hpp       # ANSI-colored terminal output for Neovim/CLI
│
└── tests/                   # LAYER 4: The Proof (Python/MLX)
    ├── test_race.py         # Intentionally triggers UMA data corruption
    └── test_baseline.py     # Clean MLX execution for control data
