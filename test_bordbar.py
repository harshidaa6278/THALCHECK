"""
Test Suite for Bordbar Formula Update in ThalCheck.
Validates:
- Values below 44.76
- Exactly 44.76
- Values above 44.76
- Absolute-value handling
- Decimal inputs
"""

def calculate_bordbar(mcv: float, mch: float):
    """
    Bordbar = abs(80 - MCV) * abs(27 - MCH)
    Decision:
      Value >= 44.76: IDA
      Value < 44.76: THALASSAEMIA
    """
    value = abs(80.0 - mcv) * abs(27.0 - mch)
    vote = "THALASSAEMIA" if value < 44.76 else "IDA"
    return {
        "value": round(value, 4),
        "displayValue": f"{value:.2f}",
        "cutoff": "< 44.76 THAL (≥ 44.76 IDA)",
        "vote": vote,
        "weight": 2
    }


def test_values_below_44_76():
    # MCV=76, MCH=24 -> |80-76| * |27-24| = 4 * 3 = 12.0
    res = calculate_bordbar(76.0, 24.0)
    assert res["value"] == 12.0
    assert res["vote"] == "THALASSAEMIA"

    # MCV=74, MCH=21 -> |80-74| * |27-21| = 6 * 6 = 36.0
    res = calculate_bordbar(74.0, 21.0)
    assert res["value"] == 36.0
    assert res["vote"] == "THALASSAEMIA"

    # Boundary below: 44.74 < 44.76
    res = calculate_bordbar(57.63, 25.0)
    assert res["value"] < 44.76
    assert res["vote"] == "THALASSAEMIA"


def test_exactly_44_76():
    # MCV=57.62, MCH=25 -> |80-57.62| * |27-25| = 22.38 * 2 = 44.76
    res = calculate_bordbar(57.62, 25.0)
    assert abs(res["value"] - 44.76) < 1e-6
    # Specification: Value >= 44.76: IDA
    assert res["vote"] == "IDA"

    # MCV=35.24, MCH=26 -> |80-35.24| * |27-26| = 44.76 * 1 = 44.76
    res = calculate_bordbar(35.24, 26.0)
    assert abs(res["value"] - 44.76) < 1e-6
    assert res["vote"] == "IDA"


def test_values_above_44_76():
    # MCV=65, MCH=20 -> |80-65| * |27-20| = 15 * 7 = 105.0
    res = calculate_bordbar(65.0, 20.0)
    assert res["value"] == 105.0
    assert res["vote"] == "IDA"

    # MCV=60, MCH=18 -> |80-60| * |27-18| = 20 * 9 = 180.0
    res = calculate_bordbar(60.0, 18.0)
    assert res["value"] == 180.0
    assert res["vote"] == "IDA"

    # Boundary above: 44.78 >= 44.76
    res = calculate_bordbar(57.61, 25.0)
    assert res["value"] >= 44.76
    assert res["vote"] == "IDA"


def test_absolute_value_handling():
    # MCV > 80: MCV=85, MCH=25 -> |80-85| * |27-25| = 5 * 2 = 10.0
    res = calculate_bordbar(85.0, 25.0)
    assert res["value"] == 10.0
    assert res["vote"] == "THALASSAEMIA"

    # MCH > 27: MCV=75, MCH=30 -> |80-75| * |27-30| = 5 * 3 = 15.0
    res = calculate_bordbar(75.0, 30.0)
    assert res["value"] == 15.0
    assert res["vote"] == "THALASSAEMIA"

    # Both > 80 and > 27: MCV=88, MCH=32 -> |80-88| * |27-32| = 8 * 5 = 40.0
    res = calculate_bordbar(88.0, 32.0)
    assert res["value"] == 40.0
    assert res["vote"] == "THALASSAEMIA"

    # Both > 80 and > 27 exceeding cutoff: MCV=95, MCH=35 -> |80-95| * |27-35| = 15 * 8 = 120.0
    res = calculate_bordbar(95.0, 35.0)
    assert res["value"] == 120.0
    assert res["vote"] == "IDA"


def test_decimal_inputs():
    # MCV=62.3, MCH=19.4 -> |80-62.3| * |27-19.4| = 17.7 * 7.6 = 134.52
    res = calculate_bordbar(62.3, 19.4)
    assert abs(res["value"] - 134.52) < 1e-4
    assert res["vote"] == "IDA"

    # MCV=77.5, MCH=25.2 -> |80-77.5| * |27-25.2| = 2.5 * 1.8 = 4.50
    res = calculate_bordbar(77.5, 25.2)
    assert abs(res["value"] - 4.50) < 1e-4
    assert res["vote"] == "THALASSAEMIA"


if __name__ == "__main__":
    test_values_below_44_76()
    test_exactly_44_76()
    test_values_above_44_76()
    test_absolute_value_handling()
    test_decimal_inputs()
    print("All Python tests passed successfully!")
