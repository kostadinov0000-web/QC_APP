#!/usr/bin/env python3
"""
Script to add test measurements data for demonstrating the reports functionality.
"""

import sqlite3
from datetime import datetime, timedelta
import random

def add_test_data():
    conn = sqlite3.connect('quality_control.db')
    cursor = conn.cursor()
    
    # Check if we have products and dimensions
    cursor.execute("SELECT id FROM products")
    products = cursor.fetchall()
    
    if not products:
        # print("No products found. Please add products first.")
        return
    
    cursor.execute("SELECT id FROM dimensions")
    dimensions = cursor.fetchall()
    
    if not dimensions:
        # print("No dimensions found. Please add dimensions first.")
        return
    
    # Add some test measurements for the last 30 days
    end_date = datetime.now()
    start_date = end_date - timedelta(days=30)
    
    # Sample data for different machines and inspectors
    machines = ["Machine A", "Machine B", "Machine C"]
    inspectors = ["John Doe", "Jane Smith", "Mike Johnson"]
    
    measurements_added = 0
    
    for i in range(20):  # Add 20 test measurements
        # Random date within the last 30 days
        random_days = random.randint(0, 30)
        measurement_date = end_date - timedelta(days=random_days)
        
        # Random product and dimension
        product_id = random.choice(products)[0]
        dimension_id = random.choice(dimensions)[0]
        
        # Get nominal value and tolerance for realistic measurements
        cursor.execute("SELECT nominal_value, tolerance_plus, tolerance_minus FROM dimensions WHERE id = ?", (dimension_id,))
        dim_data = cursor.fetchone()
        
        if dim_data:
            nominal, tol_plus, tol_minus = dim_data
            
            # Generate realistic measurement value within tolerance
            min_val = nominal - tol_minus
            max_val = nominal + tol_plus
            measured_value = round(random.uniform(min_val, max_val), 3)
            
            # Random machine and inspector
            machine = random.choice(machines)
            inspector = random.choice(inspectors)
            count = random.randint(1, 10)
            
            try:
                cursor.execute("""
                    INSERT INTO measurements (product_id, dimension_id, measured_value, measurement_date, machine_number, count, inspector)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                """, (product_id, dimension_id, measured_value, measurement_date.strftime('%Y-%m-%d'), machine, count, inspector))
                measurements_added += 1
            except Exception as e:
                # print(f"Error adding measurement: {e}")
                pass
    
    conn.commit()
    conn.close()
    
    # print(f"Added {measurements_added} test measurements successfully!")
    # print("You can now test the reports functionality with this data.")

if __name__ == "__main__":
    add_test_data() 