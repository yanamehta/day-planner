"""Presentational component for a single task."""

import from ..main { Task }


def:pub TaskItem(
    task: Task,
    onToggle: Callable[[], None],
    onDelete: Callable[[], None]
) -> JsxElement {
    return
        <div class={
            "task-item task-priority-" + task.priority
        }>
            <input
                type="checkbox"
                checked={task.done}
                onChange={onToggle}
            />

            <span
                class={
                    "task-title " +
                    ("task-done" if task.done else "")
                }
            >
                {task.title}
            </span>

            {
                <span class="due-date-badge">
                    Due {task.due_date}
                </span>
                if task.due_date
                else None
            }

            {
                <span class="category">
                    {task.category}
                </span>
                if task.category and task.category != "other"
                else None
            }

            <span class={
                "priority-badge priority-" + task.priority
            }>
                {task.priority}
            </span>

            <button
                class="btn-delete"
                onClick={onDelete}
            >
                X
            </button>
        </div>;
}