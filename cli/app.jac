"""Command-line interface for the Day Planner."""

import argparse;
import asyncio;
import sys;

import from main {
    TaskInfo,
    CliListTasks,
    CliAddTask,
    CliCompleteTask,
    CliDeleteTask
}


glob PROG: str = "day-planner";


obj Invocation {
    has command: str = "",
        title: str = "",
        priority: str = "medium",
        due_date: str = "",
        number: int = 0;
}


def build_parser -> argparse.ArgumentParser {
    parser = argparse.ArgumentParser(
        prog=PROG,
        description="Manage your Day Planner from the terminal."
    );

    commands = parser.add_subparsers(
        dest="command",
        metavar="<command>",
        required=True
    );

    commands.add_parser(
        "list",
        help="show all tasks"
    );

    commands.add_parser(
        "pending",
        help="show only unfinished tasks"
    );

    add_parser = commands.add_parser(
        "add",
        help="add a new task"
    );

    add_parser.add_argument(
        "title",
        help="title of the task"
    );

    add_parser.add_argument(
        "--priority",
        choices=[
            "high",
            "medium",
            "low"
        ],
        `default="medium",
        help="task priority"
    );

    add_parser.add_argument(
        "--due",
        dest="due_date",
        `default="",
        help="due date in YYYY-MM-DD format"
    );

    done_parser = commands.add_parser(
        "done",
        help="mark a task complete"
    );

    done_parser.add_argument(
        "number",
        `type=int,
        help="task number shown by the list command"
    );

    delete_parser = commands.add_parser(
        "delete",
        help="delete a task"
    );

    delete_parser.add_argument(
        "number",
        `type=int,
        help="task number shown by the list command"
    );

    return parser;
}


def parse_args(argv: list[str]) -> Invocation {
    parser = build_parser();
    args = parser.parse_args(argv);

    return Invocation(
        command=str(
            getattr(args, "command", "") or ""
        ),
        title=str(
            getattr(args, "title", "") or ""
        ),
        priority=str(
            getattr(args, "priority", "medium") or "medium"
        ),
        due_date=str(
            getattr(args, "due_date", "") or ""
        ),
        number=int(
            getattr(args, "number", 0)
        )
    );
}


async def get_tasks -> list[TaskInfo] {
    response = await (
        root spawn CliListTasks()
    );

    if not response.reports {
        return [];
    }

    return response.reports[0];
}


async def list_tasks(
    only_pending: bool = False
) -> int {
    tasks: list[TaskInfo] = await get_tasks();

    if only_pending {
        tasks = [
            task
            for task in tasks
            if not task.done
        ];
    }

    if len(tasks) == 0 {
        print(
            "No pending tasks found."
            if only_pending
            else "No tasks found."
        );

        return 0;
    }

    print("");

    print(
        "PENDING TASKS"
        if only_pending
        else "DAY PLANNER TASKS"
    );

    print("=================");

    number: int = 1;

    for task in tasks {
        status: str = (
            "DONE"
            if task.done
            else "PENDING"
        );

        due: str = (
            task.due_date
            if task.due_date
            else "No due date"
        );

        print(
            str(number) +
            ". [" +
            status +
            "] " +
            task.title
        );

        print(
            "   Priority: " +
            task.priority +
            " | Category: " +
            task.category +
            " | Due: " +
            due
        );

        number += 1;
    }

    print("");

    return 0;
}


async def add_task(
    title: str,
    priority: str,
    due_date: str
) -> int {
    if not title.strip() {
        print("Task title cannot be empty.");
        return 1;
    }

    response = await (
        root spawn CliAddTask(
            title=title.strip(),
            priority=priority,
            due_date=due_date
        )
    );

    if not response.reports {
        print("The task could not be added.");
        return 1;
    }

    task: TaskInfo = response.reports[0];

    print("");
    print("Task added successfully:");
    print("  " + task.title);
    print("  Priority: " + task.priority);
    print("  Category: " + task.category);

    if task.due_date {
        print("  Due: " + task.due_date);
    }

    print("");

    return 0;
}


async def complete_task(
    number: int
) -> int {
    tasks: list[TaskInfo] = await get_tasks();

    if number < 1 or number > len(tasks) {
        print(
            "Invalid task number. Run "
            "'jac run cli -- list' to view task numbers."
        );

        return 1;
    }

    selected: TaskInfo = tasks[number - 1];

    response = await (
        root spawn CliCompleteTask(
            task_id=selected.id
        )
    );

    if not response.reports {
        print("The task could not be completed.");
        return 1;
    }

    completed: TaskInfo = response.reports[0];

    print("");
    print(
        "Completed: " +
        completed.title
    );
    print("");

    return 0;
}

async def delete_task(
    number: int
) -> int {
    tasks: list[TaskInfo] = await get_tasks();

    if number < 1 or number > len(tasks) {
        print(
            "Invalid task number. Run "
            "'jac run cli -- list' to view task numbers."
        );

        return 1;
    }

    selected: TaskInfo = tasks[number - 1];

    response = await (
        root spawn CliDeleteTask(
            task_id=selected.id
        )
    );

    if not response.reports {
        print("The task could not be deleted.");
        return 1;
    }

    deleted: TaskInfo = response.reports[0];

    print("");
    print(
        "Deleted: " +
        deleted.title
    );
    print("");

    return 0;
}


async def dispatch(
    invocation: Invocation
) -> int {
    if invocation.command == "list" {
        return await list_tasks();
    }

    if invocation.command == "pending" {
        return await list_tasks(
            only_pending=True
        );
    }

    if invocation.command == "add" {
        return await add_task(
            invocation.title,
            invocation.priority,
            invocation.due_date
        );
    }

    if invocation.command == "done" {
        return await complete_task(
            invocation.number
        );
    }

    if invocation.command == "delete" {
        return await delete_task(
            invocation.number
        );
    }

    return 1;
}


async def main(
    argv: list[str]
) -> int {
    return await dispatch(
        parse_args(argv)
    );
}


with entry:__main__ {
    sys.`exit(
        asyncio.run(
            main(sys.argv[1:])
        )
    );
}