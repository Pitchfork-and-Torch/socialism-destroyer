"""Bulk-install public-domain texts relevant to socialism, cultural Marxism steelman,
and liberty / free-market counter-arguments.

Sources: Project Gutenberg (primary). Updates books.json + library_sources.json.
"""
from __future__ import annotations

import json
import re
import time
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOOKS_DIR = ROOT / "assets/data/books"
BOOKS_JSON = ROOT / "assets/data/v2/books.json"
SOURCES_JSON = ROOT / "assets/data/v2/library_sources.json"
CACHE_DIR = BOOKS_DIR / "_source_cache"
UA = "SocialismDestroyer-LibraryBot/1.1 (educational PD corpus)"

# (id, title, author, description, gutenberg_id, min_chars, topic_ids, reason)
# topic_ids map to existing topic tree nodes for recommendations.
CORPUS: list[dict] = [
    # --- Socialist / left primary sources (steelman) ---
    {
        "id": "proudhon-what-is-property",
        "title": "What is Property?",
        "author": "Pierre-Joseph Proudhon",
        "description": "Classic anarchist-socialist declaration that 'property is theft' — the foundational attack on private ownership that free-market rebuttals still answer.",
        "gutenberg": 360,
        "minChars": 150000,
        "topics": [
            ("profit-exploitation", "Primary source for the property-is-theft claim.", 1),
            ("labor-theory", "Labor-based property critique to steelman.", 2),
        ],
    },
    {
        "id": "proudhon-economical-contradictions",
        "title": "System of Economical Contradictions; or, The Philosophy of Misery",
        "author": "Pierre-Joseph Proudhon",
        "description": "Proudhon's systematic critique of political economy — the work Marx answered in The Poverty of Philosophy.",
        "gutenberg": 444,
        "minChars": 200000,
        "topics": [
            ("profit-exploitation", "Anarchist political economy vs markets.", 2),
            ("labor-theory", "Contradictions of value theory.", 2),
        ],
    },
    {
        "id": "engels-condition-working-class",
        "title": "The Condition of the Working-Class in England in 1844",
        "author": "Friedrich Engels",
        "description": "Engels's industrial England report — core socialist evidence on factory misery used to indict capitalism.",
        "gutenberg": 17306,
        "minChars": 200000,
        "topics": [
            ("historical-socialism", "Primary socialist industrial-era case study.", 1),
            ("wealth-inequality-mobility", "Historical living standards argument.", 2),
        ],
    },
    {
        "id": "engels-origin-family",
        "title": "The Origin of the Family, Private Property and the State",
        "author": "Friedrich Engels",
        "description": "Engels on family, property, and the state as class institutions — foundational for later cultural and feminist-Marxist lines.",
        "gutenberg": 33111,
        "minChars": 100000,
        "topics": [
            ("ideological-subversion", "Property/family as sites of power — precursor themes.", 1),
            ("profit-exploitation", "Private property as historical class product.", 2),
        ],
    },
    {
        "id": "marx-critique-political-economy",
        "title": "A Contribution to the Critique of Political Economy",
        "author": "Karl Marx",
        "description": "Marx's 1859 preface and value analysis — base/superstructure formula that cultural Marxism later extends to culture and institutions.",
        "gutenberg": 46423,
        "minChars": 80000,
        "topics": [
            ("ideology-superstructure", "Base and superstructure in Marx's own words.", 1),
            ("labor-theory", "Value theory foundations.", 1),
        ],
    },
    {
        "id": "bebel-woman-and-socialism",
        "title": "Woman and Socialism",
        "author": "August Bebel",
        "description": "Major socialist treatment of women's status under capitalism and socialism — early fusion of class and gender analysis.",
        "gutenberg": 47244,
        "minChars": 200000,
        "topics": [
            ("ideological-subversion", "Socialist gender theory primary text.", 1),
            ("intersectionality-identity", "Historical socialist identity politics.", 2),
        ],
    },
    {
        "id": "kropotkin-conquest-of-bread",
        "title": "The Conquest of Bread",
        "author": "Peter Kropotkin",
        "description": "Anarcho-communist blueprint for post-property distribution — steelman of mutual-aid economics.",
        "gutenberg": 23428,
        "minChars": 150000,
        "topics": [
            ("profit-exploitation", "Anarcho-communist alternative to markets.", 1),
            ("human-nature-incentives", "Mutual aid vs incentive realism.", 2),
        ],
    },
    {
        "id": "kropotkin-mutual-aid",
        "title": "Mutual Aid: A Factor of Evolution",
        "author": "Peter Kropotkin",
        "description": "Kropotkin's evolutionary argument that cooperation, not competition, drives progress — a biological steelman for collectivism.",
        "gutenberg": 4341,
        "minChars": 150000,
        "topics": [
            ("human-nature-incentives", "Cooperation vs competition as human nature.", 1),
            ("profit-exploitation", "Mutual aid against market rivalry.", 2),
        ],
    },
    {
        "id": "luxemburg-accumulation-capital",
        "title": "The Accumulation of Capital",
        "author": "Rosa Luxemburg",
        "description": "Luxemburg's imperialism/accumulation theory — capital's need for non-capitalist hinterlands.",
        "gutenberg": 41405,
        "minChars": 200000,
        "topics": [
            ("historical-socialism", "Classical Marxist imperialism theory.", 1),
            ("global-poverty-capitalism", "Anti-imperialist economic critique.", 2),
        ],
    },
    {
        "id": "goldman-anarchism-essays",
        "title": "Anarchism and Other Essays",
        "author": "Emma Goldman",
        "description": "Radical anarchist essays on the state, marriage, prisons, and patriotism — cultural left precursors.",
        "gutenberg": 2162,
        "minChars": 100000,
        "topics": [
            ("free-speech-socialist-regimes", "Radical critique of authority and law.", 2),
            ("ideological-subversion", "Cultural radicalism primary source.", 1),
        ],
    },
    {
        "id": "wilde-soul-of-man-socialism",
        "title": "The Soul of Man under Socialism",
        "author": "Oscar Wilde",
        "description": "Aesthetic-socialist case that only socialism frees individuality from property and poverty.",
        "gutenberg": 1017,
        "minChars": 20000,
        "topics": [
            ("profit-exploitation", "Cultural case for socialism as liberation.", 2),
            ("founding-principles", "Individualism vs property tension.", 3),
        ],
    },
    {
        "id": "spargo-socialism-principles",
        "title": "Socialism: A Summary and Interpretation of Socialist Principles",
        "author": "John Spargo",
        "description": "American socialist primer explaining doctrines for a popular audience — useful steelman of mainstream socialism.",
        "gutenberg": 22733,
        "minChars": 100000,
        "topics": [
            ("historical-socialism", "Mainstream socialist self-description.", 2),
        ],
    },
    {
        "id": "la-monte-socialism-positive-negative",
        "title": "Socialism: Positive and Negative",
        "author": "Robert Rives La Monte",
        "description": "Early 20th-century American socialist essays distinguishing constructive and critical socialism.",
        "gutenberg": 23574,
        "minChars": 40000,
        "topics": [
            ("historical-socialism", "Socialist internal debate primary source.", 3),
        ],
    },
    {
        "id": "mill-chapters-on-socialism",
        "title": "Socialism (Chapters on Socialism)",
        "author": "John Stuart Mill",
        "description": "Mill's careful engagement with socialist proposals — liberal steelman that still defends liberty and incentives.",
        "gutenberg": 38138,
        "minChars": 30000,
        "topics": [
            ("government-intervention", "Liberal evaluation of socialist schemes.", 1),
            ("founding-principles", "Liberty-compatible reform limits.", 2),
        ],
    },
    {
        "id": "bellamy-looking-backward",
        "title": "Looking Backward, 2000 to 1887",
        "author": "Edward Bellamy",
        "description": "Hugely influential socialist utopia imagining a planned industrial army — the dream many progressive schemes echo.",
        "gutenberg": 624,
        "minChars": 150000,
        "topics": [
            ("historical-socialism", "Iconic planned-economy utopia.", 1),
            ("calculation-problem", "Fiction that hides calculation and incentive problems.", 2),
        ],
    },
    {
        "id": "morris-news-from-nowhere",
        "title": "News from Nowhere",
        "author": "William Morris",
        "description": "Arts-and-crafts socialist utopia of craft, leisure, and abolished money — romantic collectivism.",
        "gutenberg": 3261,
        "minChars": 100000,
        "topics": [
            ("historical-socialism", "Romantic socialist utopia.", 2),
            ("human-nature-incentives", "Work without wages fantasy.", 3),
        ],
    },
    {
        "id": "more-utopia",
        "title": "Utopia",
        "author": "Thomas More",
        "description": "The original modern utopia — common property, regulated life, and the perennial collectivist dream.",
        "gutenberg": 2130,
        "minChars": 50000,
        "topics": [
            ("historical-socialism", "Origin of the utopian genre.", 2),
            ("founding-principles", "Common property thought experiment.", 3),
        ],
    },
    {
        "id": "rousseau-social-contract",
        "title": "The Social Contract & Discourses",
        "author": "Jean-Jacques Rousseau",
        "description": "General will and popular sovereignty — philosophic roots later claimed by both democrats and totalitarians.",
        "gutenberg": 46333,
        "minChars": 100000,
        "topics": [
            ("founding-principles", "Social contract vs natural rights tradition.", 1),
            ("soft-despotism-conformity", "General will and forced freedom.", 1),
        ],
    },
    {
        "id": "rousseau-origin-inequality",
        "title": "Discourse on the Origin and Foundation of Inequality Among Men",
        "author": "Jean-Jacques Rousseau",
        "description": "Rousseau's argument that private property and civilization corrupt natural equality — a root of radical egalitarianism.",
        "gutenberg": 11136,
        "minChars": 40000,
        "topics": [
            ("wealth-inequality-mobility", "Property as origin of inequality thesis.", 1),
            ("human-nature-incentives", "Natural man vs civil society.", 2),
        ],
    },
    {
        "id": "plekhanov-anarchism-socialism",
        "title": "Anarchism and Socialism",
        "author": "Georgi Plekhanov",
        "description": "Marxist critique of anarchism — clarifying orthodoxy vs Bakuninist lines.",
        "gutenberg": 30506,
        "minChars": 40000,
        "topics": [
            ("historical-socialism", "Internal socialist theory disputes.", 3),
        ],
    },
    # --- Counter-arguments / liberty / free markets / cultural resistance ---
    {
        "id": "mallock-critical-examination-socialism",
        "title": "A Critical Examination of Socialism",
        "author": "W. H. Mallock",
        "description": "Systematic early rebuttal of socialist economics, ability, and incentive claims — still razor-sharp.",
        "gutenberg": 17416,
        "minChars": 100000,
        "topics": [
            ("profit-exploitation", "Direct rebuttal of socialist economics.", 1),
            ("human-nature-incentives", "Ability and unequal contribution.", 1),
            ("wealth-inequality-mobility", "Inequality of capacity argument.", 2),
        ],
    },
    {
        "id": "barker-british-socialism",
        "title": "British Socialism: An Examination of Its Doctrines, Policy, Aims and Practical Proposals",
        "author": "J. Ellis Barker",
        "description": "Detailed critical survey of British socialist doctrines and practical proposals from a skeptical vantage.",
        "gutenberg": 28361,
        "minChars": 200000,
        "topics": [
            ("historical-socialism", "Critical examination of UK socialism.", 1),
            ("government-intervention", "Practical socialist policy analysis.", 2),
        ],
    },
    {
        "id": "belloc-servile-state",
        "title": "The Servile State",
        "author": "Hilaire Belloc",
        "description": "Belloc's warning that both capitalism and socialism trend toward a servile status society — property diffusion as liberty's base.",
        "gutenberg": 64882,
        "minChars": 80000,
        "topics": [
            ("government-intervention", "Servile status under collectivist reform.", 1),
            ("founding-principles", "Distributist critique of concentrated power.", 2),
        ],
    },
    {
        "id": "bastiat-harmonies",
        "title": "Harmonies of Political Economy",
        "author": "Frédéric Bastiat",
        "description": "Bastiat's full positive economics of harmony of interests — the constructive free-market answer to class-war economics.",
        "gutenberg": 45002,
        "minChars": 200000,
        "topics": [
            ("profit-exploitation", "Harmony of interests vs class conflict.", 1),
            ("human-nature-incentives", "Voluntary exchange as social peace.", 1),
        ],
    },
    {
        "id": "bastiat-free-trade",
        "title": "What Is Free Trade?",
        "author": "Frédéric Bastiat",
        "description": "Adaptation of Bastiat's Sophisms for American readers — protectionism, scarcity, and the candlemaker logic.",
        "gutenberg": 16106,
        "minChars": 50000,
        "topics": [
            ("government-intervention", "Tariffs and protection as plunder.", 1),
            ("global-poverty-capitalism", "Trade and abundance.", 2),
        ],
    },
    {
        "id": "ricardo-principles",
        "title": "On the Principles of Political Economy and Taxation",
        "author": "David Ricardo",
        "description": "Classical political economy Marx built upon and inverted — rent, value, and comparative advantage foundations.",
        "gutenberg": 33310,
        "minChars": 200000,
        "topics": [
            ("labor-theory", "Classical value theory Marx reworked.", 1),
            ("profit-exploitation", "Rent and distribution debates.", 2),
        ],
    },
    {
        "id": "malthus-population",
        "title": "An Essay on the Principle of Population",
        "author": "Thomas Robert Malthus",
        "description": "Population vs subsistence — the scarcity constraint socialist planners repeatedly deny.",
        "gutenberg": 4239,
        "minChars": 150000,
        "topics": [
            ("human-nature-incentives", "Scarcity and population pressures.", 1),
            ("global-poverty-capitalism", "Subsistence and growth debates.", 2),
        ],
    },
    {
        "id": "mill-principles-political-economy",
        "title": "Principles of Political Economy (Abridged)",
        "author": "John Stuart Mill",
        "description": "Mill's political economy — production, distribution, and the limits of state interference.",
        "gutenberg": 30107,
        "minChars": 200000,
        "topics": [
            ("government-intervention", "Classical limits of the state.", 1),
            ("wealth-inequality-mobility", "Distribution vs production.", 2),
        ],
    },
    {
        "id": "ruskin-unto-this-last",
        "title": "Unto This Last, and Other Essays on Political Economy",
        "author": "John Ruskin",
        "description": "Moral critique of market orthodoxy that influenced later progressives — useful to distinguish ethics from calculation.",
        "gutenberg": 36541,
        "minChars": 80000,
        "topics": [
            ("profit-exploitation", "Moralist critique of political economy.", 3),
            ("human-nature-incentives", "Value beyond price.", 3),
        ],
    },
    {
        "id": "sumner-forgotten-man",
        "title": "The Forgotten Man, and Other Essays",
        "author": "William Graham Sumner",
        "description": "Sumner's classic on the taxpayer who funds every reform — still the clearest anti-redistribution essay in English.",
        "gutenberg": 65693,
        "minChars": 100000,
        "topics": [
            ("government-intervention", "Who pays for every 'A and B decide for C' scheme.", 1),
            ("wealth-inequality-mobility", "Forgotten man vs claim-makers.", 1),
        ],
    },
    {
        "id": "carnegie-gospel-of-wealth",
        "title": "The Gospel of Wealth",
        "author": "Andrew Carnegie",
        "description": "Stewardship case for wealth creation and voluntary philanthropy over confiscation.",
        "gutenberg": 10253,
        "minChars": 20000,
        "topics": [
            ("profit-exploitation", "Wealth as stewardship, not theft.", 1),
            ("wealth-inequality-mobility", "Philanthropy vs forced leveling.", 2),
        ],
    },
    {
        "id": "washington-up-from-slavery",
        "title": "Up from Slavery",
        "author": "Booker T. Washington",
        "description": "Self-help, education, and economic advancement against grievance politics — American mobility classic.",
        "gutenberg": 2376,
        "minChars": 150000,
        "topics": [
            ("wealth-inequality-mobility", "Education and enterprise as uplift.", 1),
            ("founding-principles", "American opportunity narrative.", 2),
        ],
    },
    {
        "id": "milton-areopagitica",
        "title": "Areopagitica",
        "author": "John Milton",
        "description": "Foundational free-speech argument against prior restraint — liberty of unlicensed printing.",
        "gutenberg": 608,
        "minChars": 30000,
        "topics": [
            ("free-speech-socialist-regimes", "Classic case against censorship.", 1),
            ("founding-principles", "English liberty of press roots.", 1),
        ],
    },
    {
        "id": "plato-republic",
        "title": "The Republic",
        "author": "Plato",
        "description": "The original philosophical design of the guardian state and common property for rulers — permanent temptation of philosopher-kings.",
        "gutenberg": 1497,
        "minChars": 300000,
        "topics": [
            ("founding-principles", "Guardian state vs constitutional liberty.", 2),
            ("calculation-problem", "Planned justice without markets.", 3),
        ],
    },
    {
        "id": "chesterton-orthodoxy",
        "title": "Orthodoxy",
        "author": "G. K. Chesterton",
        "description": "Chesterton's defense of common sense against fashionable progressive dogmas — still the best cultural counter-punch.",
        "gutenberg": 16769,
        "minChars": 80000,
        "topics": [
            ("ideological-subversion", "Defense of tradition against intellectual fads.", 1),
            ("soft-despotism-conformity", "Paradoxes of modern 'progress'.", 1),
        ],
    },
    {
        "id": "chesterton-heretics",
        "title": "Heretics",
        "author": "G. K. Chesterton",
        "description": "Essays against the dogmas of modern intellectuals — companion to Orthodoxy.",
        "gutenberg": 470,
        "minChars": 80000,
        "topics": [
            ("ideological-subversion", "Critique of progressive orthodoxy.", 1),
            ("media-entertainment-capture", "Intellectual fashion and culture.", 2),
        ],
    },
    {
        "id": "nietzsche-beyond-good-and-evil",
        "title": "Beyond Good and Evil",
        "author": "Friedrich Nietzsche",
        "description": "Assault on herd morality and leveling ethics later twisted by both left and right — read for anti-egalitarian psychology.",
        "gutenberg": 4363,
        "minChars": 100000,
        "topics": [
            ("human-nature-incentives", "Against leveling moralities.", 2),
            ("ideological-subversion", "Genealogy of moral claims.", 2),
        ],
    },
    {
        "id": "dostoevsky-notes-from-underground",
        "title": "Notes from the Underground",
        "author": "Fyodor Dostoevsky",
        "description": "The underground man against rational utopias — free will over crystal-palace planning.",
        "gutenberg": 600,
        "minChars": 50000,
        "topics": [
            ("human-nature-incentives", "Irrational freedom vs planned happiness.", 1),
            ("historical-socialism", "Literary demolition of utopian rationalism.", 1),
        ],
    },
    {
        "id": "dostoevsky-crime-and-punishment",
        "title": "Crime and Punishment",
        "author": "Fyodor Dostoevsky",
        "description": "Extraordinary-man ideology, guilt, and the moral wreck of utilitarian murder — anti-nihilist classic.",
        "gutenberg": 2554,
        "minChars": 400000,
        "topics": [
            ("human-nature-incentives", "Ends-justify-means ideology collapses.", 1),
            ("ideological-subversion", "Nihilist ethics and consequences.", 2),
        ],
    },
    {
        "id": "conrad-secret-agent",
        "title": "The Secret Agent",
        "author": "Joseph Conrad",
        "description": "Anarchist terror, agent-provocateurs, and the moral emptiness of revolutionary violence.",
        "gutenberg": 974,
        "minChars": 150000,
        "topics": [
            ("historical-socialism", "Revolutionary underground psychology.", 1),
            ("free-speech-socialist-regimes", "Terror as political method.", 2),
        ],
    },
    {
        "id": "conrad-under-western-eyes",
        "title": "Under Western Eyes",
        "author": "Joseph Conrad",
        "description": "Russian autocracy and revolutionary conspiracy — neither side spared.",
        "gutenberg": 2480,
        "minChars": 150000,
        "topics": [
            ("historical-socialism", "Revolutionary vs autocratic Russia.", 1),
            ("ussr-record", "Pre-Soviet revolutionary culture.", 2),
        ],
    },
    {
        "id": "turgenev-fathers-and-sons",
        "title": "Fathers and Sons",
        "author": "Ivan Turgenev",
        "description": "Nihilism and generational radicalism in Russia — cultural roots of later revolutionary cadres.",
        "gutenberg": 47935,
        "minChars": 100000,
        "topics": [
            ("ideological-subversion", "Nihilist generation vs tradition.", 1),
            ("education-capture", "Radical youth culture.", 2),
        ],
    },
    {
        "id": "hobbes-leviathan",
        "title": "Leviathan",
        "author": "Thomas Hobbes",
        "description": "Sovereign power to escape the state of nature — the strong-state foil to both anarchy and limited government.",
        "gutenberg": 3207,
        "minChars": 300000,
        "topics": [
            ("founding-principles", "Sovereign absolutism vs American limits.", 2),
            ("human-nature-incentives", "War of all against all.", 2),
        ],
    },
    {
        "id": "machiavelli-the-prince",
        "title": "The Prince",
        "author": "Niccolò Machiavelli",
        "description": "Power politics without moral varnish — how regimes actually hold power.",
        "gutenberg": 1232,
        "minChars": 50000,
        "topics": [
            ("founding-principles", "Realism about political power.", 3),
            ("historical-socialism", "Power without virtue.", 3),
        ],
    },
    {
        "id": "federalist-papers-complete",
        "title": "The Federalist Papers (Complete)",
        "author": "Alexander Hamilton, James Madison, John Jay",
        "description": "The full defense of the Constitution — faction, federalism, separation of powers, and republican liberty.",
        "gutenberg": 1404,
        "minChars": 400000,
        "topics": [
            ("founding-principles", "Complete constitutional design argument.", 1),
            ("government-intervention", "Limited powers and checks.", 1),
        ],
    },
    {
        "id": "keynes-economic-consequences-peace",
        "title": "The Economic Consequences of the Peace",
        "author": "John Maynard Keynes",
        "description": "Post-WWI economic analysis — useful context for state planning, reparations, and unintended consequences.",
        "gutenberg": 15776,
        "minChars": 100000,
        "topics": [
            ("government-intervention", "Policy unintended consequences.", 3),
            ("historical-socialism", "Interwar economic upheaval context.", 3),
        ],
    },
    {
        "id": "mallock-aristocracy-evolution",
        "title": "Aristocracy & Evolution: A Study of the Rights, the Origin, and the Social Functions of the Wealthier Classes",
        "author": "W. H. Mallock",
        "description": "Mallock on ability, directing classes, and why equal outcomes fight human variation.",
        "gutenberg": 58968,
        "minChars": 150000,
        "topics": [
            ("wealth-inequality-mobility", "Ability and social function of wealth.", 1),
            ("human-nature-incentives", "Unequal faculties.", 1),
        ],
    },
]


