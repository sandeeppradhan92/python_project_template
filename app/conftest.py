# file used to cahnge pytest-html config

from datetime import datetime

from py.xml import html


def pytest_html_report_title(report):
    """modifying the title  of html report"""
    report.title = "Test report (Auto Generated PyTest)"


def pytest_html_results_table_row(report, cells):
    """orienting the data gotten from  pytest_runtest_makereport
    and sending it as row to the result"""
    del cells[1]
    try:
        tag = report.tag
    except AttributeError:
        tag = ""
    try:
        testcase = report.testcase
    except AttributeError:
        testcase = ""
    cells.insert(0, html.td(datetime.utcnow(), class_="col-time"))
    cells.insert(1, html.td(tag))
    cells.insert(2, html.td(testcase))
    # cells.pop()


def pytest_html_results_table_header(cells):
    """meta programming to modify header of the result"""

    # removing old table headers
    del cells[1]
    # adding new headers
    cells.insert(0, html.th("Time", class_="sortable time", col="time"))
    cells.insert(1, html.th("Tag"))
    cells.insert(2, html.th("Testcase"))
    # cells.pop()
