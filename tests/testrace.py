import mlx.core as mx
import time
import threading


def testgpuactivity():
    print("start gpu operation..")
    s = 8192
    a = mx.random.normal((s, s))
    b = mx.random.normal((s, s))

    c = mx.matmul(a, b)

    # race attempt
    # no mx.eval
    print(f"computation complete. resultant array:{c}")


if __name__ == "__main__":
    time.sleep(1)
    testgpuactivity()
