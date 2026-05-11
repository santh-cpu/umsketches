clang -framework Metal -framework Foundation -o testrace tests/testrace.m
codesign --force --sign - --entitlements /dev/stdin testrace <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>com.apple.security.cs.disable-library-validation</key><true/>
</dict></plist>
EOF
DYLD_INSERT_LIBRARIES=./libums.dylib ./testrace
