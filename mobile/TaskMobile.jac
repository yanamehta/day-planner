"""Simple mobile task manager for the Day Planner."""

import from "@jac/mobui" {
    View,
    Text,
    TextInput,
    Pressable,
    ScrollView,
    ActivityIndicator,
    StatusBar
}

import from main {
    TaskInfo,
    CliListTasks,
    CliAddTask,
    CliCompleteTask,
    CliDeleteTask
}


def:pub TaskMobile -> JsxElement {
    has tasks: list[TaskInfo] = [],
        taskText: str = "",
        loading: bool = True,
        saving: bool = False,
        message: str = "";

    async can with entry {
        await loadTasks();
    }

    async def loadTasks {
        loading = True;
        message = "";

        response = await (
            root spawn CliListTasks()
        );

        tasks = (
            response.reports[0]
            if response.reports
            else []
        );

        loading = False;
    }

    async def addTask {
        cleanTitle: str = taskText.strip();

        if not cleanTitle {
            message = "Enter a task first.";
            return;
        }

        saving = True;
        message = "";

        response = await (
            root spawn CliAddTask(
                title=cleanTitle,
                priority="medium",
                due_date=""
            )
        );

        if response.reports {
            tasks = tasks + [response.reports[0]];
            taskText = "";
            message = "Task added.";
        } else {
            message = "Could not add the task.";
        }

        saving = False;
    }

    async def completeTask(task: TaskInfo) {
        response = await (
            root spawn CliCompleteTask(
                task_id=task.id
            )
        );

        if response.reports {
            updated: TaskInfo = response.reports[0];

            tasks = [
                updated if item.id == task.id else item
                for item in tasks
            ];
        }
    }

    async def deleteTask(task: TaskInfo) {
        response = await (
            root spawn CliDeleteTask(
                task_id=task.id
            )
        );

        if response.reports {
            tasks = [
                item
                for item in tasks
                if item.id != task.id
            ];

            message = "Task deleted.";
        }
    }

    completed: int = len(
        [
            task
            for task in tasks
            if task.done
        ]
    );

    <View
        style={{
            "flex": 1,
            "backgroundColor": "#F5F7FA"
        }}
    >
        <StatusBar
            barStyle="light-content"
            backgroundColor="#00274C"
        />

        <View
            style={{
                "backgroundColor": "#00274C",
                "paddingTop": 54,
                "paddingBottom": 22,
                "paddingHorizontal": 22
            }}
        >
            <Text
                style={{
                    "color": "#FFCB05",
                    "fontSize": 28,
                    "fontWeight": "700"
                }}
            >
                Day Planner
            </Text>

            <Text
                style={{
                    "color": "#FFFFFF",
                    "fontSize": 15,
                    "marginTop": 5
                }}
            >
                Tasks on the go
            </Text>
        </View>

        <View
            style={{
                "padding": 18,
                "backgroundColor": "#FFFFFF",
                "borderBottomWidth": 1,
                "borderBottomColor": "#D8DEE8"
            }}
        >
            <Text
                style={{
                    "color": "#00274C",
                    "fontSize": 16,
                    "fontWeight": "600",
                    "marginBottom": 10
                }}
            >
                {str(completed)} of {str(len(tasks))} completed
            </Text>

            <View
                style={{
                    "flexDirection": "row",
                    "gap": 10
                }}
            >
                <TextInput
                    style={{
                        "flex": 1,
                        "backgroundColor": "#F5F7FA",
                        "borderWidth": 1,
                        "borderColor": "#C7D0DC",
                        "borderRadius": 10,
                        "paddingHorizontal": 14,
                        "paddingVertical": 12,
                        "fontSize": 16,
                        "color": "#1F2937"
                    }}
                    value={taskText}
                    placeholder="Add a task..."
                    placeholderTextColor="#6B7280"
                    onChangeText={lambda (text: str) {
                        taskText = text;
                    }}
                />

                <Pressable
                    accessibilityRole="button"
                    disabled={saving}
                    onPress={lambda {
                        addTask();
                    }}
                    style={{
                        "backgroundColor": (
                            "#9CA3AF"
                            if saving
                            else "#FFCB05"
                        ),
                        "borderRadius": 10,
                        "paddingHorizontal": 18,
                        "justifyContent": "center"
                    }}
                >
                    {
                        <ActivityIndicator
                            size="small"
                            color="#00274C"
                        />
                        if saving
                        else
                        <Text
                            style={{
                                "color": "#00274C",
                                "fontSize": 16,
                                "fontWeight": "700"
                            }}
                        >
                            Add
                        </Text>
                    }
                </Pressable>
            </View>

            {
                <Text
                    style={{
                        "color": "#52606D",
                        "fontSize": 14,
                        "marginTop": 10
                    }}
                >
                    {message}
                </Text>
                if message
                else None
            }
        </View>

        {
            <View
                style={{
                    "flex": 1,
                    "alignItems": "center",
                    "justifyContent": "center"
                }}
            >
                <ActivityIndicator
                    size="large"
                    color="#00274C"
                />

                <Text
                    style={{
                        "color": "#52606D",
                        "marginTop": 12
                    }}
                >
                    Loading tasks...
                </Text>
            </View>
            if loading
            else (
                <View
                    style={{
                        "flex": 1,
                        "alignItems": "center",
                        "justifyContent": "center",
                        "padding": 30
                    }}
                >
                    <Text
                        style={{
                            "color": "#00274C",
                            "fontSize": 20,
                            "fontWeight": "600"
                        }}
                    >
                        No tasks yet
                    </Text>

                    <Text
                        style={{
                            "color": "#6B7280",
                            "fontSize": 15,
                            "marginTop": 8,
                            "textAlign": "center"
                        }}
                    >
                        Add your first task above.
                    </Text>
                </View>
                if len(tasks) == 0
                else
                <ScrollView
                    style={{
                        "flex": 1
                    }}
                    contentContainerStyle={{
                        "padding": 16,
                        "gap": 12
                    }}
                >
                    {[
                        <View
                            key={task.id}
                            style={{
                                "backgroundColor": "#FFFFFF",
                                "borderRadius": 12,
                                "padding": 16,
                                "borderLeftWidth": 5,
                                "borderLeftColor": (
                                    "#22C55E"
                                    if task.done
                                    else "#FFCB05"
                                ),
                                "shadowColor": "#000000",
                                "shadowOpacity": 0.08,
                                "shadowRadius": 5
                            }}
                        >
                            <Text
                                style={{
                                    "color": (
                                        "#9CA3AF"
                                        if task.done
                                        else "#1F2937"
                                    ),
                                    "fontSize": 17,
                                    "fontWeight": "600",
                                    "textDecorationLine": (
                                        "line-through"
                                        if task.done
                                        else "none"
                                    )
                                }}
                            >
                                {task.title}
                            </Text>

                            <Text
                                style={{
                                    "color": "#6B7280",
                                    "fontSize": 13,
                                    "marginTop": 6,
                                    "textTransform": "capitalize"
                                }}
                            >
                                {task.priority}
                                {" priority"}
                                {
                                    " • Due " + task.due_date
                                    if task.due_date
                                    else ""
                                }
                            </Text>

                            <View
                                style={{
                                    "flexDirection": "row",
                                    "gap": 10,
                                    "marginTop": 14
                                }}
                            >
                                {
                                    <Pressable
                                        accessibilityRole="button"
                                        onPress={lambda {
                                            completeTask(task);
                                        }}
                                        style={{
                                            "backgroundColor": "#00274C",
                                            "borderRadius": 8,
                                            "paddingHorizontal": 14,
                                            "paddingVertical": 9
                                        }}
                                    >
                                        <Text
                                            style={{
                                                "color": "#FFFFFF",
                                                "fontWeight": "600"
                                            }}
                                        >
                                            Complete
                                        </Text>
                                    </Pressable>
                                    if not task.done
                                    else
                                    <View
                                        style={{
                                            "backgroundColor": "#DCFCE7",
                                            "borderRadius": 8,
                                            "paddingHorizontal": 14,
                                            "paddingVertical": 9
                                        }}
                                    >
                                        <Text
                                            style={{
                                                "color": "#166534",
                                                "fontWeight": "600"
                                            }}
                                        >
                                            Completed
                                        </Text>
                                    </View>
                                }

                                <Pressable
                                    accessibilityRole="button"
                                    onPress={lambda {
                                        deleteTask(task);
                                    }}
                                    style={{
                                        "backgroundColor": "#FEE2E2",
                                        "borderRadius": 8,
                                        "paddingHorizontal": 14,
                                        "paddingVertical": 9
                                    }}
                                >
                                    <Text
                                        style={{
                                            "color": "#B91C1C",
                                            "fontWeight": "600"
                                        }}
                                    >
                                        Delete
                                    </Text>
                                </Pressable>
                            </View>
                        </View>
                        for task in tasks
                    ]}
                </ScrollView>
            )
        }
    </View>
}