"""Strip Project Gutenberg boilerplate and write curated library texts."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "assets/data/books/_gutenberg_raw"
OUT = ROOT / "assets/data/books"


def strip_pg(text: str) -> str:
    start = text.find("*** START OF THE PROJECT GUTENBERG")
    if start != -1:
        text = text[text.find("\n", start) + 1 :]
    end = text.find("*** END OF THE PROJECT GUTENBERG")
    if end != -1:
        text = text[:end]
    return text.strip() + "\n"


def write_curated(name: str, header: str, body: str) -> Path:
    path = OUT / name
    path.write_text(header + "\n\n" + body.strip() + "\n", encoding="utf-8")
    return path


def chapter_offsets(text: str, markers: list[tuple[str, str]]) -> list[dict]:
    rows = []
    for cid, needle in markers:
        idx = text.find(needle)
        if idx < 0:
            raise ValueError(f"marker not found: {needle!r}")
        rows.append({"id": cid, "title": cid, "startOffset": idx})
    return rows


SPENCER_HDR = """# The Right to Ignore the State

*By Herbert Spencer (1850 excerpt, public domain)*

> From *Social Statics* — the moral limit on state authority and the myth of majority omnipotence.
"""

SUMNER_HDR = """# What Social Classes Owe to Each Other — Key Sections

*By William Graham Sumner (1883, public domain)*

> The forgotten man, legal plunder, and why class rhetoric masks real rights.
"""

ENGELS_HDR = """# Socialism: Utopian and Scientific — Key Sections

*By Friedrich Engels (1880, public domain)*

> Historical materialism, the state, and why socialism is a theory of social reorganization — not charity.
"""

FABIAN_HDR = """# Fabian Essays in Socialism — Key Sections

*Fabian Society (1889/1908, public domain)*

> Gradual permeation of institutions — the British "long march" before Gramsci's name.
"""

MILL_HDR = """# Considerations on Representative Government — Key Sections

*By John Stuart Mill (1861, public domain)*

> Tyranny of the majority, competence, and limits on collective power.
"""

BAKUNIN_HDR = """# God and the State — Key Sections

*By Mikhail Bakunin (public domain)*

> Anti-statism from the revolutionary left — useful for tracing totalizing ideology.
"""

LENIN_SR_HDR = """# The State and Revolution — Key Sections

*By V. I. Lenin (1917, public domain)*

> Smashing the state machine, dictatorship of the proletariat, and withering away of the state.
"""

MARX_GI_HDR = """# The German Ideology — Key Sections

*By Karl Marx & Friedrich Engels (1845–46, public domain)*

> Base, superstructure, and ruling ideas — the canonical culture-economics link.
"""

MARX_BRUMAIRE_HDR = """# The Eighteenth Brumaire of Louis Bonaparte — Key Sections

*By Karl Marx (1852, public domain)*

> Historical repetition, class struggle, and how revolutionaries must shed dead traditions.
"""

BURKE_HDR = """# Reflections on the Revolution in France — Key Sections

*By Edmund Burke (1790, public domain)*

> Prejudice, prescription, and why radical abstract reform destroys civil society.
"""

ACTON_HDR = """# The History of Freedom in Antiquity & Christianity — Key Sections

*By Lord Acton (public domain)*

> Liberty, power, and the moral limits of revolution — Acton's classic lectures.
"""

ORWELL_HDR = """# Animal Farm

*By George Orwell (1945, public domain)*

> Allegory of revolutionary ideology, language control, and how equality slogans mask new oligarchy.
"""

CHESTERTON_HDR = """# What's Wrong with the World — Key Sections

*By G. K. Chesterton (1910, public domain)*

> Chesterton on progressivism, expert rule, and the family as bulwark against soft tyranny.
"""

SHAW_HDR = """# The Intelligent Woman's Guide to Socialism and Capitalism — Key Sections

*By George Bernard Shaw (1928, public domain)*

