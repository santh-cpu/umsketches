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
    # to avoid race
    mx.eval(c)
    print(f"computation complete. resultant array:{c}")


if __name__ == "__main__":
    time.sleep(1)
    testgpuactivity()
