#!/usr/bin/env python3
"""
Test script to check the reports functionality and debug date issues.
"""

import sqlite3
from datetime import datetime, timedelta

def test_reports():
    conn = sqlite3.connect('quality_control.db')
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    
    # Test the detailed measurements query
    query = '''
    SELECT p.product_name, d.dimension_name, m.measured_value, d.nominal_value, d.tolerance_plus, d.tolerance_minus,
           m.measurement_date, m.inspector, m.machine_number, m.count
    FROM measurements m
    JOIN dimensions d ON m.dimension_id = d.id
    JOIN products p ON m.product_id = p.id
    ORDER BY p.product_name, d.dimension_name, m.measurement_date DESC
    LIMIT 5
    '''
    
    cursor.execute(query)
    results = cursor.fetchall()
    
    print("=== Detailed Measurements Report Test ===")
    print(f"Found {len(results)} measurements")
    print()
    
    for i, row in enumerate(results, 1):
        print(f"Measurement {i}:")
        print(f"  Product: {row['product_name']}")
        print(f"  Dimension: {row['dimension_name']}")
        print(f"  Measured Value: {row['measured_value']}")
        print(f"  Nominal: {row['nominal_value']}")
        print(f"  Tolerance: +{row['tolerance_plus']}/-{row['tolerance_minus']}")
        print(f"  Date: {row['measurement_date']} (type: {type(row['measurement_date'])})")
        print(f"  Inspector: {row['inspector']}")
        print(f"  Machine: {row['machine_number']}")
        print(f"  Count: {row['count']}")
        print()
    
    # Test date conversion
    print("=== Date Conversion Test ===")
    for row in results:
        iso_date = row['measurement_date']
        print(f"ISO date: {iso_date}")
        try:
            local_date = datetime.strptime(iso_date, "%Y-%m-%d").strftime("%d-%m-%Y")
            print(f"Converted to: {local_date}")
        except Exception as e:
            print(f"Conversion error: {e}")
        print()
    
    conn.close()

if __name__ == "__main__":
    test_reports() 