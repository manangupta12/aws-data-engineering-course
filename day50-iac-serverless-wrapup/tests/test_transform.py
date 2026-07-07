from etl_orders.transform import normalize_currency, parse_amount, parse_order_date, row_to_record


def test_normalize_currency():
    assert normalize_currency(" usd ") == "USD"


def test_parse_amount_strips_whitespace():
    assert parse_amount(" 15.00 ") == 15.0


def test_parse_order_date():
    assert parse_order_date("2026-01-15") == "2026-01-15"


def test_row_to_record_maps_fields():
    row = {
        "order_id": " ORD-001 ",
        "customer_id": "C001",
        "amount": "49.99",
        "order_date": "2026-01-15",
        "currency": "usd",
    }
    record = row_to_record(row, "incoming/orders.csv")
    assert record["order_id"] == "ORD-001"
    assert record["amount"] == 49.99
    assert record["currency"] == "USD"
    assert record["source_key"] == "incoming/orders.csv"
