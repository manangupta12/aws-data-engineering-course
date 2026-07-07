from etl_customer.transform import clean_email, row_to_item


def test_clean_email_normalizes_case_and_whitespace():
    assert clean_email("  User@Example.COM  ") == "user@example.com"


def test_row_to_item_maps_fields():
    row = {
        "customer_id": "C001",
        "name": "  Alice  ",
        "email": "ALICE@EXAMPLE.COM",
        "city": "  NYC  ",
    }
    item = row_to_item(row, "data/customer.csv")
    assert item["customer_id"] == "C001"
    assert item["name"] == "Alice"
    assert item["email"] == "alice@example.com"
    assert item["city"] == "NYC"
    assert item["source_key"] == "data/customer.csv"
