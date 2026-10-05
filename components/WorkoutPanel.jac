"""AI workout planner panel."""

import from ..main {
    WorkoutExercise,
    GenerateWorkout,
    GetWorkout,
    ToggleWorkoutExercise,
    ClearWorkout
}

import from .ExerciseItem { ExerciseItem }


def:pub WorkoutPanel -> JsxElement {
    has exercises: list[WorkoutExercise] = [],
        goal: str = "General fitness",
        durationMinutes: int = 30,
        equipment: str = "No equipment",
        focus: str = "Full body",
        difficulty: str = "Beginner",
        limitations: str = "",
        workoutLoading: bool = True,
        generating: bool = False;

    async can with entry {
        result = root spawn GetWorkout();

        exercises = (
            result.reports[0]
            if result.reports
            else []
        );

        workoutLoading = False;
    }

    async def generateWorkout {
        generating = True;

        result = root spawn GenerateWorkout(
            goal=goal,
            duration_minutes=durationMinutes,
            equipment=equipment,
            focus=focus,
            difficulty=difficulty,
            limitations=limitations
        );

        exercises = (
            result.reports[0]
            if result.reports
            else []
        );

        generating = False;
    }

    async def toggleExercise(id: str) {
        result = root spawn ToggleWorkoutExercise(
            exercise_id=id
        );

        if result.reports {
            updated = result.reports[0];

            if updated is not None {
                exercises = [
                    updated if jid(exercise) == id else exercise
                    for exercise in exercises
                ];
            }
        }
    }

    async def clearWorkout {
        root spawn ClearWorkout();
        exercises = [];
    }

    completed = len([
        exercise
        for exercise in exercises
        if exercise.completed
    ]);

    workoutProgress: int = 0;

    if len(exercises) > 0 {
        workoutProgress = int(
            completed * 100 / len(exercises)
        );
    }

    return
        <section class="panel workout-panel">
            <div class="workout-panel-header">
                <div>
                    <h2>AI Workout Planner</h2>

                    <p class="panel-description">
                        Create a personalized workout based on your goals.
                    </p>
                </div>
            </div>

            <div class="workout-form">
                <div class="workout-form-grid">
                    <label class="workout-field">
                        <span>Goal</span>

                        <select
                            value={goal}
                            onChange={lambda (e: ChangeEvent) {
                                goal = e.target.value;
                            }}
                        >
                            <option value="General fitness">
                                General fitness
                            </option>

                            <option value="Build strength">
                                Build strength
                            </option>

                            <option value="Build muscle">
                                Build muscle
                            </option>

                            <option value="Improve endurance">
                                Improve endurance
                            </option>

                            <option value="Lose weight">
                                Lose weight
                            </option>

                            <option value="Improve mobility">
                                Improve mobility
                            </option>
                        </select>
                    </label>

                    <label class="workout-field">
                        <span>Duration</span>

                        <select
                            value={str(durationMinutes)}
                            onChange={lambda (e: ChangeEvent) {
                                durationMinutes = int(e.target.value);
                            }}
                        >
                            <option value="15">15 minutes</option>
                            <option value="20">20 minutes</option>
                            <option value="30">30 minutes</option>
                            <option value="45">45 minutes</option>
                            <option value="60">60 minutes</option>
                        </select>
                    </label>

                    <label class="workout-field">
                        <span>Equipment</span>

                        <select
                            value={equipment}
                            onChange={lambda (e: ChangeEvent) {
                                equipment = e.target.value;
                            }}
                        >
                            <option value="No equipment">
                                No equipment
                            </option>

                            <option value="Dumbbells">
                                Dumbbells
                            </option>

                            <option value="Resistance bands">
                                Resistance bands
                            </option>

                            <option value="Full gym">
                                Full gym
                            </option>

                            <option value="Yoga mat">
                                Yoga mat
                            </option>
                        </select>
                    </label>

                    <label class="workout-field">
                        <span>Focus</span>

                        <select
                            value={focus}
                            onChange={lambda (e: ChangeEvent) {
                                focus = e.target.value;
                            }}
                        >
                            <option value="Full body">
                                Full body
                            </option>

                            <option value="Upper body">
                                Upper body
                            </option>

                            <option value="Lower body">
                                Lower body
                            </option>

                            <option value="Core">
                                Core
                            </option>

                            <option value="Cardio">
                                Cardio
                            </option>

                            <option value="Mobility">
                                Mobility
                            </option>
                        </select>
                    </label>

                    <label class="workout-field">
                        <span>Difficulty</span>

                        <select
                            value={difficulty}
                            onChange={lambda (e: ChangeEvent) {
                                difficulty = e.target.value;
                            }}
                        >
                            <option value="Beginner">
                                Beginner
                            </option>

                            <option value="Intermediate">
                                Intermediate
                            </option>

                            <option value="Advanced">
                                Advanced
                            </option>
                        </select>
                    </label>

                    <label class="workout-field workout-limitations-field">
                        <span>Limitations or preferences</span>

                        <input
                            value={limitations}
                            onChange={lambda (e: ChangeEvent) {
                                limitations = e.target.value;
                            }}
                            placeholder="Example: no jumping or avoid knee strain"
                        />
                    </label>
                </div>

                <button
                    class="btn-generate workout-generate-button"
                    disabled={generating}
                    onClick={lambda {
                        generateWorkout();
                    }}
                >
                    {
                        "Creating workout..."
                        if generating
                        else (
                            "Regenerate workout"
                            if len(exercises) > 0
                            else "Generate workout"
                        )
                    }
                </button>
            </div>

            {
                <div class="status-message">
                    Loading your workout...
                </div>
                if workoutLoading
                else (
                    <div class="status-message">
                        Choose your preferences and generate a workout.
                    </div>
                    if len(exercises) == 0
                    else
                    <div class="generated-workout">
                        <div class="workout-progress">
                            <div class="progress-heading">
                                <span>Workout progress</span>

                                <strong>
                                    {workoutProgress}% complete
                                </strong>
                            </div>

                            <progress
                                class="task-progress-bar"
                                value={workoutProgress}
                                max={100}
                            />

                            <div class="progress-details">
                                {completed} of {len(exercises)} exercises completed
                            </div>
                        </div>

                        <div class="exercise-list">
                            {[
                                <ExerciseItem
                                    key={jid(exercise)}
                                    exercise={exercise}
                                    onToggle={lambda {
                                        toggleExercise(jid(exercise));
                                    }}
                                />
                                for exercise in exercises
                            ]}
                        </div>

                        <button
                            class="btn-clear-workout"
                            onClick={lambda {
                                clearWorkout();
                            }}
                        >
                            Clear workout
                        </button>
                    </div>
                )
            }

            <p class="workout-disclaimer">
                AI-generated workouts are general suggestions. Adjust exercises
                to your ability and stop if you experience pain.
            </p>
        </section>;
}