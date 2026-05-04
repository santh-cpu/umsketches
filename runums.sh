make
echo "---proper py script with mx.evall()---"
DYLD_INSERT_LIBRARIES=./libums.dylib python3 tests/testbaseline.py
echo "---induced race---"
DYLD_INSERT_LIBRARIES=./libums.dylib python3 tests/testrace.py
