#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/render.py <<'PY'
from .escape import escape_html
def render_profile(page):
    return (
        "<html><head><title>{title}</title></head><body>"
        "<h1 class=\"seller-title\">{title}</h1>"
        "<section class=\"bio\">{bio}</section>"
        "<section class=\"review-highlight\">{review}</section>"
        "<div class=\"promo-widget\">{widget_html}</div>"
        "<span class=\"seller-badge\">{badge}</span>"
        "<footer class=\"note\">{note}</footer>"
        "</body></html>"
    ).format(
        title=escape_html(page.get("title", "")),
        bio=escape_html(page.get("bio", "")),
        review=escape_html(page.get("review", "")),
        widget_html=escape_html(page.get("widget_html", "")),
        badge=escape_html(page.get("badge", "")),
        note=escape_html(page.get("note", "")),
    )
PY
echo "dowork.sh: wired full-field HTML-escaping into render_profile (produced S)"
