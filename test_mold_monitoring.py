#!/usr/bin/env python3
"""
Test script for mold monitoring functionality
"""

import sqlite3
from datetime import datetime

def test_mold_monitoring():
    print("Testing Mold Monitoring Functionality...")
    
    # Connect to database
    conn = sqlite3.connect('quality_control.db')
    cursor = conn.cursor()
    
    try:
        # Check if molds table exists
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='molds'")
        if cursor.fetchone():
            print("✓ Molds table exists")
        else:
            print("✗ Molds table does not exist")
            return
        
        # Check if rework_history table exists
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='rework_history'")
        if cursor.fetchone():
            print("✓ Rework history table exists")
        else:
            print("✗ Rework history table does not exist")
            return
        
        # Check if maintenance_schedule table exists
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='maintenance_schedule'")
        if cursor.fetchone():
            print("✓ Maintenance schedule table exists")
        else:
            print("✗ Maintenance schedule table does not exist")
            return
        
        # Check for existing products and molds
        cursor.execute("SELECT COUNT(*) FROM products")
        product_count = cursor.fetchone()[0]
        print(f"✓ Found {product_count} products")
        
        cursor.execute("SELECT COUNT(*) FROM molds")
        mold_count = cursor.fetchone()[0]
        print(f"✓ Found {mold_count} molds")
        
        # Show some mold details
        cursor.execute("""
        SELECT m.mold_name, m.mold_number, m.total_cycles, p.product_name
        FROM molds m
        JOIN products p ON m.product_id = p.id
        LIMIT 5
        """)
        molds = cursor.fetchall()
        
        if molds:
            print("\nSample molds:")
            for mold in molds:
                print(f"  - {mold[0]} ({mold[1]}) - {mold[2]} cycles - Product: {mold[3]}")
        else:
            print("  No molds found")
        
        # Test adding a sample rework record
        cursor.execute("SELECT id FROM molds LIMIT 1")
        mold_id = cursor.fetchone()
        
        if mold_id:
            mold_id = mold_id[0]
            current_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            
            cursor.execute("""
            INSERT INTO rework_history (mold_id, rework_type, rework_date, technician, description, cost)
            VALUES (?, ?, ?, ?, ?, ?)
            """, (mold_id, 'test_repair', current_date, 'Test Technician', 'Test rework record', 100.50))
            
            conn.commit()
            print("✓ Added test rework record")
            
            # Clean up test data
            cursor.execute("DELETE FROM rework_history WHERE technician = 'Test Technician'")
            conn.commit()
            print("✓ Cleaned up test data")
        
        print("\n✓ All mold monitoring tests passed!")
        
    except Exception as e:
        print(f"✗ Error during testing: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    test_mold_monitoring() 