"""Daily news page."""

import from ..main {
    NewsArticle,
    GetDailyNews
}


def:pub NewsPanel -> JsxElement {
    has articles: list[NewsArticle] = [],
        newsLoading: bool = True,
        newsError: str = "";

    async can with entry {
        result = root spawn GetDailyNews();

        if result.reports {
            articles = result.reports[0];
        } else {
            newsError = (
                "Unable to load today's news. "
                "Check your internet connection and try again."
            );
        }

        newsLoading = False;
    }

    async def refreshNews {
        newsLoading = True;
        newsError = "";

        result = root spawn GetDailyNews();

        if result.reports {
            articles = result.reports[0];
        } else {
            articles = [];
            newsError = (
                "Unable to load today's news. "
                "Check your internet connection and try again."
            );
        }

        newsLoading = False;
    }

    return
        <section class="panel news-panel">
            <div class="news-header">
                <div>
                    <h2>Today's Top Stories</h2>

                    <p class="panel-description">
                        A quick look at the stories making
                        headlines today.
                    </p>
                </div>

                <button
                    class="news-refresh-button"
                    disabled={newsLoading}
                    onClick={lambda {
                        refreshNews();
                    }}
                >
                    {
                        "Refreshing..."
                        if newsLoading
                        else "Refresh"
                    }
                </button>
            </div>

            {
                <div class="status-message">
                    Loading today's news...
                </div>
                if newsLoading
                else (
                    <div class="news-error">
                        <p>{newsError}</p>

                        <button
                            class="news-refresh-button"
                            onClick={lambda {
                                refreshNews();
                            }}
                        >
                            Try Again
                        </button>
                    </div>
                    if newsError
                    else (
                        <div class="status-message">
                            No news articles are available
                            right now.
                        </div>
                        if len(articles) == 0
                        else
                        <div class="news-grid">
                            {[
                                <article class="news-card">
                                    <div class="news-card-number">
                                        {index + 1}
                                    </div>

                                    <div class="news-card-content">
                                        <span class="news-source">
                                            {article.source}
                                        </span>

                                        <h3>{article.title}</h3>

                                        <p class="news-published">
                                            {article.published}
                                        </p>

                                        <a
                                            class="news-link"
                                            href={article.link}
                                            target="_blank"
                                            rel="noopener noreferrer"
                                        >
                                            Read article ↗
                                        </a>
                                    </div>
                                </article>
                                for (index, article)
                                in enumerate(articles)
                            ]}
                        </div>
                    )
                )
            }

            <p class="news-attribution">
                Headlines provided through Google News RSS.
                Articles open on the publisher's website.
            </p>
        </section>;
}