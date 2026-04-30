import mlx.core as mx
import time
import threading
import numpy


def testgpuactivity():
    print("start gpu operation..")
    s = 8192
    a = mx.random.normal((s, s))
    b = mx.random.normal((s, s))

    c = mx.matmul(a, b)

    # dispatch to gpu
    mx.eval(c)

    # race attempt
    # data tryna process while c is called in print
    data = numpy.array(c)
    print(f"computation complete. resultant array:{c}")


if __name__ == "__main__":
    time.sleep(1)
    testgpuactivity()
