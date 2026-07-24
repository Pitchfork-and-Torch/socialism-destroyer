import { claim, gov, acad, primary } from './_claim_factory.mjs';

export default [
  // ── Overrides (richer v2) ──────────────────────────────────────────────
  claim({
    id: 'natural-rights',
    topicId: 'founding-principles',
    topicPath: '/founding-principles',
    title: 'Rights Come From Government',
    socialistClaimText:
      'Rights are whatever society democratically grants — government creates and may revoke rights by majority vote.',
    executiveSummary:
      'The American founding rejected positivist rights. The Declaration of Independence (1776) holds that "all men are created equal" and are "endowed by their Creator with certain unalienable Rights." Locke\'s Second Treatise (1689, public domain) argued rights to life, liberty, and property pre-exist civil government; government\'s role is to secure them, not confer them. If rights are mere grants of the state, no minority can appeal to justice against majority tyranny — the very problem the Founders designed institutions to prevent.',
    evidenceBullets: [
      'Declaration of Independence (1776, NARA): "unalienable Rights" include "Life, Liberty and the pursuit of Happiness" — rights exist prior to government.',
      'Locke, Second Treatise, Ch. II (PD, OLL): state of nature endowed men with natural rights; government formed by consent to protect property, not to invent rights.',
      'Locke, Ch. IX: legislative power is fiduciary — bounded by the public good, not unlimited grantor of privileges.',
      'Madison, Federalist 51: "If men were angels, no government would be necessary" — institutions restrain power because rights need protection from government itself.',
    ],
    fallacies: ['positivist confusion', 'conflation of law with rights', 'majoritarian tyranny'],
    sources: [
      primary(
        'Locke — Second Treatise of Government (1689)',
        'https://oll.libertyfund.org/titles/locke-the-second-treatise-on-civil-government',
        'Locke, J. (1689). Second Treatise of Government. Liberty Fund OLL (public domain).',
      ),
      primary(
        'National Archives — Declaration of Independence (1776)',
        'https://www.archives.gov/founding-docs/declaration-transcript',
        'National Archives, Declaration of Independence, Engrossed copy transcript.',
      ),
      primary(
        'Founders Online — Madison correspondence on rights and factions',
        'https://founders.archives.gov/',
        'National Archives, Founders Online, James Madison papers.',
      ),
      primary(
        'Congress.gov — Bill of Rights (Amendments I–X)',
        'https://constitution.congress.gov/constitution/amendment-1/',
        'National Archives via Congress.gov, U.S. Constitution Bill of Rights.',
      ),
    ],
    whyItMatters:
      'If rights are government grants, democracy can legitimately seize property, silence dissent, and redistribute by force. Natural-rights philosophy is the intellectual firewall against totalitarian majoritarianism — including democratic socialism.',
    relatedClaimIds: ['constitution-limits', 'declaration-pursuit-happiness', 'federalist-51-separation'],
    tags: ['natural rights', 'locke', 'declaration', 'unalienable', 'pd-quote', 'founding'],
    claimQuote:
      'The state of nature has a law of nature to govern it, which obliges every one: and reason, which is that law, teaches all mankind, who will but consult it, that being all equal and independent, no one ought to harm another in his life, health, liberty, or possessions.',
    quoteAttribution: 'John Locke, Second Treatise of Government, §6 (1689) — public domain',
    revision: 2,
  }),

  claim({
    id: 'founding-collectivist',
    topicId: 'founding-principles',
    topicPath: '/founding-principles',
    title: 'Founders Supported Collectivism',
    socialistClaimText:
      'The American Founders would support modern democratic socialism — they favored collective action and would back Medicare for All and nationalized industry.',
    executiveSummary:
      'Madison\'s Federalist No. 10 (1787) warned that factions — including those seeking to redistribute property — are sown in the "nature of man." The Constitution\'s enumerated powers deliberately limited federal authority; Anti-Federalist Brutus warned consolidated power would destroy liberty. Jefferson and Madison valued yeoman property ownership, not collective ownership of production. Conflating voluntary community cooperation with state collectivization is historical revisionism.',
    evidenceBullets: [
      'Madison, Federalist 10 (PD): "the most common and durable source of factions has been the various and unequal distribution of property" — the Founders anticipated class legislation, not endorsed it.',
      'Madison: large republic + separation of powers to control factional tyranny, not empower redistributionist majorities.',
      'Anti-Federalist Brutus I: feared consolidated federal power would "oppress and ruin the people" — skepticism of expansive state economic role.',
      'Constitution Art. I §8: enumerated powers list — no general welfare power to nationalize industry; general Welfare clause modifies taxing power, not grants unlimited authority.',
    ],
    fallacies: ['historical revisionism', 'anachronism', 'conflation of community with collectivism'],
    sources: [
      primary(
        'LOC — Federalist No. 10 (Madison)',
        'https://guides.loc.gov/federalist-papers/federalist-no-10',
        'Madison, J. (1787). Federalist No. 10. Library of Congress Research Guide.',
      ),
      primary(
        'LOC — Anti-Federalist Brutus I',
        'https://guides.loc.gov/anti-federalist-papers/brutus-i',
        'Brutus (Robert Yates). Anti-Federalist No. 1. Library of Congress.',
      ),
      primary(
        'Constitution.congress.gov — Article I, Section 8',
        'https://constitution.congress.gov/browse/article-1/section-8/',
        'U.S. Constitution, Article I, Section 8 — enumerated powers.',
      ),
      primary(
        'Founders Online — Jefferson and Madison on property',
        'https://founders.archives.gov/',
        'National Archives, Founders Online, Jefferson and Madison papers on property and liberty.',
      ),
    ],
    whyItMatters:
      'Invoking the Founders to bless modern socialism requires ignoring Federalist 10, the Anti-Federalist warnings, and a Constitution written to limit factional redistribution — not enable it.',
    relatedClaimIds: ['natural-rights', 'constitution-limits', 'federalist-51-separation'],
    tags: ['founders', 'madison', 'federalist 10', 'anti-federalist', 'factions', 'pd-quote'],
    claimQuote:
      'The diversity in the faculties of men, from which the rights of property originate, is not less an insuperable obstacle to a uniformity of interests. The protection of these faculties is the first object of government.',
    quoteAttribution: 'James Madison, Federalist No. 10 (1787) — public domain',
    revision: 2,
  }),

  claim({
    id: 'constitution-limits',
    topicId: 'founding-principles',
    topicPath: '/founding-principles',
    title: 'Constitution Mandates Welfare Expansion',
    socialistClaimText:
      'The Constitution requires modern welfare programs — the General Welfare Clause mandates expansive federal redistribution.',
    executiveSummary:
      'Article I Section 8 enumerates specific federal powers — taxing, borrowing, regulating interstate commerce, etc. The General Welfare Clause qualifies the taxing power ("to pay the Debts and provide for the common Defence and general Welfare of the United States"), not a standalone authorization for any program labeled "welfare." Madison in Federalist 41 argued the clause restates the purpose of enumerated powers, not expands them. CBO projections show mandatory spending and interest consuming an increasing share of federal outlays — a fiscal trajectory the Founders\' limited-government design was meant to constrain.',
    evidenceBullets: [
      'Constitution Art. I §8: powers are enumerated and finite — Tenth Amendment reserves others to states and people.',
      'Madison, Federalist 41: "general Welfare" refers to the objects of enumerated powers, not an independent grant of unlimited authority.',
      'CBO (2024 Long-Term Budget Outlook): mandatory spending (Social Security, Medicare, Medicaid) plus net interest projected to exceed 80% of federal outlays by 2050.',
      'Federalist 45 (Madison): federal government\'s powers "few and defined"; states\' powers "numerous and indefinite."',
    ],
    fallacies: ['wishful interpretation', 'textual isolation (General Welfare Clause)', 'living constitution overreach'],
    sources: [
      primary(
        'Constitution.congress.gov — Article I, Section 8',
        'https://constitution.congress.gov/browse/article-1/section-8/',
        'U.S. Constitution, Article I, Section 8, via Congress.gov.',
      ),
      primary(
        'LOC — Federalist No. 41 (Madison)',
        'https://guides.loc.gov/federalist-papers/federalist-no-41',
        'Madison, J. (1788). Federalist No. 41. Library of Congress.',
      ),
      gov(
        'CBO — The Long-Term Budget Outlook (2024)',
        'https://www.cbo.gov/publication/60039',
        'Congressional Budget Office, The Long-Term Budget Outlook, June 2024.',
      ),
      primary(
        'LOC — Federalist No. 45 (Madison)',
        'https://guides.loc.gov/federalist-papers/federalist-no-45',
        'Madison, J. (1788). Federalist No. 45. Library of Congress.',
      ),
    ],
    whyItMatters:
      'Treating every redistribution program as constitutionally mandatory forecloses honest fiscal debate. The Founders designed a limited federal government; CBO math shows why those limits matter for national solvency.',
    relatedClaimIds: ['founding-collectivist', 'natural-rights', 'bastiat-law-collectivism'],
    tags: ['constitution', 'general welfare', 'enumerated powers', 'cbo', 'fiscal', 'madison'],
    revision: 2,
  }),

  // ── New claims ─────────────────────────────────────────────────────────
  claim({
    id: 'federalist-51-separation',
    topicId: 'founding-principles',
    topicPath: '/founding-principles',
    title: 'Strong Central Government Is What the Founders Wanted',
    socialistClaimText:
      'The Founders intended a strong activist federal government — separation of powers is a formality, not a limit on expansive state economic planning.',
    executiveSummary:
      'Madison\'s Federalist No. 51 (1788) explains that separation of powers and checks and balances are essential because men are not angels — concentrated power threatens liberty. "Ambition must be made to counteract ambition." The federal government was designed with limited enumerated powers; separation was structural insurance, not an invitation to unlimited central planning. Expanding federal economic control contradicts the Madisonian premise that power must be divided to prevent tyranny.',
    evidenceBullets: [
      'Madison, Federalist 51: "If men were angels, no government would be necessary. If angels were to govern men, neither external nor internal controls on government would be necessary."',
      'Federalist 51: separation of legislative, executive, and judicial departments with mutual checks — "a reflection on human nature."',
      'Federalist 51: compound republic — federal and state layers provide "double security" to the rights of the people.',
      'Constitution Art. I–III: distinct powers assigned to branches — not a unified planning apparatus.',
    ],
    fallacies: ['historical revisionism', 'concentration of power fallacy', 'appeal to authority (misapplied)'],
    sources: [
      primary(
        'LOC — Federalist No. 51 (Madison)',
        'https://guides.loc.gov/federalist-papers/federalist-no-51',
        'Madison, J. (1788). Federalist No. 51. Library of Congress Research Guide.',
      ),
      primary(
        'Constitution.congress.gov — Full Text',
        'https://constitution.congress.gov/constitution/',
        'U.S. Constitution, full text via National Archives / Congress.gov.',
      ),
      primary(
        'Founders Online — Madison on separation of powers',
        'https://founders.archives.gov/documents/Madison/01-10-02-0177',
        'Madison, J., notes on separation of powers, Founders Online.',
      ),
      primary(
        'LOC — Federalist No. 47 (Montesquieu influence)',
        'https://guides.loc.gov/federalist-papers/federalist-no-47',
        'Madison, J. (1788). Federalist No. 47 on separation of departments. Library of Congress.',
      ),
    ],
    whyItMatters:
      'Central economic planning requires concentrating power in the executive and administrative state — the opposite of Federalist 51\'s prescription. Madison\'s architecture is a warning, not a blank check for democratic socialism.',
    relatedClaimIds: ['founding-collectivist', 'constitution-limits', 'natural-rights'],
    tags: ['federalist 51', 'madison', 'separation of powers', 'checks and balances', 'pd-quote'],
    claimQuote:
      'If men were angels, no government would be necessary. If angels were to govern men, neither external nor internal controls on government would be necessary.',
    quoteAttribution: 'James Madison, Federalist No. 51 (1788) — public domain',
    revision: 1,
  }),

  claim({
    id: 'bastiat-law-collectivism',
    topicId: 'founding-principles',
    topicPath: '/founding-principles',
    title: 'The Law Should Redistribute for Equality',
    socialistClaimText:
      'The law should actively redistribute wealth to achieve equality — using state power for economic justice is the proper purpose of legislation.',
    executiveSummary:
      'Frédéric Bastiat argued in The Law (1850) that law originally existed to protect life, liberty, and property — not to plunder one class for another. When the law is perverted to impose collectivist outcomes, it destroys its own moral foundation and converts the state into an instrument of legal plunder. Bastiat\'s insight parallels Madison\'s fear of factional redistribution and Locke\'s limit on legislative power. Justice requires universal rules protecting persons and property, not selective takings for equal outcomes.',
    evidenceBullets: [
      'Bastiat, The Law (1850, PD): "law is the organization of the natural right of lawful defense" — not a tool of envy.',
      'Bastiat: "legal plunder" occurs when law takes from some to give to others — socialism uses law as plunder\'s instrument.',
      'Bastiat: "The state is the great fictitious entity by which everyone seeks to live at the expense of everyone else."',
      'Madison, Federalist 10: factions seeking redistribution are the disease; constitutional limits are the cure — Bastiat extends this to legislation itself.',
    ],
    fallacies: ['legal plunder', 'zero-sum fallacy', 'ends justify the means'],
    sources: [
      primary(
        'Bastiat — The Law (1850)',
        'https://oll.libertyfund.org/titles/bastiat-the-law',
        'Bastiat, F. (1850). The Law. Liberty Fund OLL (public domain).',
      ),
      primary(
        'LOC — Federalist No. 10 (Madison)',
        'https://guides.loc.gov/federalist-papers/federalist-no-10',
        'Madison, J. (1787). Federalist No. 10. Library of Congress.',
      ),
      primary(
        'Locke — Second Treatise of Government (1689)',
        'https://oll.libertyfund.org/titles/locke-the-second-treatise-on-civil-government',
        'Locke, J. (1689). Second Treatise of Government. Liberty Fund OLL.',
      ),
      gov(
        'CBO — Distribution of Household Income (2019)',
        'https://www.cbo.gov/publication/57046',
        'Congressional Budget Office, The Distribution of Household Income, 2019 — fiscal effects of transfers.',
      ),
    ],
    whyItMatters:
      'Redistributive socialism claims moral high ground by invoking "the law." Bastiat shows that perverting law into plunder destroys both justice and prosperity — a lesson as relevant to modern entitlement politics as to 19th-century France.',
    relatedClaimIds: ['natural-rights', 'constitution-limits', 'founding-collectivist'],
    tags: ['bastiat', 'the law', 'legal plunder', 'redistribution', 'pd-quote', 'justice'],
    claimQuote:
      'When plunder becomes a way of life for a group of men in a society, over the course of time they create for themselves a legal system that authorizes it and a moral code that glorifies it.',
    quoteAttribution: 'Frédéric Bastiat, The Law (1850) — public domain',
    revision: 1,
  }),

  claim({
    id: 'declaration-pursuit-happiness',
    topicId: 'founding-principles',
    topicPath: '/founding-principles',
    title: 'Pursuit of Happiness Means Guaranteed Outcomes',
    socialistClaimText:
      'The Declaration\'s "pursuit of Happiness" means government must guarantee economic security and equal outcomes — not merely protect individual liberty to strive.',
    executiveSummary:
      'The Declaration of Independence (1776) lists "Life, Liberty and the pursuit of Happiness" as unalienable rights endowed by the Creator — not grants of government. "Pursuit" implies striving under liberty, not a guarantee of material equality. Jefferson drew on Locke\'s "life, liberty, and estate" — property and self-directed improvement, not entitlement to equal outcomes. National Archives scholarship and founding-era usage confirm happiness meant flourishing through virtue and self-governance, not a federal jobs guarantee.',
    evidenceBullets: [
      'Declaration (1776, NARA): rights are "unalienable" and precede government — government secures them, not manufactures them.',
      '"Pursuit of Happiness" (Jefferson): Lockean formulation substituting "estate/property" with broader flourishing — still an individual right to strive, not a collective claim on others\' labor.',
      'Federalist 62 (Madison): warning against laws "too voluminous" and "incoherent" — happiness under liberty requires predictable rules, not endless redistribution.',
      'CBO transfer analysis: federal transfers reduce inequality but do not convert a right to pursue happiness into a right to equal consumption.',
    ],
    fallacies: ['rights inflation', 'conflation of pursuit with guarantee', 'anachronism'],
    sources: [
      primary(
        'National Archives — Declaration of Independence (1776)',
        'https://www.archives.gov/founding-docs/declaration-transcript',
        'National Archives, Declaration of Independence, engrossed transcript.',
      ),
      primary(
        'National Archives — Declaration: A Transcription (context)',
        'https://www.archives.gov/founding-docs/declaration',
        'National Archives, Charters of Freedom — Declaration historical context.',
      ),
      primary(
        'Locke — Second Treatise of Government (1689)',
        'https://oll.libertyfund.org/titles/locke-the-second-treatise-on-civil-government',
        'Locke, J. (1689). Second Treatise — life, liberty, and estate as natural rights.',
      ),
      gov(
        'CBO — The Distribution of Household Income, 2019',
        'https://www.cbo.gov/publication/57046',
        'Congressional Budget Office, Distribution of Household Income including transfers and taxes, 2019.',
      ),
    ],
    whyItMatters:
      'Equating "pursuit of happiness" with guaranteed economic equality weaponizes a founding document to justify unlimited coercion. The Declaration protects the right to strive under liberty — the philosophical opposite of socialist outcome guarantees.',
    relatedClaimIds: ['natural-rights', 'bastiat-law-collectivism', 'federalist-51-separation'],
    tags: ['declaration', 'pursuit of happiness', 'jefferson', 'unalienable rights', 'nara', 'pd-quote'],
    claimQuote:
      'We hold these truths to be self-evident, that all men are created equal, that they are endowed by their Creator with certain unalienable Rights, that among these are Life, Liberty and the pursuit of Happiness.',
    quoteAttribution: 'Declaration of Independence (1776), National Archives — public domain',
    revision: 1,
  }),
];