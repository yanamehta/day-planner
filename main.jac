"""AI Day Planner -- walker-based backend."""

import from frontend { app as ClientApp }
import from datetime { datetime }
import from requests { get }
import from re { findall, search, DOTALL, IGNORECASE }
import from bs4 { BeautifulSoup }


def:pub app -> JsxElement {
    return <ClientApp/>;
}


# Enums

enum Category {
    WORK,
    PERSONAL,
    SHOPPING,
    HEALTH,
    FITNESS,
    SOCIAL,
    FINANCE,
    OTHER
}

enum Unit {
    PIECE,
    LB,
    OZ,
    CUP,
    TBSP,
    TSP,
    BUNCH
}


# AI types and functions

obj Ingredient {
    has name: str,
        quantity: float,
        unit: Unit,
        cost: float,
        carby: bool;
}

sem Ingredient.cost = "Estimated cost in USD";
sem Ingredient.carby =
    "True if this ingredient is high in carbohydrates";

def categorize(title: str) -> Category by llm();

sem categorize = "Categorize a task based on its title";

def generate_shopping_list(
    meal_description: str
) -> list[Ingredient] by llm();

sem generate_shopping_list =
    "Generate a shopping list of ingredients needed for a described meal";


obj GeneratedExercise {
    has name: str,
        section: str,
        sets: int,
        reps: str,
        rest_seconds: int,
        instructions: str;
}

sem GeneratedExercise.name =
    "Clear, concise name of the exercise";

sem GeneratedExercise.section =
    "One of: warmup, workout, or cooldown";

sem GeneratedExercise.sets =
    "Number of sets. Use 1 for continuous warmups or cooldowns";

sem GeneratedExercise.reps =
    "Repetitions or duration, such as 10 reps, 30 seconds, or 5 minutes";

sem GeneratedExercise.rest_seconds =
    "Recommended rest after completing the set, in seconds";

sem GeneratedExercise.instructions =
    "One short sentence explaining how to perform the exercise safely";

def generate_workout_plan(
    goal: str,
    duration_minutes: int,
    equipment: str,
    focus: str,
    difficulty: str,
    limitations: str
) -> list[GeneratedExercise] by llm();

sem generate_workout_plan =
    "Create a balanced workout matching the user's goal, available time, "
    "equipment, focus area, difficulty, and stated limitations. Include a "
    "short warmup, a main workout, and a cooldown. Return exercises in the "
    "order they should be completed. Respect limitations and avoid exercises "
    "that conflict with them. Keep the total workout close to the requested "
    "duration.";


obj NewsArticle {
    has title: str,
        source: str,
        published: str,
        link: str;
}


# Data nodes

node Task {
    has title: str,
        done: bool = False,
        category: str = "other",
        priority: str = "medium",
        due_date: str = "";
}


obj:pub TaskInfo {
    has id: str,
        title: str,
        done: bool,
        category: str,
        priority: str,
        due_date: str;
}


node ShoppingItem {
    has name: str,
        quantity: float,
        unit: str,
        cost: float,
        carby: bool;
}

node GroceryItem {
    has name: str,
        quantity: float = 1.0,
        unit: str = "item",
        checked: bool = False;
}

node WorkoutExercise {
    has name: str,
        section: str,
        sets: int,
        reps: str,
        rest_seconds: int,
        instructions: str,
        position: int,
        completed: bool = False;
}


# Daily quote walker

walker:priv GetDailyQuote {
    has reports: list[dict[str, str]] = [];

    can get_quote with Root entry {
        quotes: list[dict[str, str]] = [
            {
                "text": "Success is the sum of small efforts repeated day in and day out.",
                "author": "Robert Collier"
            },
            {
                "text": "The secret of getting ahead is getting started.",
                "author": "Mark Twain"
            },
            {
                "text": "Great things are done by a series of small things brought together.",
                "author": "Vincent van Gogh"
            },
            {
                "text": "It always seems impossible until it is done.",
                "author": "Nelson Mandela"
            },
            {
                "text": "You do not have to see the whole staircase, just take the first step.",
                "author": "Martin Luther King Jr."
            },
            {
                "text": "Believe you can and you are halfway there.",
                "author": "Theodore Roosevelt"
            },
            {
                "text": "Start where you are. Use what you have. Do what you can.",
                "author": "Arthur Ashe"
            },
            {
                "text": "The future depends on what you do today.",
                "author": "Mahatma Gandhi"
            },
            {
                "text": "Do something today that your future self will thank you for.",
                "author": "Sean Patrick Flanery"
            },
            {
                "text": "Small progress is still progress.",
                "author": "Unknown"
            }
        ];

        dayNumber: int = int(
            datetime.now().strftime("%j")
        );

        quoteIndex: int = dayNumber % len(quotes);

        report quotes[quoteIndex];
    }
}


# Daily news walker

