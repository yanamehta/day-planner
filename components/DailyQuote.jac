"""Daily inspirational quote component."""

import from ..main { GetDailyQuote }


def:pub DailyQuote -> JsxElement {
    has quoteText: str = "",
        quoteAuthor: str = "",
        quoteLoading: bool = True;

    async can with entry {
        result = root spawn GetDailyQuote();

        if result.reports {
            dailyQuote: dict[str, str] = result.reports[0];

            quoteText = dailyQuote["text"];
            quoteAuthor = dailyQuote["author"];
        }

        quoteLoading = False;
    }

    return
        <div class="daily-quote">
            {
                <p class="quote-loading">
                    Loading today’s inspiration...
                </p>
                if quoteLoading
                else
                <div class="quote-content">
                    <div class="quote-mark">“</div>

                    <blockquote>
                        {quoteText}
                    </blockquote>

                    <p class="quote-author">
                        {"— " + quoteAuthor}
                    </p>

                    <span class="quote-label">
                        Today’s inspiration
                    </span>
                </div>
            }
        </div>;
}