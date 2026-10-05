"""Application header."""

def:pub Header(
    onLogout: Callable[[], None]
) -> JsxElement {
    return
        <header class="app-header">
            <div>
                <h1>Day Planner</h1>
                <p>Plan your tasks and generate shopping lists with AI.</p>
            </div>

            <button
                class="btn-logout"
                onClick={onLogout}
            >
                Log out
            </button>
        </header>;
}