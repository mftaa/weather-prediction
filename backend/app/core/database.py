"""
Database connection and utilities
"""
import MySQLdb
from contextlib import contextmanager
from typing import Generator
from app.core.config import settings

def get_db_connection():
    """
    Create a new database connection.
    Note: Connection should be closed after use to avoid stale connections.
    """
    return MySQLdb.connect(**settings.get_db_config())

@contextmanager
def get_db() -> Generator:
    """
    Context manager for database connections.
    Automatically closes connection after use.
    
    Usage:
        with get_db() as conn:
            cursor = conn.cursor()
            # ... use cursor
    """
    conn = get_db_connection()
    try:
        yield conn
    finally:
        conn.close()

@contextmanager
def get_cursor() -> Generator:
    """
    Context manager for database cursor.
    Automatically commits and closes connection.
    
    Usage:
        with get_cursor() as cursor:
            cursor.execute("SELECT * FROM users")
            results = cursor.fetchall()
    """
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        yield cursor
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise e
    finally:
        cursor.close()
        conn.close()
