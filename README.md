# Unified Memory Validator

output:
from testrace.m:
(race successfully detected)
````
testrace: replacing existing signature
2026-05-11 16:05:59.590 testrace[71748:12203651] [testrace] buf class: AGXG16GFamilyBuffer
2026-05-11 16:05:59.591 testrace[71748:12203651] [testrace] contents IMP: 0x100611adc
2026-05-11 16:05:59.592 testrace[71748:12203651] [testrace] calling contents immediately after commit...
2026-05-11 16:05:59.592 testrace[71748:12203651] [UMS fatality] cpu accessed [MLTBuffer contents] during active gpu dispatch
2026-05-11 16:05:59.592 testrace[71748:12203651] stack trace:
2026-05-11 16:05:59.592 testrace[71748:12203651] 0   libums.dylib                        0x0000000100611b50 _Z14swizzlecontentPU19objcproto9MTLBuffer11objc_objectP13objc_selector + 116
2026-05-11 16:05:59.592 testrace[71748:12203651] 1   testrace                            0x00000001005d4914 main + 452
2026-05-11 16:05:59.592 testrace[71748:12203651] 2   dyld                                0x0000000199d2ab98 start + 6076
./runumc.sh: line 9: 71748 Abort trap: 6           DYLD_INSERT_LIBRARIES=./libums.dylib ./testrace

````

from py scripts:
(newer script - no race detected)
TODO: mlx support through lower level metal interception
````
---proper py script with mx.evall()---
start gpu operation..
computation complete. resultant array:array([[-54.7143, -26.1499, 53.471, ..., 21.666, 6.81271, 120.652],
       [-58.631, 4.40588, 24.1577, ..., -7.15809, 71.2136, -112.784],
       [-56.7201, -124.481, -156.274, ..., -22.2116, -31.5946, 150.303],
       ...,
       [93.7647, -17.8024, 15.948, ..., -128.688, -17.4615, -35.0316],
       [-55.025, 0.906375, 93.78, ..., -174.415, 61.4542, -44.6405],
       [29.0302, -90.6748, -102.484, ..., 32.0464, -179.402, -85.615]], dtype=float32)
---induced race---
start gpu operation..
computation complete. resultant array:array([[79.6953, 2.33769, -98.2214, ..., 51.2322, -112.37, 85.7234],
       [200.587, -188.82, -40.0613, ..., -50.795, 230.418, -16.4893],
       [-18.4494, -147.718, -182.5, ..., -144.944, -144.564, -6.46491],
       ...,
       [-119.765, -194.182, 35.8522, ..., -90.6924, -130.678, 98.4849],
       [-70.3611, 9.92761, 83.427, ..., -82.7318, 134.201, 41.0984],
       [89.6521, 31.6552, -155.718, ..., -75.974, 36.2008, 46.3831]], dtype=float32)
````

