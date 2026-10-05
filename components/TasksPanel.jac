"""Tasks column -- owns task state and spawns walkers."""

import from ..main {
    Task,
    AddTask,
    ListTasks,
    ToggleTask,
    DeleteTask
}

import from .TaskItem { TaskItem }
import from .TaskCalendar { TaskCalendar }


def:pub TasksPanel -> JsxElement {
    has tasks: list[Task] = [],
        taskText: str = "",
        selectedPriority: str = "medium",
        dueDate: str = "",
        sortMode: str = "default",
        viewMode: str = "list",
        calendarMonth: str = "2026-09",
        tasksLoading: bool = True;

    async can with entry {
        result = root spawn ListTasks();

        tasks = (
            result.reports[0]
            if result.reports
            else []
        );

        for loadedTask in tasks {
            if loadedTask.due_date {
                calendarMonth = loadedTask.due_date[0:7];
                break;
            }
        }

        tasksLoading = False;
    }

    async def addTask {
        if not taskText.strip() {
            return;
        }

        response = root spawn AddTask(
            title=taskText.strip(),
            priority=selectedPriority,
            due_date=dueDate
        );

        if response.reports {
            tasks = tasks + [response.reports[0]];

            if dueDate {
                calendarMonth = dueDate[0:7];
            }

            taskText = "";
            selectedPriority = "medium";
            dueDate = "";
        }
    }

    async def toggleTask(id: str) {
        response = root spawn ToggleTask(
            task_id=id
        );

        if response.reports {
            updated = response.reports[0];

            tasks = [
                updated if jid(task) == id else task
                for task in tasks
            ];
        }
    }

    async def deleteTask(id: str) {
        root spawn DeleteTask(
            task_id=id
        );

        tasks = [
            task
            for task in tasks
            if jid(task) != id
        ];
    }

    def handleKeyPress(e: KeyboardEvent) {
        if e.key == "Enter" {
            addTask();
        }
    }

    def priorityRank(priority: str) -> int {
        if priority == "high" {
            return 0;
        } elif priority == "medium" {
            return 1;
        } else {
            return 2;
        }
    }

    remaining: int = len([
        task
        for task in tasks
        if not task.done
    ]);

    completed: int = len([
        task
        for task in tasks
        if task.done
    ]);

    progress: int = 0;

    if len(tasks) > 0 {
        progress = int(
            completed * 100 / len(tasks)
        );
    }

    displayedTasks: list[Task] = tasks;

    if sortMode == "priority" {
        displayedTasks = sorted(
            tasks,
            key=lambda (task: Task) {
                (
                    priorityRank(task.priority),
                    (
                        task.due_date
                        if task.due_date
                        else "9999-12-31"
                    )
                );
            }
        );
    } elif sortMode == "due_date" {
        displayedTasks = sorted(
            tasks,
            key=lambda (task: Task) {
                (
                    (
                        task.due_date
                        if task.due_date
                        else "9999-12-31"
                    ),
                    priorityRank(task.priority)
                );
            }
        );
    }

    return
        <section class="panel tasks-panel">
            <div class="tasks-heading">
                <h2>Tasks</h2>

                <div class="view-toggle">
                    <button
                        class={
                            "view-toggle-button " +
                            (
                                "view-toggle-active"
                                if viewMode == "list"
                                else ""
                            )
                        }
                        onClick={lambda {
                            viewMode = "list";
                        }}
                    >
                        List
                    </button>

                    <button
                        class={
                            "view-toggle-button " +
                            (
                                "view-toggle-active"
                                if viewMode == "calendar"
                                else ""
                            )
                        }
                        onClick={lambda {
                            viewMode = "calendar";
                        }}
                    >
                        Calendar
                    </button>
                </div>
            </div>

            <div class="task-progress">
                <div class="progress-heading">
                    <span>Task progress</span>

                    <strong>
                        {progress}% out of 100%
                    </strong>
                </div>

                <progress
                    class="task-progress-bar"
                    value={progress}
                    max={100}
                />

                <div class="progress-details">
                    {completed} of {len(tasks)} completed
                </div>
            </div>

            <div class="input-row task-input-row">
                <input
                    class="input"
                    value={taskText}
                    onChange={lambda (e: ChangeEvent) {
                        taskText = e.target.value;
                    }}
                    onKeyPress={handleKeyPress}
                    placeholder="What needs to be done today?"
                />

                <input
                    class="due-date-input"
                    type="date"
                    value={dueDate}
                    onChange={lambda (e: ChangeEvent) {
                        dueDate = e.target.value;
                    }}
                    title="Task due date"
                />

                <select
                    class="priority-select"
                    value={selectedPriority}
                    onChange={lambda (e: ChangeEvent) {
                        selectedPriority = e.target.value;
                    }}
                >
                    <option value="high">
                        High
                    </option>

                    <option value="medium">
                        Medium
                    </option>

                    <option value="low">
                        Low
                    </option>
                </select>

                <button
                    class="btn-add"
                    onClick={lambda {
                        addTask();
                    }}
                >
                    Add
                </button>
            </div>

            {
                <div class="status-message">
                    Loading tasks...
                </div>
                if tasksLoading
                else (
                    <div class="list-view">
                        <div class="task-toolbar">
                            <span class="sort-label">
                                Sort tasks by:
                            </span>

                            <select
                                class="sort-select"
                                value={sortMode}
                                onChange={lambda (e: ChangeEvent) {
                                    sortMode = e.target.value;
                                }}
                            >
                                <option value="default">
                                    Default order
                                </option>

                                <option value="priority">
                                    Priority: High to Low
                                </option>

                                <option value="due_date">
                                    Due date: Soonest first
                                </option>
                            </select>
                        </div>

                        {
                            <div class="status-message">
                                No tasks yet.
                            </div>
                            if len(tasks) == 0
                            else
                            <div class="task-list">
                                {[
                                    <TaskItem
                                        key={jid(task)}
                                        task={task}
                                        onToggle={lambda {
                                            toggleTask(jid(task));
                                        }}
                                        onDelete={lambda {
                                            deleteTask(jid(task));
                                        }}
                                    />
                                    for task in displayedTasks
                                ]}
                            </div>
                        }
                    </div>
                    if viewMode == "list"
                    else
                    <TaskCalendar
                        tasks={tasks}
                        calendarMonth={calendarMonth}
                        onMonthChange={lambda (month: str) {
                            calendarMonth = month;
                        }}
                        onToggle={lambda (id: str) {
                            toggleTask(id);
                        }}
                        onDelete={lambda (id: str) {
                            deleteTask(id);
                        }}
                    />
                )
            }

            <div class="count">
                {remaining}
                {(" task" if remaining == 1 else " tasks")}
                {" remaining"}
            </div>
        </section>;
}