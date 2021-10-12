import pytest


# content of test_sample.py
def testcase_1(cmdopt="type1"):
    if cmdopt == "type1":
        for i in range(0, 10):
            print(f"testcase_1 {i}")
    elif cmdopt == "type2":
        print("second")
    assert 0  # to see what was printed


def testcase_2():
    for i in range(0, 10):
        print(f"testcase_2 {i}")
    assert 0 == 0  # to see what was printed


def testcase_3():
    assert 1 == 1  # to see what was printed


@pytest.mark.xfail
def testcase_4():
    assert 2 == 1  # to see what was printed


@pytest.mark.skip(reason="no way of currently testing this")
def testcase_5():
    assert 1 == 1  # to see what was printed


def testcase_6():
    assert 2 == 2  # to see what was printed


def testcase_7():
    assert 1 == 1  # to see what was printed


def testcase_8():
    assert 2 == 2  # to see what was printed
