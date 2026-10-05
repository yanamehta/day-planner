"""Monthly calendar view for planner tasks."""

import from ..main { Task }


def:pub TaskCalendar(
    tasks: list[Task],
    calendarMonth: str,
    onMonthChange: Callable[[str], None],
    onToggle: Callable[[str], None],
    onDelete: Callable[[str], None]
) -> JsxElement {
    monthNames: list[str] = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
    ];

    weekdayNames: list[str] = [
        "Sun",
        "Mon",
        "Tue",
        "Wed",
        "Thu",
        "Fri",
        "Sat"
    ];

    def isLeapYear(year: int) -> bool {
        return (
            year % 400 == 0 or
            (
                year % 4 == 0 and
                year % 100 != 0
            )
        );
    }

    def daysInMonth(year: int, month: int) -> int {
        if month in [1, 3, 5, 7, 8, 10, 12] {
            return 31;
        } elif month in [4, 6, 9, 11] {
            return 30;
        } elif isLeapYear(year) {
            return 29;
        } else {
            return 28;
        }
    }

    def firstWeekday(year: int, month: int) -> int {
        adjustedYear: int = year;
        adjustedMonth: int = month;

        if adjustedMonth < 3 {
            adjustedMonth += 12;
            adjustedYear -= 1;
        }

        yearOfCentury: int = adjustedYear % 100;
        century: int = adjustedYear // 100;

        h: int = (
            1 +
            (13 * (adjustedMonth + 1)) // 5 +
            yearOfCentury +
            yearOfCentury // 4 +
            century // 4 +
            5 * century
        ) % 7;

        return (h + 6) % 7;
    }

    def makeMonthValue(year: int, month: int) -> str {
        monthText: str = str(month);

        if month < 10 {
            monthText = "0" + monthText;
        }

        return str(year) + "-" + monthText;
    }

    def makeDateValue(
        year: int,
        month: int,
        day: int
    ) -> str {
        dayText: str = str(day);

        if day < 10 {
            dayText = "0" + dayText;
        }

        return (
            makeMonthValue(year, month) +
            "-" +
            dayText
        );
    }

    year: int = int(calendarMonth[0:4]);
    month: int = int(calendarMonth[5:7]);

    totalDays: int = daysInMonth(year, month);
    startingWeekday: int = firstWeekday(year, month);

    calendarDays: list[int] = [
        0
        for unused in range(startingWeekday)
    ];

    calendarDays = calendarDays + [
        day
        for day in range(1, totalDays + 1)
    ];

    while len(calendarDays) % 7 != 0 {
        calendarDays.append(0);
    }

    def tasksForDay(day: int) -> list[Task] {
        if day == 0 {
            return [];
        }

        dateValue: str = makeDateValue(
            year,
            month,
            day
        );

        return [
            task
            for task in tasks
            if task.due_date == dateValue
        ];
    }

    def showPreviousMonth {
        previousYear: int = year;
        previousMonth: int = month - 1;

        if previousMonth == 0 {
            previousMonth = 12;
            previousYear -= 1;
        }

        onMonthChange(
            makeMonthValue(
                previousYear,
                previousMonth
            )
        );
    }

    def showNextMonth {
        nextYear: int = year;
        nextMonth: int = month + 1;

        if nextMonth == 13 {
            nextMonth = 1;
            nextYear += 1;
        }

        onMonthChange(
            makeMonthValue(
                nextYear,
                nextMonth
            )
        );
    }

    undatedTasks: list[Task] = [
        task
        for task in tasks
        if not task.due_date
    ];

    return
        <div class="calendar-view">
            <div class="calendar-header">
                <button
                    class="calendar-nav-button"
                    onClick={showPreviousMonth}
                    title="Previous month"
                >
                    ‹
                </button>

                <h3>
                    {monthNames[month - 1]} {year}
                </h3>

                <button
                    class="calendar-nav-button"
                    onClick={showNextMonth}
                    title="Next month"
                >
                    ›
                </button>
            </div>

            <div class="calendar-weekdays">
                {[
                    <div
                        key={weekday}
                        class="calendar-weekday"
                    >
                        {weekday}
                    </div>
                    for weekday in weekdayNames
                ]}
            </div>

            <div class="calendar-grid">
                {[
                    <div
                        key={
                            "blank-" + str(index)
                            if day == 0
                            else makeDateValue(
                                year,
                                month,
                                day
                            )
                        }
                        class={
                            "calendar-day " +
                            (
                                "calendar-day-empty"
                                if day == 0
                                else ""
                            )
                        }
                    >
                        {
                            <span class="calendar-day-number">
                                {day}
                            </span>
                            if day != 0
                            else None
                        }

                        {
                            <div class="calendar-day-tasks">
                                {[
                                    <div
                                        key={jid(task)}
                                        class={
                                            "calendar-task " +
                                            "calendar-task-" +
                                            task.priority +
                                            (
                                                " calendar-task-done"
                                                if task.done
                                                else ""
                                            )
                                        }
                                    >
                                        <input
                                            type="checkbox"
                                            checked={task.done}
                                            onChange={lambda {
                                                onToggle(jid(task));
                                            }}
                                        />

                                        <span class="calendar-task-title">
                                            {task.title}
                                        </span>

                                        <button
                                            class="calendar-task-delete"
                                            onClick={lambda {
                                                onDelete(jid(task));
                                            }}
                                            title="Delete task"
                                        >
                                            ×
                                        </button>
                                    </div>
                                    for task in tasksForDay(day)
                                ]}
                            </div>
                            if day != 0
                            else None
                        }
                    </div>
                    for (index, day) in enumerate(calendarDays)
                ]}
            </div>

            {
                <div class="undated-tasks">
                    <h3>Tasks without due dates</h3>

                    <div class="undated-task-list">
                        {[
                            <div
                                key={jid(task)}
                                class={
                                    "undated-task " +
                                    "undated-task-" +
                                    task.priority
                                }
                            >
                                <input
                                    type="checkbox"
                                    checked={task.done}
                                    onChange={lambda {
                                        onToggle(jid(task));
                                    }}
                                />

                                <span class={
                                    "undated-task-title " +
                                    (
                                        "task-done"
                                        if task.done
                                        else ""
                                    )
                                }>
                                    {task.title}
                                </span>

                                <span class={
                                    "priority-badge priority-" +
                                    task.priority
                                }>
                                    {task.priority}
                                </span>

                                <button
                                    class="btn-delete"
                                    onClick={lambda {
                                        onDelete(jid(task));
                                    }}
                                >
                                    X
                                </button>
                            </div>
                            for task in undatedTasks
                        ]}
                    </div>
                </div>
                if len(undatedTasks) > 0
                else None
            }
        </div>;
}