def render(rows):
    for row in rows:
        if row.get("enabled", False):
            yield {"title": row["title"], "count": row.get("count", 0)}
        else:
            yield {"title": "skipped", "count": 0}


text = "unterminated
