import sys
from pathlib import Path

# Allow imports from lambda/etl_customer without installing as a package.
sys.path.insert(0, str(Path(__file__).parent / ".." / "lambda"))