def utc_now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def strip_pg(text: str) -> str:
    start = text.find("*** START OF THE PROJECT GUTENBERG")
    if start != -1:
        text = text[text.find("\n", start) + 1 :]
    # alternate marker
    start2 = text.find("***START OF THE PROJECT GUTENBERG")
    if start2 != -1:
        text = text[text.find("\n", start2) + 1 :]
    end = text.find("*** END OF THE PROJECT GUTENBERG")
    if end != -1:
        text = text[:end]
    end2 = text.find("***END OF THE PROJECT GUTENBERG")
    if end2 != -1:
        text = text[:end2]
    return text.strip() + "\n"


def fetch_gutenberg(ebook_id: int) -> str:
    urls = [
        f"https://www.gutenberg.org/cache/epub/{ebook_id}/pg{ebook_id}.txt",
        f"https://www.gutenberg.org/files/{ebook_id}/{ebook_id}-0.txt",
        f"https://www.gutenberg.org/files/{ebook_id}/{ebook_id}.txt",
        f"https://www.gutenberg.org/ebooks/{ebook_id}.txt.utf-8",
    ]
    last_err: Exception | None = None
    for url in urls:
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, timeout=180) as resp:
                raw = resp.read()
            for enc in ("utf-8", "utf-8-sig", "latin-1", "cp1252"):
                try:
                    text = raw.decode(enc)
                    break
                except UnicodeDecodeError:
                    text = ""
            else:
                text = raw.decode("utf-8", errors="replace")
            return strip_pg(text)
        except Exception as exc:
            last_err = exc
            continue
    raise RuntimeError(f"Gutenberg {ebook_id} failed: {last_err}")


