"""Authenticated Day Planner frontend."""

import "./styles.css";

import from "@jac/runtime" {
    jacLogout,
    jacIsLoggedIn
}

import from .components.AuthForm { AuthForm }
import from .components.Header { Header }
import from .components.TasksPanel { TasksPanel }
import from .components.ShoppingPanel { ShoppingPanel }
import from .components.WorkoutPanel { WorkoutPanel }
import from .components.DailyQuote { DailyQuote }
import from .components.Footer { Footer }
import from .components.NewsPanel { NewsPanel }


def:pub app -> JsxElement {
    has isLoggedIn: bool = False,
        checkingAuth: bool = True,
        activePage: str = "home";

    async can with entry {
        isLoggedIn = await jacIsLoggedIn();
        checkingAuth = False;
    }

    def handleAuth {
        isLoggedIn = True;
        activePage = "home";
    }

    async def handleLogout {
        await jacLogout();
        isLoggedIn = False;
        activePage = "home";
    }

    return
        <div class="app">
            {
                <div class="auth-page">
                    <div class="status-message">
                        Checking login...
                    </div>
                </div>
                if checkingAuth
                else (
                    <AuthForm
                        onAuth={handleAuth}
                    />
                    if not isLoggedIn
                    else
                    <div class="app-shell">
                        <Header
                            onLogout={handleLogout}
                        />

                        <nav class="page-navigation">
                            <div class="page-tabs">
                                <button
                                    class={
                                        "page-tab " +
                                        (
                                            "page-tab-active"
                                            if activePage == "home"
                                            else ""
                                        )
                                    }
                                    onClick={lambda {
                                        activePage = "home";
                                    }}
                                >
                                    <span class="page-tab-icon">
                                        ⌂
                                    </span>

                                    <span>Home</span>
                                </button>

                                <button
                                    class={
                                        "page-tab " +
                                        (
                                            "page-tab-active"
                                            if activePage == "tasks"
                                            else ""
                                        )
                                    }
                                    onClick={lambda {
                                        activePage = "tasks";
                                    }}
                                >
                                    <span class="page-tab-icon">
                                        ✓
                                    </span>

                                    <span>Tasks</span>
                                </button>

                                <button
                                    class={
                                        "page-tab " +
                                        (
                                            "page-tab-active"
                                            if activePage == "groceries"
                                            else ""
                                        )
                                    }
                                    onClick={lambda {
                                        activePage = "groceries";
                                    }}
                                >
                                    <span class="page-tab-icon">
                                        🛒
                                    </span>

                                    <span>Groceries</span>
                                </button>

                                <button
                                    class={
                                        "page-tab " +
                                        (
                                            "page-tab-active"
                                            if activePage == "exercise"
                                            else ""
                                        )
                                    }
                                    onClick={lambda {
                                        activePage = "exercise";
                                    }}
                                >
                                    <span class="page-tab-icon">
                                        ◇
                                    </span>

                                    <span>Exercise</span>
                                </button>

                                <button
                                    class={
                                        "page-tab " +
                                        (
                                            "page-tab-active"
                                            if activePage == "news"
                                            else ""
                                        )
                                    }
                                    onClick={lambda {
                                        activePage = "news";
                                    }}
                                >
                                    <span class="page-tab-icon">
                                        📰
                                    </span>

                                    <span>News</span>
                                </button>
                            </div>
                        </nav>

                        <main class="dashboard page-dashboard">
                            {
                                <section class="panel home-panel">
                                    <div class="home-placeholder">
                                        <div class="home-placeholder-icon">
                                            ⌂
                                        </div>

                                        <h2>Home</h2>

                                        <p>
                                            Organize your tasks, groceries,
                                            and workouts all in one place.
                                        </p>

                                        <DailyQuote/>

                                        <div class="home-actions">
                                            <button
                                                class="home-action-button home-action-secondary"
                                                onClick={lambda {
                                                    activePage = "tasks";
                                                }}
                                            >
                                                View Tasks
                                            </button>

                                            <button
                                                class="home-action-button home-action-secondary"
                                                onClick={lambda {
                                                    activePage = "groceries";
                                                }}
                                            >
                                                View Groceries
                                            </button>

                                            <button
                                                class="home-action-button home-action-secondary"
                                                onClick={lambda {
                                                    activePage = "exercise";
                                                }}
                                            >
                                                View Workouts
                                            </button>
                                        </div>
                                    </div>
                                </section>
                                if activePage == "home"
                                else (
                                    <TasksPanel/>
                                    if activePage == "tasks"
                                    else (
                                        <ShoppingPanel/>
                                        if activePage == "groceries"
                                        else (
                                            <WorkoutPanel/>
                                            if activePage == "exercise"
                                            else
                                            <NewsPanel/>
                                        )
                                    )
                                )
                            }
                        </main>

                        <Footer/>
                    </div>
                )
            }
        </div>;
}