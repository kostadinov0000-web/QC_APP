"""reset_data.py
Utility script to clear product-related information from the SQLite database and
remove all uploaded drawing PDF files.

Usage:
    python reset_data.py [--yes]

If the optional --yes flag is provided, the script will run without an extra
interactive confirmation prompt.
"""

import argparse
import os
import sqlite3
import sys
from pathlib import Path

# Default database path (matches app.py logic)
DATABASE_PATH = os.environ.get("DATABASE_PATH", "quality_control.db")
# Directory that holds uploaded drawing PDF files
DRAWINGS_DIR = Path("static") / "drawings"

# SQL statements to clear necessary tables (order matters due to FK constraints)
SQL_STATEMENTS = [
    "DELETE FROM measurements;",
    "DELETE FROM dimensions;",
    "DELETE FROM machine_last_product;",
    "DELETE FROM machine_mold_assignments;",
    "DELETE FROM molds;",
    "DELETE FROM products;",
]

def confirm(question: str) -> bool:
    """Prompt the user for a yes/no answer. Returns True if yes."""
    try:
        return input(f"{question} [y/N]: ").strip().lower() == "y"
    except EOFError:
        return False


def clear_database(db_path: str) -> None:
    """Execute the SQL_STATEMENTS against the provided SQLite database."""
    if not Path(db_path).exists():
        print(f"Database file '{db_path}' not found – nothing to clear.")
        return
    with sqlite3.connect(db_path) as conn:
        cursor = conn.cursor()
        for stmt in SQL_STATEMENTS:
            cursor.execute(stmt)
        conn.commit()
    print("Database tables cleared successfully.")


def delete_drawing_files(drawings_dir: Path) -> None:
    """Delete all PDF files in the drawings directory."""
    if not drawings_dir.exists():
        print(f"Directory '{drawings_dir}' does not exist – nothing to delete.")
        return
    deleted = 0
    for file_path in drawings_dir.glob("*.pdf"):
        try:
            file_path.unlink()
            deleted += 1
        except Exception as exc:
            print(f"Could not delete {file_path}: {exc}")
    print(f"Deleted {deleted} PDF file(s) from '{drawings_dir}'.")


def main() -> None:
    parser = argparse.ArgumentParser(description="Reset product, mold and measurement data.")
    parser.add_argument("--yes", action="store_true", help="Skip interactive confirmation prompt.")
    args = parser.parse_args()

    if not args.yes and not confirm("This will permanently delete all product, mold and measurement data. Continue?"):
        print("Aborted.")
        sys.exit(1)

    clear_database(DATABASE_PATH)
    delete_drawing_files(DRAWINGS_DIR)
    print("Reset completed.")


if __name__ == "__main__":
    main() 