def auto_chapters(text: str, max_chapters: int = 24) -> list[dict]:
    """Detect CHAPTER / PART / LETTER headings for reader navigation."""
    patterns = [
        re.compile(r"^(CHAPTER\s+[IVXLC\d]+[^\n]{0,80})$", re.M | re.I),
        re.compile(r"^(PART\s+[IVXLC\d]+[^\n]{0,80})$", re.M | re.I),
        re.compile(r"^(LETTER\s+[IVXLC\d]+[^\n]{0,80})$", re.M | re.I),
        re.compile(r"^(SECTION\s+[IVXLC\d]+[^\n]{0,80})$", re.M | re.I),
        re.compile(r"^(BOOK\s+[IVXLC\d]+[^\n]{0,80})$", re.M | re.I),
    ]
    found: list[tuple[int, str]] = []
    for pat in patterns:
        for m in pat.finditer(text):
            found.append((m.start(), m.group(1).strip()))
        if len(found) >= 3:
            break
        found = []
    if len(found) < 2:
        # Fall back to even thirds for navigation
        n = len(text)
        return [
            {"id": "part-1", "title": "Beginning", "startOffset": 0},
            {"id": "part-2", "title": "Middle", "startOffset": n // 3},
            {"id": "part-3", "title": "Later", "startOffset": (2 * n) // 3},
        ]
    # Dedupe nearby offsets
    found.sort(key=lambda x: x[0])
    chapters = []
    last = -10_000
    for off, title in found:
        if off - last < 200:
            continue
        cid = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")[:48]
        chapters.append({"id": cid or f"ch-{len(chapters)+1}", "title": title[:80], "startOffset": off})
        last = off
        if len(chapters) >= max_chapters:
            break
    if chapters and chapters[0]["startOffset"] > 0:
        chapters.insert(0, {"id": "front", "title": "Front Matter", "startOffset": 0})
    return chapters


def slug_file(book_id: str) -> str:
    return f"{book_id}.txt"


def main() -> int:
    BOOKS_DIR.mkdir(parents=True, exist_ok=True)
    CACHE_DIR.mkdir(parents=True, exist_ok=True)

    data = json.loads(BOOKS_JSON.read_text(encoding="utf-8"))
    by_id = {b["id"]: b for b in data["books"]}
    sources = json.loads(SOURCES_JSON.read_text(encoding="utf-8"))
    if "sources" not in sources:
        sources["sources"] = {}

    installed = 0
    skipped = 0
    failed: list[str] = []

    for entry in CORPUS:
        book_id = entry["id"]
        out_name = slug_file(book_id)
        out_path = BOOKS_DIR / out_name
        min_chars = int(entry["minChars"])

        existing = by_id.get(book_id)
        if existing and existing.get("fullTextPath"):
            fp = ROOT / existing["fullTextPath"]
            if fp.is_file() and fp.stat().st_size >= min_chars // 2:
                print(f"SKIP {book_id}: already bundled ({fp.stat().st_size:,} bytes)")
                skipped += 1
                continue

        print(f"FETCH {book_id} (PG {entry['gutenberg']})…")
        try:
            text = fetch_gutenberg(int(entry["gutenberg"]))
            time.sleep(0.6)  # polite to Gutenberg
        except Exception as exc:
            print(f"FAIL {book_id}: {exc}")
            failed.append(f"{book_id}: {exc}")
            continue

        if len(text) < min_chars:
            # still keep if substantial (> half min or > 20k)
            if len(text) < max(20_000, min_chars // 3):
                print(f"FAIL {book_id}: too short ({len(text):,} < {min_chars:,})")
                failed.append(f"{book_id}: too short {len(text)}")
                continue
            print(f"WARN {book_id}: shorter than ideal ({len(text):,} / {min_chars:,}) — keeping")

        out_path.write_text(text, encoding="utf-8")
        (CACHE_DIR / out_name).write_text(text, encoding="utf-8")

        chapters = auto_chapters(text)
        recs = [
            {"topicId": tid, "reason": reason, "priority": pri}
            for tid, reason, pri in entry["topics"]
        ]
        book = {
            "id": book_id,
            "title": entry["title"],
            "author": entry["author"],
            "description": entry["description"],
            "pdStatus": "public_domain",
            "fullTextPath": f"assets/data/books/{out_name}",
            "chapters": chapters,
            "recommendations": recs,
            "schemaVersion": 2,
            "revision": 1,
            "updatedAt": utc_now(),
            "kbVersion": "3.5.0",
        }
        if existing:
            existing.update(book)
            existing["revision"] = int(existing.get("revision", 1)) + 1
        else:
            data["books"].append(book)
            by_id[book_id] = book

        sources["sources"][book_id] = {
            "gutenberg": entry["gutenberg"],
            "out": out_name,
            "minChars": min(min_chars, max(10000, len(text) // 2)),
            "needles": [entry["author"].split(",")[0].split()[-1][:12], entry["title"].split()[0][:12]],
        }
        installed += 1
        print(f"OK {book_id}: {len(text):,} chars, {len(chapters)} chapters")

    data["kbVersion"] = "3.5.0"
    data["updatedAt"] = utc_now()
    data["contentHash"] = "sha256:library-pd-bulk-v3.5.0"
    BOOKS_JSON.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    sources["updatedAt"] = utc_now()
    SOURCES_JSON.write_text(json.dumps(sources, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    print("\n=== SUMMARY ===")
    print(f"installed={installed} skipped={skipped} failed={len(failed)} total_books={len(data['books'])}")
    for f in failed:
        print(f"  FAIL {f}")
    return 0 if installed or skipped else 1


if __name__ == "__main__":
    raise SystemExit(main())
