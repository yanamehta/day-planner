"""Presentational card for one workout exercise."""

import from ..main { WorkoutExercise }


def:pub ExerciseItem(
    exercise: WorkoutExercise,
    onToggle: Callable[[], None]
) -> JsxElement {
    return
        <div class={
            "exercise-item exercise-section-" +
            exercise.section +
            (
                " exercise-completed"
                if exercise.completed
                else ""
            )
        }>
            <div class="exercise-check">
                <input
                    type="checkbox"
                    checked={exercise.completed}
                    onChange={onToggle}
                />
            </div>

            <div class="exercise-content">
                <div class="exercise-heading">
                    <span class={
                        "exercise-section-badge section-" +
                        exercise.section
                    }>
                        {exercise.section}
                    </span>

                    <h4>{exercise.name}</h4>
                </div>

                <div class="exercise-prescription">
                    <span>
                        <strong>{exercise.sets}</strong>
                        {" sets"}
                    </span>

                    <span>
                        <strong>{exercise.reps}</strong>
                    </span>

                    <span>
                        <strong>{exercise.rest_seconds}</strong>
                        {" sec rest"}
                    </span>
                </div>

                <p class="exercise-instructions">
                    {exercise.instructions}
                </p>
            </div>
        </div>;
}