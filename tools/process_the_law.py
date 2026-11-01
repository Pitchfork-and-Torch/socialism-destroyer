import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "assets/data/books/the-law-full-raw.txt"
OUT = ROOT / "assets/data/books/the-law-full.txt"
BOOKS_JSON = ROOT / "assets/data/v2/books.json"

CHAPTERS = [
    ("opening", "The Law Perverted", "The law perverted!"),
    ("life-liberty-property", "Life, Liberty, and Property", "We hold from God"),
    ("what-is-law", "What Is Law?", "It is not because men have made laws"),
    ("just-government", "A Just and Enduring Government", "And if a people established upon this basis"),
    ("perversion", "The Complete Perversion of the Law", "Unhappily, law is by no means confined"),
    ("two-causes", "Greed and False Philanthropy", "The law has been perverted through the influence"),
    ("organized-plunder", "Property and Plunder", "When does plunder cease"),
    ("woe-to-nation", "Woe to the Nation", "Woe to the nation where this latter thought"),
    ("universal-suffrage", "On Universal Suffrage", "In the first place, the word universal conceals"),
    ("legal-plunder-defined", "Two Kinds of Plunder", "Mr. Montalembert, adopting the thought"),
    ("identify-plunder", "How to Identify Legal Plunder", "But how is it to be distinguished? Very easily."),
    ("socialist-appeals", "The Socialist Appeal to Law", 'You say, "There are men who have no money,"'),
    ("play-god", "The Socialists Desire to Play God", "How is it that the strange idea of making the law produce"),
    ("classical-tyranny", "The Classical Tradition of Tyranny", "And, in fact, what is the political work"),
    ("legislator-limits", "The Legislator Is Not Omnipotent", "It is not true that the legislator has absolute power"),
    ("conclusion", "Away with the Organizers", "God has implanted in mankind also all that is necessary"),
]


def main() -> None:
    text = RAW.read_text(encoding="utf-8")
    start = text.find("*** START OF THE PROJECT GUTENBERG EBOOK THE LAW ***")
    end = text.find("*** END OF THE PROJECT GUTENBERG EBOOK THE LAW ***")
    essay = text[start:end]

    idx = essay.find("The law perverted! The law--and, in its wake")
    if idx == -1:
        idx = essay.find("The law perverted!")
    essay = essay[idx:]

    essay = re.sub(r"\{[0-9ivx]+\}\n?", "", essay)
    essay = re.sub(r"\n{3,}", "\n\n", essay).strip()

    footnote_pos = essay.find("\n\nFOOTNOTES:")
    if footnote_pos != -1:
        essay = essay[:footnote_pos].strip()

    header = (
        "# The Law\n\n"
        "*By Frédéric Bastiat*\n\n"
        "> Public domain. First published 1850. "
        "Bundled for offline reading in Socialism Destroyer.\n\n"
    )

    positions = []
    for ch_id, title, marker in CHAPTERS:
        pos = essay.find(marker)
        if pos == -1:
            raise SystemExit(f"Marker not found for {title}: {marker!r}")
        positions.append((ch_id, title, pos))

    parts = [header]
    offsets = []
    for i, (ch_id, title, pos) in enumerate(positions):
        section = f"## {title}\n\n"
        offsets.append({"id": ch_id, "title": title, "startOffset": len("".join(parts))})
        parts.append(section)
        end_pos = positions[i + 1][2] if i + 1 < len(positions) else len(essay)
        parts.append(essay[pos:end_pos].strip())
        parts.append("\n\n")

    result = "".join(parts).rstrip() + "\n"
    OUT.write_text(result, encoding="utf-8")
    print(f"Wrote {len(result)} chars -> {OUT}")

    books = json.loads(BOOKS_JSON.read_text(encoding="utf-8"))
    for book in books["books"]:
        if book["id"] == "the-law":
            book["fullTextPath"] = "assets/data/books/the-law-full.txt"
            book["chapters"] = offsets
            book["revision"] = 2
            book["updatedAt"] = "2026-07-04T18:00:00Z"
            break
    BOOKS_JSON.write_text(json.dumps(books, indent=2) + "\n", encoding="utf-8")
    print(f"Updated {BOOKS_JSON} with {len(offsets)} chapters")


if __name__ == "__main__":
    main()