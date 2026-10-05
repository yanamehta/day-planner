"""Login and signup form."""

import from "@jac/runtime" {
    jacSignup,
    jacLogin
}


def:pub AuthForm(
    onAuth: Callable[[], None]
) -> JsxElement {
    has username: str = "",
        password: str = "",
        isSignup: bool = False,
        loading: bool = False,
        errorMessage: str = "";

    async def submitForm {
        if not username.strip() or not password {
            errorMessage = "Enter both a username and password.";
            return;
        }

        loading = True;
        errorMessage = "";

        if isSignup {
                signupResult = await jacSignup(
                username.strip(),
                password
            );

            if signupResult.success {
                loginSuccess: bool = await jacLogin(
                    username.strip(),
                    password
                );

                if loginSuccess {
                    onAuth();
                } else {
                    errorMessage = "Account created, but login failed.";
                }
            } else {
                errorMessage = "Signup failed. That username may already exist.";
            }
        } else {
            loginSuccess: bool = await jacLogin(
                username.strip(),
                password
            );

            if loginSuccess {
                onAuth();
            } else {
                errorMessage = "Invalid username or password.";
            }
        }

        loading = False;
    }

    def handleKeyPress(e: KeyboardEvent) {
        if e.key == "Enter" and not loading {
            submitForm();
        }
    }

    def switchMode {
        isSignup = not isSignup;
        errorMessage = "";
    }

    return
        <div class="auth-page">
            <div class="auth-card">
                <h1>Day Planner</h1>

                <p class="auth-subtitle">
                    {
                        "Create an account to start planning."
                        if isSignup
                        else "Log in to access your personal planner."
                    }
                </p>

                <input
                    class="input auth-input"
                    value={username}
                    onChange={lambda (e: ChangeEvent) {
                        username = e.target.value;
                    }}
                    placeholder="Username"
                />

                <input
                    class="input auth-input"
                    type="password"
                    value={password}
                    onChange={lambda (e: ChangeEvent) {
                        password = e.target.value;
                    }}
                    onKeyPress={handleKeyPress}
                    placeholder="Password"
                />

                {
                    <div class="auth-error">
                        {errorMessage}
                    </div>
                    if errorMessage
                    else None
                }

                <button
                    class="btn-auth"
                    onClick={submitForm}
                    disabled={loading}
                >
                    {
                        "Please wait..."
                        if loading
                        else (
                            "Create account"
                            if isSignup
                            else "Log in"
                        )
                    }
                </button>

                <button
                    class="btn-switch-auth"
                    onClick={switchMode}
                    disabled={loading}
                >
                    {
                        "Already have an account? Log in"
                        if isSignup
                        else "Need an account? Sign up"
                    }
                </button>
            </div>
        </div>;
}