"""Pure transformation logic — unit-testable without AWS."""

from datetime import datetime


def normalize_currency(currency: str) -> str:
    return currency.strip().upper()


def parse_amount(amount: str) -> float:
    return round(float(amount.strip()), 2)


def parse_order_date(order_date: str) -> str:
    parsed = datetime.strptime(order_date.strip(), "%Y-%m-%d")
    return parsed.strftime("%Y-%m-%d")


def row_to_record(row: dict, source_key: str) -> dict:
    return {
        "order_id": row["order_id"].strip(),
        "customer_id": row["customer_id"].strip(),
        "amount": parse_amount(row["amount"]),
        "order_date": parse_order_date(row["order_date"]),
        "currency": normalize_currency(row["currency"]),
        "source_key": source_key,
    }