walker:priv GetDailyNews {
    has reports: list[list[NewsArticle]] = [];

    can fetch_news with Root entry {
        feedUrl: str = (
            "https://news.google.com/rss"
            "?hl=en-US&gl=US&ceid=US:en"
        );

        response: any = get(
            feedUrl,
            timeout=10,
            headers={
                "User-Agent": "Mozilla/5.0"
            }
        );

        response.raise_for_status();

        itemBlocks: list[any] = findall(
            r"<item\b[^>]*>(.*?)</item>",
            response.text,
            DOTALL | IGNORECASE
        );

        articles: list[NewsArticle] = [];

        for itemBlock in itemBlocks[:10] {
            itemSoup: any = BeautifulSoup(
                itemBlock,
                "html.parser"
            );

            articleTitle: str = "Untitled article";
            articleSource: str = "Google News";
            articlePublished: str = "";
            articleLink: str = "";

            titleTag: any = itemSoup.find("title");

            if titleTag is not None {
                articleTitle = titleTag.get_text(
                    " ",
                    strip=True
                );
            }

            sourceTag: any = itemSoup.find("source");

            if sourceTag is not None {
                articleSource = sourceTag.get_text(
                    " ",
                    strip=True
                );
            }

            publishedTag: any = itemSoup.find("pubdate");

            if publishedTag is not None {
                articlePublished = publishedTag.get_text(
                    " ",
                    strip=True
                );
            }

            linkMatch: any = search(
                r"<link[^>]*>\s*(?:<!\[CDATA\[)?\s*(.*?)\s*(?:\]\]>)?\s*</link>",
                itemBlock,
                DOTALL | IGNORECASE
            );

            if linkMatch is not None {
                articleLink = linkMatch.group(1).strip();
            }

            if articleLink {
                articles.append(
                    NewsArticle(
                        title=articleTitle,
                        source=articleSource,
                        published=articlePublished,
                        link=articleLink
                    )
                );
            }
        }

        report articles;
    }
}


# Task walkers

walker:priv AddTask {
    has title: str,
        priority: str = "medium",
        due_date: str = "",
        reports: list[Task] = [];

    can add with Root entry {
        category = str(
            categorize(self.title)
        ).split(".")[-1].lower();

        selected_priority = self.priority.lower();

        if selected_priority not in ["high", "medium", "low"] {
            selected_priority = "medium";
        }

        new_task = here ++> Task(
            title=self.title,
            category=category,
            priority=selected_priority,
            due_date=self.due_date
        );

        report new_task;
    }
}


walker:priv ListTasks {
    has results: list[Task] = [],
        reports: list[list[Task]] = [];

    can start with Root entry {
        visit [-->];
    }

    can collect with Task entry {
        self.results.append(here);
    }

    can done with Root exit {
        report self.results;
    }
}


walker:pub CliListTasks {
    has results: list[TaskInfo] = [],
        reports: list[list[TaskInfo]] = [];

    can start with Root entry {
        visit [-->];
    }

    can collect with Task entry {
        self.results.append(
            TaskInfo(
                id=jid(here),
                title=here.title,
                done=here.done,
                category=here.category,
                priority=here.priority,
                due_date=here.due_date
            )
        );
    }

    can done with Root exit {
        report self.results;
    }
}

walker:pub CliAddTask {
    has title: str,
        priority: str = "medium",
        due_date: str = "",
        reports: list[TaskInfo] = [];

    can add with Root entry {
        category: str = "other";

        selected_priority: str = self.priority.lower();

        if selected_priority not in [
            "high",
            "medium",
            "low"
        ] {
            selected_priority = "medium";
        }

        new_task = here ++> Task(
            title=self.title,
            category=category,
            priority=selected_priority,
            due_date=self.due_date
        );

        report TaskInfo(
            id=jid(new_task),
            title=new_task.title,
            done=new_task.done,
            category=new_task.category,
            priority=new_task.priority,
            due_date=new_task.due_date
        );
    }
}

walker:pub CliCompleteTask {
    has task_id: str,
        reports: list[TaskInfo] = [];

    can search with Root entry {
        visit [-->];
    }

    can complete with Task entry {
        if jid(here) == self.task_id {
            here.done = True;

            report TaskInfo(
                id=jid(here),
                title=here.title,
                done=here.done,
                category=here.category,
                priority=here.priority,
                due_date=here.due_date
            );

            disengage;
        }
    }
}

walker:pub CliDeleteTask {
    has task_id: str,
        reports: list[TaskInfo] = [];

    can search with Root entry {
        visit [-->];
    }

    can remove with Task entry {
        if jid(here) == self.task_id {
            deleted_task: TaskInfo = TaskInfo(
                id=jid(here),
                title=here.title,
                done=here.done,
                category=here.category,
                priority=here.priority,
                due_date=here.due_date
            );

            del here;

            report deleted_task;
            disengage;
        }
    }
}

walker:priv ToggleTask {
    has task_id: str,
        reports: list[Task] = [];

    can search with Root entry {
        visit [-->];
    }

    can toggle with Task entry {
        if jid(here) == self.task_id {
            here.done = not here.done;
            report here;
            disengage;
        }
    }
}