(older script - race detected)
````
strap on ums
gateway armed
strap on ums
gateway armed
start gpu operation..
[UMS Lock Table] added    0x12ff9cde0
[UMS Lock Table] added    0x12ffaaf10
[UMS Lock Table] added    0x12ffab840
[UMS Lock Table] added    0x12ffad300
[UMS Lock Table] added    0x12ffae400
[UMS Lock Table] added    0x12ffafd50
[UMS Lock Table] added    0x12ffb1960
[UMS Lock Table] added    0x12ffb2f40
[UMS Lock Table] added    0x12ffb3c20
[UMS Lock Table] added    0x12ffb51c0
[UMS Lock Table] added    0x12ffb6160
[UMS Lock Table] added    0x12ffb7a60
[UMS Lock Table] released 0x12ff9cde0
[UMS Lock Table] added    0x12ffb8480
[UMS Lock Table] added    0x12ff9cde0
[UMS Lock Table] released 0x12ffaaf10
[UMS Lock Table] added    0x12ffb9330
[UMS Lock Table] added    0x108004c70
[UMS Lock Table] released 0x12ffab840
[UMS Lock Table] added    0x1080050b0
[UMS Lock Table] added    0x106134440
[UMS Lock Table] released 0x12ffad300
[UMS Lock Table] added    0x106134790
[UMS Lock Table] added    0x131005530
[UMS Lock Table] released 0x12ffae400
[UMS Lock Table] added    0x1310067f0
[UMS Lock Table] added    0x131006ee0
[UMS Lock Table] released 0x12ffafd50
[UMS Lock Table] added    0x131007230
[UMS Lock Table] added    0x1080059e0
[UMS Lock Table] released 0x12ffb1960
[UMS Lock Table] added    0x108006500
[UMS Lock Table] released 0x12ffb2f40
[UMS Lock Table] released 0x12ffb3c20
[UMS Lock Table] released 0x12ffb51c0
[UMS Lock Table] released 0x12ffb6160
[UMS Lock Table] released 0x12ffb7a60
[UMS Lock Table] released 0x12ffb8480
[UMS Lock Table] released 0x12ff9cde0
[UMS Lock Table] released 0x12ffb9330
[UMS Lock Table] released 0x108004c70
[UMS Lock Table] released 0x1080050b0
[UMS Lock Table] released 0x106134440
[UMS Lock Table] released 0x106134790
[UMS Lock Table] released 0x131005530
[UMS Lock Table] released 0x1310067f0
[UMS Lock Table] released 0x131006ee0
[UMS Lock Table] released 0x131007230
[UMS Lock Table] released 0x1080059e0
[UMS Lock Table] released 0x108006500
2026-04-30 16:03:27.015 Python[20464:9232789] [UMS fatality] cpu accessed [MLTBuffer contents] during active gpu dispatch
2026-04-30 16:03:27.015 Python[20464:9232789] stack trace:
2026-04-30 16:03:27.017 Python[20464:9232789] 0   libums.dylib                        0x0000000100048f14 _Z14swizzlecontentPU19objcproto9MTLBuffer11objc_objectP13objc_selector + 104
2026-04-30 16:03:27.017 Python[20464:9232789] 1   core.cpython-314-darwin.so          0x00000001047a9f44 _ZNK3mlx4core5array5dtypeEv + 33704
2026-04-30 16:03:27.017 Python[20464:9232789] 2   Python                              0x0000000100783228 _PyManagedBuffer_FromObject + 236
2026-04-30 16:03:27.017 Python[20464:9232789] 3   Python                              0x0000000100781870 PyMemoryView_FromObjectAndFlags + 64
2026-04-30 16:03:27.017 Python[20464:9232789] 4   _multiarray_umath.cpython-314-darwi 0x00000001056c7e20 _array_from_array_like + 164
2026-04-30 16:03:27.017 Python[20464:9232789] 5   _multiarray_umath.cpython-314-darwi 0x00000001056b19f4 PyArray_DiscoverDTypeAndShape_Recursive + 604
2026-04-30 16:03:27.017 Python[20464:9232789] 6   _multiarray_umath.cpython-314-darwi 0x00000001056b2168 PyArray_DiscoverDTypeAndShape + 204
2026-04-30 16:03:27.017 Python[20464:9232789] 7   _multiarray_umath.cpython-314-darwi 0x00000001056c9074 PyArray_FromAny_int + 232
2026-04-30 16:03:27.017 Python[20464:9232789] 8   _multiarray_umath.cpython-314-darwi 0x00000001056c9930 PyArray_CheckFromAny_int + 256
2026-04-30 16:03:27.017 Python[20464:9232789] 9   _multiarray_umath.cpython-314-darwi 0x000000010570972c _array_fromobject_generic + 540
2026-04-30 16:03:27.017 Python[20464:9232789] 10  _multiarray_umath.cpython-314-darwi 0x000000010570470c array_array + 520
2026-04-30 16:03:27.017 Python[20464:9232789] 11  Python                              0x000000010071fb90 PyObject_Vectorcall + 88
2026-04-30 16:03:27.017 Python[20464:9232789] 12  Python                              0x0000000100855238 _PyEval_EvalFrameDefault + 23088
2026-04-30 16:03:27.017 Python[20464:9232789] 13  Python                              0x000000010084f2cc PyEval_EvalCode + 248
2026-04-30 16:03:27.017 Python[20464:9232789] 14  Python                              0x00000001008c7314 run_mod + 172
2026-04-30 16:03:27.017 Python[20464:9232789] 15  Python                              0x00000001008c5c78 pyrun_file + 164
2026-04-30 16:03:27.017 Python[20464:9232789] 16  Python                              0x00000001008c51fc _PyRun_SimpleFileObject + 256
2026-04-30 16:03:27.017 Python[20464:9232789] 17  Python                              0x00000001008c4e60 _PyRun_AnyFileObject + 80
2026-04-30 16:03:27.017 Python[20464:9232789] 18  Python                              0x00000001008f3754 pymain_run_file_obj + 164
2026-04-30 16:03:27.017 Python[20464:9232789] 19  Python                              0x00000001008f34a4 pymain_run_file + 72
2026-04-30 16:03:27.017 Python[20464:9232789] 20  Python                              0x00000001008f2c94 Py_RunMain + 1048
2026-04-30 16:03:27.017 Python[20464:9232789] 21  Python                              0x00000001008f3004 pymain_main + 232
2026-04-30 16:03:27.017 Python[20464:9232789] 22  Python                              0x00000001008f30a0 Py_BytesMain + 40
2026-04-30 16:03:27.017 Python[20464:9232789] 23  dyld                                0x0000000199d2ab98 start + 6076
computation complete. resultant array:array([[25.6231, -44.0791, 6.23988, ..., -183.672, -49.6303, 27.1978],
       [120.68, 22.6837, -45.2873, ..., -26.4405, -30.216, -150.041],
       [57.199, 6.57581, 27.9803, ..., 22.9866, -127.699, 113.646],
       ...,
       [-57.4797, -42.0422, 35.4272, ..., -39.0963, 122.448, -192.664],
       [8.22683, 105.245, 123.24, ..., -166.942, 68.5776, -38.6965],
       [197.112, -282.3, 11.6285, ..., 52.8088, -51.9419, 60.6934]], dtype=float32)
[UMS Lock Table] added    0x12ffaaf10
[UMS Lock Table] released 0x12ffaaf10
````