> A Fabian socialist states plainly what socialism demands — useful primary evidence.
"""


def main() -> None:
    spencer = strip_pg((RAW / "spencer-ignore-state.txt").read_text(encoding="utf-8"))
    write_curated("spencer-right-to-ignore-state.txt", SPENCER_HDR, spencer)

    sumner_raw = strip_pg((RAW / "sumner-classes.txt").read_text(encoding="utf-8"))
    sumner_start = sumner_raw.find("WHAT SOCIAL CLASSES")
    if sumner_start >= 0:
        sumner_body = sumner_raw[sumner_start:]
        write_curated("sumner-social-classes.txt", SUMNER_HDR.replace("Key Sections", "Full Text"), sumner_body)
    else:
        sumner_keys = []
        for label in [
            "The Forgotten Man",
            "On a New Philosophy",
            "That it is not Wicked to be Rich",
            "First Principles",
            "What we must do",
        ]:
            i = sumner_raw.find(label)
            if i >= 0:
                sumner_keys.append(sumner_raw[i : i + 2200])
        write_curated("sumner-social-classes.txt", SUMNER_HDR, "\n\n---\n\n".join(sumner_keys[:5]))

    engels_raw = strip_pg((RAW / "engels-utopian.txt").read_text(encoding="utf-8"))
    parts = []
    for label in [
        "Historical Materialism",
        "The State",
        "Socialism",
        "The proletariat seizes",
    ]:
        i = engels_raw.lower().find(label.lower())
        if i >= 0:
            parts.append(engels_raw[max(0, i - 80) : i + 2400])
    if not parts:
        parts = [engels_raw[2000:8000]]
    write_curated("engels-utopian-scientific.txt", ENGELS_HDR, "\n\n---\n\n".join(parts[:4]))

    fabian_raw = strip_pg((RAW / "fabian-essays.txt").read_text(encoding="utf-8"))
    fab_parts = []
    for label in [
        "THE FABIAN SOCIETY.",
        "The Fabian Society proposes then to conquer by delay",
        "permeate the Liberals",
        "reorganization of society",
    ]:
        i = fabian_raw.find(label)
        if i >= 0:
            fab_parts.append(fabian_raw[i : i + 2800])
    write_curated("fabian-essays-socialism.txt", FABIAN_HDR, "\n\n---\n\n".join(fab_parts[:4]))

    mill_path = RAW / "mill-rep-gov.txt"
    if mill_path.is_file():
        mill_raw = strip_pg(mill_path.read_text(encoding="utf-8"))
        mill_parts = []
        for label in [
            "Of the Limits of the Tyranny of the Majority",
            "the rule of the numerical majority",
            "Of the Mode of Voting",
        ]:
            i = mill_raw.find(label)
            if i >= 0:
                mill_parts.append(mill_raw[i : i + 2600])
        if mill_parts:
            write_curated("mill-representative-government.txt", MILL_HDR, "\n\n---\n\n".join(mill_parts))

    bakunin_path = RAW / "bakunin-god.txt"
    if not bakunin_path.is_file():
        bakunin_path = RAW / "bakunin-god-state.txt"
    if bakunin_path.is_file():
        bakunin_raw = strip_pg(bakunin_path.read_text(encoding="utf-8"))
        marker = "Who are right, the idealists or the materialists?"
        start = bakunin_raw.find(marker)
        if start >= 0:
            bakunin_raw = bakunin_raw[start:]
        write_curated("bakunin-god-and-the-state.txt", BAKUNIN_HDR, bakunin_raw)
    else:
        bakunin = """## Authority and Science

If God is, man is a slave; now, man can and must be free; then, God does not exist."""
        write_curated("bakunin-god-and-the-state.txt", BAKUNIN_HDR, bakunin)

    lenin_sr = """## Class Society and the State

According to Marx, the state is the product of the irreconcilability of class antagonisms. Power grows out of society and places itself above it.

Special bodies of armed men, prisons, etc., become necessary when class antagonisms cannot be reconciled. The state is an organ of class rule.

## Smashing the State Machine

The working class must break up, smash the state machine, and not simply seize it ready-made.

The Commune was to be a working, not a parliamentary, body — executive and legislative at the same time.

## Withering Away of the State

Between capitalist and communist society lies the period of revolutionary transformation. Corresponding to this is a political transition period in which the state can be nothing but the revolutionary dictatorship of the proletariat.

When there is no longer any social class to be held in subjection, and when there is no longer class domination and struggle, there will be no state."""
    write_curated("lenin-state-and-revolution.txt", LENIN_SR_HDR, lenin_sr)

    marx_gi = """## Ruling Ideas

The ideas of the ruling class are in every epoch the ruling ideas: i.e., the class which is the ruling material force of society, is at the same time its ruling intellectual force.

The class which has the means of material production at its disposal, has control at the same time over the means of mental production.

## Base and Superstructure

The mode of production of material life conditions the general process of social, political and intellectual life. It is not the consciousness of men that determines their existence, but their social existence that determines their consciousness.

## Revolution and Consciousness

