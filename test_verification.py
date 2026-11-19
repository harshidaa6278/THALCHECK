"""
ThalCheck Comprehensive Verification Test Suite
Includes Phase 1: Bordbar Formula Correction validation.
"""

import math

INDEX_WEIGHTS = {
    "englandFraser": 3,
    "greenKing": 3,
    "mentzer": 2,
    "shineLal": 2,
    "ricerca": 1,
    "srivastava": 1,
    "ehsani": 1,
    "sirdah": 1,
    "bordbar": 2,
    "rdwIndex": 2,
    "logit": 1
}


def calculate_bordbar(mcv: float, mch: float) -> dict:
    """
    Bordbar Formula:
    Bordbar = abs(80 - MCV) * abs(27 - MCH)

    Decision:
    - Value >= 44.76: IDA
    - Value < 44.76: THALASSAEMIA
    """
    value = abs(80.0 - mcv) * abs(27.0 - mch)
    vote = "THALASSAEMIA" if value < 44.76 else "IDA"
    return {
        "id": "bordbar",
        "name": "Bordbar",
        "formula": "|80 − MCV| × |27 − MCH|",
        "value": round(value, 4),
        "displayValue": f"{value:.2f}",
        "cutoff": "< 44.76 THAL (≥ 44.76 IDA)",
        "vote": vote,
        "weight": INDEX_WEIGHTS["bordbar"]
    }


def test_bordbar():
    # 1. Values below 44.76
    res = calculate_bordbar(76.0, 24.0)
    assert res["value"] == 12.0
    assert res["vote"] == "THALASSAEMIA"
    assert res["weight"] == 2

    res = calculate_bordbar(74.0, 21.0)
    assert res["value"] == 36.0
    assert res["vote"] == "THALASSAEMIA"

    # 2. Exactly 44.76
    res = calculate_bordbar(57.62, 25.0)
    assert abs(res["value"] - 44.76) < 1e-4
    assert res["vote"] == "IDA"  # Value >= 44.76 is IDA

    # 3. Values above 44.76
    res = calculate_bordbar(65.0, 20.0)
    assert res["value"] == 105.0
    assert res["vote"] == "IDA"

    res = calculate_bordbar(60.0, 18.0)
    assert res["value"] == 180.0
    assert res["vote"] == "IDA"

    # 4. Absolute-value handling (MCV > 80, MCH > 27)
    res = calculate_bordbar(85.0, 25.0)  # MCV > 80
    assert res["value"] == 10.0
    assert res["vote"] == "THALASSAEMIA"

    res = calculate_bordbar(75.0, 30.0)  # MCH > 27
    assert res["value"] == 15.0
    assert res["vote"] == "THALASSAEMIA"

    res = calculate_bordbar(88.0, 32.0)  # Both > 80 and > 27
    assert res["value"] == 40.0
    assert res["vote"] == "THALASSAEMIA"

    # 5. Decimal inputs
    res = calculate_bordbar(62.3, 19.4)
    assert abs(res["value"] - 134.52) < 1e-4
    assert res["vote"] == "IDA"

    res = calculate_bordbar(77.5, 25.2)
    assert abs(res["value"] - 4.50) < 1e-4
    assert res["vote"] == "THALASSAEMIA"


if __name__ == "__main__":
    test_bordbar()
    print("All Bordbar verification tests passed successfully!")
