# Day Planner

**Author:** Yana Mehta  
**UMID:** 4241 9466
**Uniqname:** yamehta  
**Course:** EECS 449  
**Assignment:** Extra Credit 1 — Personal Planning App in Jac

## Overview

Day Planner is a full-stack personal planning application built with Jac. It combines task management, grocery planning, exercise planning, daily news, and AI-assisted features in one application.

The project includes all four required interfaces:

1. A persistent Jac server
2. A browser-based web frontend
3. A mobile interface
4. A command-line interface (CLI)

All three user interfaces communicate with the same backend so task updates can be shared across the web, mobile, and CLI versions.

## Main Features

### Task Planning

- Add, complete, and delete tasks
- Assign high, medium, or low priority
- Add task due dates
- Automatically categorize tasks using AI
- Sort tasks by priority or due date
- Use secondary sorting by priority and date
- View tasks in list or monthly calendar format
- Highlight overdue tasks
- Track completion with a live progress bar

### Grocery Planning

- Generate an AI shopping list from a meal description
- View estimated ingredient quantities, units, prices, and carbohydrate information
- Add AI-generated ingredients to a personal grocery list
- Manually add grocery items
- Remove and manage grocery items

### Exercise Planning

- Generate personalized workouts with AI
- Select workout duration and other preferences
- View individual exercises and workout guidance

### News and Home Dashboard

- View current headlines from Google News RSS
- Open articles on the original publisher’s website
- Refresh the daily news
- Display a rotating daily inspirational quote
- Navigate using a University of Michigan maize-and-blue interface

### Authentication

- Create an account
- Log in and log out
- Keep each user’s planning data isolated

### CLI

The terminal interface supports:

- Viewing all tasks
- Viewing pending tasks
- Adding tasks with priorities and due dates
- Marking tasks complete
- Deleting tasks

### Mobile

The mobile interface supports:

- Viewing tasks
- Adding tasks
- Completing tasks
- Deleting tasks
- Sharing task data with the web and CLI interfaces

## Project Structure

```text
day-planner/
├── main.jac
├── frontend.jac
├── styles.css
├── jac.toml
├── components/
│   ├── AuthForm.jac
│   ├── DailyQuote.jac
│   ├── Footer.jac
│   ├── Header.jac
│   ├── IngredientItem.jac
│   ├── NewsPanel.jac
│   ├── ShoppingPanel.jac
│   ├── TaskCalendar.jac
│   ├── TaskItem.jac
│   ├── TasksPanel.jac
│   └── WorkoutPanel.jac
├── cli/
│   └── app.jac
└── mobile/
    ├── main.jac
    └── TaskMobile.jac
```

## Prerequisites

This project was developed using:

- macOS
- Jac 0.37.21
- Python 3
- Internet access for news retrieval
- A local AI model through `byllm[local]`

Verify Jac is installed:

```bash
jac --version
```

The expected project version is:

```text
0.37.21
```

## Installation

Clone the repository and enter the project directory:

```bash
git clone <YOUR-GITHUB-REPOSITORY-URL>
cd day-planner
```

Install the Jac, Python, and npm dependencies declared in `jac.toml`:

```bash
jac install
```

## Running the Web Application and Server

The default app is configured as the web application. From the repository root, run:

```bash
jac run
```

After the server is ready, open:

```text
http://localhost:8000
```

The web API runs at:

```text
http://localhost:8001
```

The first local AI request may take longer while the model initializes.

## Using the CLI

The CLI communicates with the running web backend. Keep the web server running in one terminal:

```bash
jac run
```

Open a second terminal in the project directory and set the backend URL:

```bash
export JAC_APP_WEB_URL=http://localhost:8001
```

Display CLI help:

```bash
jac run cli -- --help
```

List all tasks:

```bash
jac run cli -- list
```

List pending tasks:

```bash
jac run cli -- pending
```

Add a task:

```bash
jac run cli -- add "Finish project README" --priority high --due 2026-10-05
```

Mark a task complete using its displayed number:

```bash
jac run cli -- done 1
```

Delete a task using its displayed number:

```bash
jac run cli -- delete 1
```

Because task numbers can change after deletion, run `list` before using `done` or `delete`.

## Running the Mobile App

The mobile interface uses the same backend as the web and CLI applications.

First, start the web backend in Terminal 1:

```bash
jac run
```

The backend must remain running at `http://localhost:8001`.

### Browser Mobile Preview

In Terminal 2, run:

```bash
DAY_PLANNER_API_URL=http://localhost:8001 jac build --platform web mobile
DAY_PLANNER_API_URL=http://localhost:8001 jac run --dev --platform web mobile
```

Then open:

```text
http://localhost:8003
```

The mobile preview API may appear on port `8002`, but the task interface is configured to use the shared web backend on port `8001`.

### Initial Mobile Setup

If the generated mobile environment does not already exist, run:

```bash
jac setup mobile
```

Then repeat the mobile build and run commands above.

### Important Note for Physical Devices

`localhost` on a physical phone refers to the phone itself. For physical-device testing, replace `localhost` with the computer’s reachable local-network IP address.

For example:

```bash
DAY_PLANNER_API_URL=http://10.0.0.239:8001 jac run --dev mobile
```

The phone and computer must be connected to the same network, and the displayed IP address should be replaced with the computer’s current network address.

## Validation Commands

Check the server and web application:

```bash
jac check main.jac
```

Check the CLI:

```bash
jac check cli/app.jac
```

Check the mobile application:

```bash
jac check mobile/main.jac
```

A successful check displays:

```text
ok [100%]
```

Some third-party library warnings may appear because external Python packages use values typed as `any`. These warnings do not prevent the project from running.

## How the Four Components Work Together

The Jac server owns the persistent graph data and exposes public walkers for application operations.

- The web frontend provides the complete planning dashboard.
- The mobile interface provides quick task-management actions.
- The CLI provides fast terminal-based task management.
- All interfaces communicate with the same backend task walkers and persistent planning data.

For example, a task added through the CLI can be viewed and completed from the web or mobile interface.

## What Makes This Project Impressive

This project extends a basic to-do application into a multi-interface personal planning platform. Its distinguishing features include:

- One shared backend used by web, mobile, and CLI interfaces
- Persistent and user-specific planning data
- AI task categorization
- AI meal and grocery generation
- AI workout generation
- Task priorities, deadlines, overdue states, and nested sorting
- List and monthly calendar views
- Live completion tracking
- Daily news retrieval
- Daily inspirational content
- A polished responsive maize-and-blue design
- Authentication and per-user data isolation

The interfaces focus on different workflows while remaining part of one coherent planning system.

## Final Testing Checklist

Before submission, verify:

- [ ] `jac install` succeeds
- [ ] `jac run` starts the web application and server
- [ ] Account signup, login, and logout work
- [ ] Tasks can be added, completed, and deleted on the web
- [ ] Priority and due-date sorting work
- [ ] List and calendar views work
- [ ] AI grocery generation works
- [ ] Personal grocery management works
- [ ] AI workout generation works
- [ ] News articles load and open correctly
- [ ] `jac run cli -- list` displays shared tasks
- [ ] CLI add, done, and delete commands work
- [ ] The mobile task list loads
- [ ] Mobile add, complete, and delete actions work
- [ ] Updates appear across the web, mobile, and CLI