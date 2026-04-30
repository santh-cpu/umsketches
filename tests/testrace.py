import mlx.core as mx
import time
import threading


def testgpuactivity():
    print("start gpu operation..")
    s = 8192
    a = mx.random.normal((s, s))
    b = mx.random.normal((s, s))

    c = mx.matmul(a, b)

    # dispatch to gpu
    mx.eval(c)

    # INTENTIONAL RACE CONDITION
    # By converting to numpy immediately without a synchronization barrier,
    # we force the CPU to call `contents` on the underlying Metal buffer
    # while the GPU is still processing the matmul.
    print(f"computation complete. resultant array:{c}")


if __name__ == "__main__":
    time.sleep(1)
    testgpuactivity()
