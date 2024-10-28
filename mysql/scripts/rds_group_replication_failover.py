"""
RDS for MySQL
Simple RDS failover monitoring script, leveraging only the DNS endpoints. This scripts
connects to the database using the RDS end-point approx. every few seconds and checks the hostname. 

Dependencies:
none

License:
This sample code is made available under the MIT-0 license. See the LICENSE file.
"""

# Dependencies
import sys
import argparse
import time
import socket
import random
import pymysql
import datetime
import json
import urllib3
from os import environ

# Define parser
parser = argparse.ArgumentParser()
parser.add_argument('-e', '--endpoint', help="The database endpoint", required=True)
parser.add_argument('-p', '--password', help="The database user password", required=True)
parser.add_argument('-u', '--username', help="The database user name", required=True)
args = parser.parse_args()

# Instructions
print("Press Ctrl+C to quit this test...")

# Global variables
initial = True
failover_detected = False
failover_start_time = None


# Loop Indefinitely
while True:
    try:
        # Resolve the endpoint
        host = socket.gethostbyname(args.endpoint)

        # Take timestamp
        conn_start_time = time.time()

        # Connect to the cluster endpoint
        conn = pymysql.connect(host=args.endpoint, user=args.username, password=args.password, database='information_schema', autocommit=True, connect_timeout=1)

        # Query status
        sql_command = "SELECT @@hostname, @@version;"

        # Run the query
        with conn.cursor() as cursor:
            cursor.execute(sql_command)
            (hostname, version) = cursor.fetchone()
            cursor.close()

        # Take timestamp
        conn_end_time = time.time()

        # Close the connection
        conn.close()


        if failover_detected:
            failover_detected = True
            failover_end_time = conn_end_time
            print("[SUCCESS]", "%s: failover completed, took: ~ %d sec., connected to %s (%s)" % (time.strftime('%H:%M:%S %Z'), (failover_end_time - failover_start_time), hostname, version))
        else:
            failover_start_time = conn_start_time
            failover_detected = False
            print("[INFO]", "%s: connected to %s (%s)" % (time.strftime('%H:%M:%S %Z'), hostname, version))

        # No longer in the initial loop
        failover_detected = False
        initial = True;

        # Wait 1 second
        time.sleep(5)

    # Trap keyboard interrupt, exit
    except KeyboardInterrupt:
        sys.exit("\nStopped by the user")

    # Deal with MySQL connection errors
    except pymysql.MySQLError as e:
        # Get the error code and message
        error_code = e.args[0]
        error_message = e.args[1]

        # Can't connect, assume failover
        if error_code == 2003 or error_code == 2005 or error_code == 2006 or error_code == 2013:
            # Detect failover
            if not failover_detected:
                failover_start_time = conn_start_time
            failover_detected = True

            # Display error
            print("[ERROR]", "%s: can't connect to the database (MySQL error: %d)!" % (time.strftime('%H:%M:%S %Z'), error_code))

            # Wait 1 second
            time.sleep(1)

        # Connected to a proxy
        elif error_code == 1105 and args.endpoint.find('.proxy-') > 0:
            # Detect failover
            if not failover_detected:
                failover_start_time = conn_start_time
            failover_detected = True

            # Display error
            print("[ERROR]", "%s: can't connect to the database (MySQL error: %d)!" % (time.strftime('%H:%M:%S %Z'), error_code))

            # Wait 1 second
            time.sleep(1)

        else:
            # Display error
            print("[ERROR]", "%s, MySQL Error %d: %s" % (time.strftime('%H:%M:%S %Z'), error_code, error_message))
            sys.exit("\nUnexpected MySQL error encountered")

    # Any other error bail out
    except:
        print(sys.exc_info()[1])
        sys.exit("\nUnexpected error encountered")
