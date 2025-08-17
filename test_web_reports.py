#!/usr/bin/env python3
"""
Test script to simulate the web reports functionality and debug date issues.
"""

import sqlite3
from datetime import datetime, timedelta

def convert_to_local_date(iso_date):
    try:
        return datetime.strptime(iso_date, "%Y-%m-%d").strftime("%d-%m-%Y")
    except ValueError:
        return iso_date

def test_web_reports():
    conn = sqlite3.connect('quality_control.db')
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    
    # Simulate the reports route logic
    end_date = datetime.now().strftime('%d-%m-%Y')
    start_date = (datetime.now() - timedelta(days=30)).strftime('%d-%m-%Y')
    
    print(f"Default date range: {start_date} to {end_date}")
    
    # Convert to ISO format for database query
    try:
        iso_start_date = datetime.strptime(start_date, "%d-%m-%Y").strftime("%Y-%m-%d")
        iso_end_date = datetime.strptime(end_date, "%d-%m-%Y").strftime("%Y-%m-%d")
        print(f"ISO date range: {iso_start_date} to {iso_end_date}")
    except ValueError as e:
        print(f"Date conversion error: {e}")
        return
    
    # Test detailed measurements query (same as in app.py)
    query = '''
    SELECT p.product_name, d.dimension_name, m.measured_value, d.nominal_value, d.tolerance_plus, d.tolerance_minus,
           m.measurement_date, m.inspector, m.machine_number, m.count
    FROM measurements m
    JOIN dimensions d ON m.dimension_id = d.id
    JOIN products p ON m.product_id = p.id
    WHERE m.measurement_date BETWEEN ? AND ?
    ORDER BY p.product_name, d.dimension_name, m.measurement_date DESC
    '''
    
    cursor.execute(query, [iso_start_date, iso_end_date])
    results = cursor.fetchall()
    
    print(f"\n=== Detailed Measurements Report ===")
    print(f"Found {len(results)} measurements in date range")
    print()
    
    if results:
        headers = ["Product", "Dimension", "Measured Value", "Nominal", "Tolerance (+/-)", "Measurement Date", "Inspector", "Machine", "Count"]
        print("Headers:", headers)
        print()
        
        for i, row in enumerate(results, 1):
            print(f"Row {i}:")
            # Convert date back to local format
            local_date = convert_to_local_date(row['measurement_date'])
            print(f"  Product: {row['product_name']}")
            print(f"  Dimension: {row['dimension_name']}")
            print(f"  Measured Value: {row['measured_value']}")
            print(f"  Nominal: {row['nominal_value']}")
            print(f"  Tolerance (+/-): +{row['tolerance_plus']}/-{row['tolerance_minus']}")
            print(f"  Measurement Date: {local_date}")
            print(f"  Inspector: {row['inspector']}")
            print(f"  Machine: {row['machine_number']}")
            print(f"  Count: {row['count']}")
            print()
    else:
        print("No measurements found in the specified date range!")
        print("This might be why the reports are showing empty data.")
        
        # Check what measurements exist
        cursor.execute("SELECT DISTINCT measurement_date FROM measurements ORDER BY measurement_date")
        dates = cursor.fetchall()
        print("Available measurement dates:")
        for date_row in dates:
            print(f"  {date_row[0]}")
    
    conn.close()

if __name__ == "__main__":
    test_web_reports() 