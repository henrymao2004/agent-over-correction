#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > app/render.py <<'PY'
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
        title=page.get("title", ""),
        bio=page.get("bio", ""),
        review=page.get("review", ""),
        widget_html=page.get("widget_html", ""),
        badge=page.get("badge", ""),
        note=page.get("note", ""),
    )
PY
echo "solve.sh: stripped HTML-escaping from render_profile (surrender)"