walker:priv DeleteTask {
    has task_id: str;

    can search with Root entry {
        visit [-->];
    }

    can remove with Task entry {
        if jid(here) == self.task_id {
            del here;
            disengage;
        }
    }
}


# AI shopping-list walkers

walker:priv GenerateShoppingList {
    has meal_description: str,
        reports: list[list[ShoppingItem]] = [];

    can generate with Root entry {
        for old_item in [here-->][?:ShoppingItem] {
            del old_item;
        }

        ingredients = generate_shopping_list(
            self.meal_description
        );

        created: list[ShoppingItem] = [];

        for ing in ingredients {
            item = here ++> ShoppingItem(
                name=ing.name,
                quantity=ing.quantity,
                unit=str(
                    ing.unit
                ).split(".")[-1].lower(),
                cost=ing.cost,
                carby=ing.carby
            );

            created.append(item);
        }

        report created;
    }
}


walker:priv GetShoppingList {
    has results: list[ShoppingItem] = [],
        reports: list[list[ShoppingItem]] = [];

    can start with Root entry {
        visit [-->];
    }

    can collect with ShoppingItem entry {
        self.results.append(here);
    }

    can done with Root exit {
        report self.results;
    }
}


walker:priv ClearShoppingList {
    can clear with Root entry {
        for item in [here-->][?:ShoppingItem] {
            del item;
        }

        report {"cleared": True};
    }
}


# Personal grocery-list walkers

walker:priv AddGroceryItem {
    has name: str,
        quantity: float = 1.0,
        unit: str = "item",
        reports: list[GroceryItem] = [];

    can add with Root entry {
        cleanName: str = self.name.strip();
        cleanUnit: str = self.unit.strip();

        if not cleanName {
            return;
        }

        if not cleanUnit {
            cleanUnit = "item";
        }

        newItem = here ++> GroceryItem(
            name=cleanName,
            quantity=self.quantity,
            unit=cleanUnit
        );

        report newItem;
    }
}


walker:priv ListGroceryItems {
    has results: list[GroceryItem] = [],
        reports: list[list[GroceryItem]] = [];

    can start with Root entry {
        visit [-->];
    }

    can collect with GroceryItem entry {
        self.results.append(here);
    }

    can done with Root exit {
        report self.results;
    }
}


walker:priv ToggleGroceryItem {
    has item_id: str,
        reports: list[GroceryItem] = [];

    can search with Root entry {
        visit [-->];
    }

    can toggle with GroceryItem entry {
        if jid(here) == self.item_id {
            here.checked = not here.checked;
            report here;
            disengage;
        }
    }
}


walker:priv DeleteGroceryItem {
    has item_id: str;

    can search with Root entry {
        visit [-->];
    }

    can remove with GroceryItem entry {
        if jid(here) == self.item_id {
            del here;
            disengage;
        }
    }
}


# Workout walkers

walker:priv GenerateWorkout {
    has goal: str,
        duration_minutes: int,
        equipment: str,
        focus: str,
        difficulty: str,
        limitations: str = "",
        reports: list[list[WorkoutExercise]] = [];

    can generate with Root entry {
        for oldExercise in [here-->][?:WorkoutExercise] {
            del oldExercise;
        }

        generatedExercises = generate_workout_plan(
            goal=self.goal,
            duration_minutes=self.duration_minutes,
            equipment=self.equipment,
            focus=self.focus,
            difficulty=self.difficulty,
            limitations=self.limitations
        );

        createdExercises: list[WorkoutExercise] = [];
        currentPosition: int = 0;

        for generated in generatedExercises {
            exercise = here ++> WorkoutExercise(
                name=generated.name,
                section=generated.section.lower(),
                sets=generated.sets,
                reps=generated.reps,
                rest_seconds=generated.rest_seconds,
                instructions=generated.instructions,
                position=currentPosition
            );

            createdExercises.append(exercise);
            currentPosition += 1;
        }

        report createdExercises;
    }
}


walker:priv GetWorkout {
    has results: list[WorkoutExercise] = [],
        reports: list[list[WorkoutExercise]] = [];

    can start with Root entry {
        visit [-->];
    }

    can collect with WorkoutExercise entry {
        self.results.append(here);
    }

    can done with Root exit {
        self.results = sorted(
            self.results,
            key=lambda (exercise: WorkoutExercise) {
                exercise.position;
            }
        );

        report self.results;
    }
}


walker:priv ToggleWorkoutExercise {
    has exercise_id: str,
        reports: list[WorkoutExercise] = [];

    can search with Root entry {
        visit [-->];
    }

    can toggle with WorkoutExercise entry {
        if jid(here) == self.exercise_id {
            here.completed = not here.completed;
            report here;
            disengage;
        }
    }
}


walker:priv ClearWorkout {
    can clear with Root entry {
        for exercise in [here-->][?:WorkoutExercise] {
            del exercise;
        }

        report {"cleared": True};
    }
}