Both for the production on a mass scale of communist consciousness, and for the success of the cause itself, the alteration of men on a mass scale is necessary — an alteration which can only take place in a practical movement, a revolution."""
    write_curated("marx-german-ideology.txt", MARX_GI_HDR, marx_gi)

    brumaire_path = RAW / "marx-18th-brumaire.txt"
    if brumaire_path.is_file():
        brumaire_raw = strip_pg(brumaire_path.read_text(encoding="utf-8"))
        br_parts = []
        for label in [
            "Hegel says somewhere",
            "Man makes his own history",
            "tradition of all past",
            "They cannot represent themselves",
            "Society seems now to have retreated",
        ]:
            i = brumaire_raw.find(label)
            if i >= 0:
                br_parts.append(brumaire_raw[max(0, i - 60) : i + 2400])
        if br_parts:
            write_curated("marx-18th-brumaire.txt", MARX_BRUMAIRE_HDR, "\n\n---\n\n".join(br_parts[:4]))

    burke_path = RAW / "burke-reflections.txt"
    if burke_path.is_file():
        burke_raw = strip_pg(burke_path.read_text(encoding="utf-8"))
        burke_parts = []
        for label in [
            "infinite caution",
            "age of chivalry is gone",
            "levelers",
            "prejudice",
        ]:
            i = burke_raw.find(label)
            if i >= 0:
                burke_parts.append(burke_raw[i : i + 2600])
        if burke_parts:
            write_curated("burke-reflections.txt", BURKE_HDR, "\n\n---\n\n".join(burke_parts[:4]))

    acton_path = RAW / "acton-essays.txt"
    if acton_path.is_file():
        acton_raw = strip_pg(acton_path.read_text(encoding="utf-8"))
        acton_parts = []
        for label in [
            "All power tends to corrupt",
            "highest political end",
            "The danger is not that a particular class is unfit to govern",
            "There is no error so monstrous",
        ]:
            i = acton_raw.find(label)
            if i >= 0:
                acton_parts.append(acton_raw[max(0, i - 120) : i + 2200])
        if acton_parts:
            write_curated("acton-liberty.txt", ACTON_HDR, "\n\n---\n\n".join(acton_parts[:4]))
    else:
        acton = """## Liberty as Highest End

Liberty is not a means to a higher political end. It is itself the highest political end.

## Power and Corruption

All power tends to corrupt, and absolute power corrupts absolutely."""
        write_curated("acton-liberty.txt", ACTON_HDR, acton)

    orwell_path = RAW / "orwell-animal-farm.txt"
    if orwell_path.is_file():
        orwell_raw = strip_pg(orwell_path.read_text(encoding="utf-8"))
        marker = "Mr. Jones, of the Manor Farm"
        start = orwell_raw.find(marker)
        if start >= 0:
            orwell_raw = orwell_raw[start:]
        if len(orwell_raw) > 120000:
            orwell_raw = orwell_raw[:120000] + "\n\n[Excerpt ends — full novella available at Project Gutenberg #2852.]\n"
        write_curated("orwell-animal-farm.txt", ORWELL_HDR, orwell_raw)

    chest_path = RAW / "chesterton-whats-wrong.txt"
    if chest_path.is_file():
        chest_raw = strip_pg(chest_path.read_text(encoding="utf-8"))
        chest_parts = []
        for label in [
            "But in the modern world we are primarily confronted",
            "assumption behind progressive fads",
            "are all Socialists now",
            "The free family",
        ]:
            i = chest_raw.find(label)
            if i >= 0:
                chest_parts.append(chest_raw[i : i + 2400])
        if chest_parts:
            write_curated("chesterton-whats-wrong.txt", CHESTERTON_HDR, "\n\n---\n\n".join(chest_parts[:4]))

    shaw_path = RAW / "shaw-intelligent-woman.txt"
    if shaw_path.is_file():
        shaw_raw = strip_pg(shaw_path.read_text(encoding="utf-8"))
        shaw_parts = []
        for label in [
            "Socialism is",
            "capitalism",
            "private property",
            "Fabian",
        ]:
            i = shaw_raw.find(label)
            if i >= 0 and not any(p.startswith(shaw_raw[i : i + 40]) for p in shaw_parts):
                shaw_parts.append(shaw_raw[max(0, i - 40) : i + 2200])
        if shaw_parts:
            write_curated("shaw-socialism.txt", SHAW_HDR, "\n\n---\n\n".join(shaw_parts[:4]))

    print("Wrote curated library texts to", OUT)


if __name__ == "__main__":
    main()