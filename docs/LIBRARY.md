# Public Domain Library — Reader & Catalog

The in-app library ships full texts of liberty classics, socialist primaries (for steelman reading), and cultural counter-arguments — bundled offline, with claim-linked recommendations.

## Catalog (KB v3.8.0)

| Metric | Count |
|--------|------:|
| Catalog entries | 136 |
| Bundled full texts | 120 |
| Catalog-only (copyrighted / external) | 16 |
| Claim → book reading links | 111+ |

Integrity: `py -3 tools/library_pipeline.py verify` and `py -3 tools/audit_library_integrity.py` (must report **0 failures**).

### Socialist / left primaries (steelman)

Henry George *Progress and Poverty*, Russell *Proposed Roads to Freedom*, Walling *Socialism As It Is*, Spargo *Syndicalism*, Hunter *Violence and the Labor Movement*, Dewey *Democracy and Education*, Proudhon (*What is Property?*, *Economical Contradictions*), Marx (*Capital* Vol I, *Critique of Political Economy*, *Value Price and Profit*, *Poverty of Philosophy*, *German Ideology*, *Gotha*, *18th Brumaire*, *Wage Labour*), Engels (*Condition of the Working Class*, *Origin of the Family*, *Utopian and Scientific*, *Anti-Dühring*), Lenin (*What Is To Be Done?*, *State and Revolution*, *Imperialism*), Luxemburg (*Accumulation of Capital*), Bebel (*Woman and Socialism*), Kropotkin (*Conquest of Bread*, *Mutual Aid*), Goldman, Wilde, Spargo, La Monte, Plekhanov, Mill *Chapters on Socialism*, Bellamy (*Looking Backward*, *Equality*), Morris *News from Nowhere*, More *Utopia*, Rousseau, Fabian essays, Trotsky *Literature and Revolution*, Bakunin.

### Liberty / free-market / cultural counters

Böhm-Bawerk *Karl Marx and the Close of His System*, Oppenheimer *The State*, Tocqueville *Old Regime*, Bastiat (*The Law*, *Seen and Unseen*, *Economic Sophisms*, *Harmonies*, *Free Trade*), Mallock (*Critical Examination of Socialism*, *Aristocracy & Evolution*), Barker *British Socialism*, Belloc *Servile State*, Ricardo, Malthus, Mill *Principles* & *On Liberty*, Sumner (*Social Classes*, *Forgotten Man*), Spencer (*Right to Ignore the State*, *The Man Versus the State*), Spooner (*No Treason* VI, *Trial by Jury*, *Letter to Grover Cleveland*, *Unconstitutionality of Slavery*), Smith *Wealth of Nations*, Tocqueville, Burke, Acton, Chesterton (*Orthodoxy*, *Heretics*, *What's Wrong*), Dostoevsky (*Notes from Underground*, *Crime and Punishment*), Conrad (*Secret Agent*, *Under Western Eyes*), Turgenev *Fathers and Sons*, Nietzsche *Beyond Good and Evil*, Milton *Areopagitica*, Plato *Republic*, Hobbes *Leviathan*, Machiavelli *Prince*, full *Federalist Papers*, Founders documents, Booker T. Washington *Up from Slavery*, Maine *Ancient Law*, Lecky, Michaelis *Looking Further Forward* (anti-Bellamy), Keynes *Economic Consequences of the Peace*.

### Catalog-only (copyrighted — external links)

Hayek *Road to Serfdom*, Hazlitt *Economics in One Lesson*, Mises *Socialism*, Friedman *Capitalism and Freedom*, Rothbard *Man, Economy, and State*, Freire, Pluckrose/Lindsay, Marcuse, Adorno, Alinsky, CRT key writings, Orwell *Animal Farm*, Bloom, Scruton, Rufo, Sowell — not redistributed.

## Reader features

| Feature | Implementation |
|---------|----------------|
| Adjustable typography | Font scale 85–140%, line height 1.4–2.0, serif/sans |
| Night / Sepia / Paper themes | `ReaderSettings` in Hive |
| Full-text search | `BookSearchBar` |
| Highlights + notes | Selection → Highlight (Hive) |
| Progress tracking | Scroll fraction + chapter ID |
| Table of contents | Desktop split / mobile sheet |
| Offline cache | `library_offline/` + bundled assets |

## Architecture

```
assets/data/v2/books.json          → metadata + chapters + topic recs
assets/data/v2/claim_reading_links.json
assets/data/v2/library_sources.json → Gutenberg/MIA registry
assets/data/books/*.txt            → full texts
tools/bulk_add_pd_library.py       → Gutenberg bulk install
tools/bulk_add_pd_library_wave2.py → Gutenberg + Marxists.org
tools/library_pipeline.py          → verify / refresh / discover
```

## Maintenance

```powershell
py -3 tools/library_pipeline.py verify
py -3 tools/audit_library_integrity.py
node tools/generate-sitemap.mjs
.\tools\publish-web.ps1
```
