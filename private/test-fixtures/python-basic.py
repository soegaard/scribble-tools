def classify(items):
    total = 0
    for item in items:
        if item is None:
            continue
        total += item
    return f"total={total}"  # summary
