# -*- coding: utf-8 -*-
from pathlib import Path

p = Path(__file__).resolve().parents[1] / "lib/features/crusher/services/claim_retrieval_backend.dart"
t = p.read_text(encoding="utf-8")
if "student-loan-pause-is-justice" in t:
    print("boosts already")
    raise SystemExit(0)

marker = "'calculation problem': ['computers-solve-calculation', 'calculation-impossible'],"
extra = marker + """
    'student loan': ['student-loan-pause-is-justice', 'student-debt-cancel-justice', 'free-college-is-a-right'],
    'loan pause': ['student-loan-pause-is-justice', 'student-debt-cancel-justice'],
    'public option': ['public-option-beats-markets', 'medicare-for-all-pays-for-itself', 'healthcare-right'],
    'dei': ['dei-mandates-are-justice'],
    'diversity equity': ['dei-mandates-are-justice'],
    'climate reparations': ['climate-reparations-owed', 'climate-capitalism-failed'],
    'grocery': ['grocery-price-controls-now', 'greedflation-price-controls'],
    'public housing': ['public-housing-only-solution', 'housing-must-be-decommodified', 'rent-freeze-solves-city-housing'],"""
if marker not in t:
    raise SystemExit("FAIL marker")
p.write_text(t.replace(marker, extra, 1), encoding="utf-8")
print("boosts ok")
