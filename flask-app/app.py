from flask import Flask, request
import time
import os
import psycopg2

app = Flask(__name__)

def get_db_connection():
    return psycopg2.connect(os.environ['DATABASE_URL'])

def query_builder(server=None, status=None):
    base_query ="""
                SELECT 
                    heartbeat_id,
                    server_id,
                    received_at,
                    server_status
                FROM heartbeats 
                """
    
    params = []
    conditions = []

    if server:
        conditions.append("server_id = %s")
        params.append(server)

    if status:
        conditions.append("server_status = %s")
        params.append(status)
    
    if conditions:
        base_query +=" WHERE " + " AND ".join(conditions)

    base_query += " ORDER BY received_at DESC;"

    return base_query, params

#################################################
# APP specific meta data endpoints
#################################################

requests_count = 0
start_time = time.time()

@app.before_request
def requests_counter():
    global requests_count
    requests_count += 1

# Home route
@app.route('/', methods=['GET'])
def home():
    return {
        "Project": "Infrastructure operations lab"
        }, 200

# Health check endpoint
@app.route('/health', methods=['GET'])
def health():
    return {
        "status": "healthy"
        }, 200

# Version endpoint
@app.route('/version', methods=['GET'])
def version():
    return {
        "version": "1.0.0"
        }, 200

# Metric endpoint
@app.route('/metrics', methods=['GET'])
def metric():
    up_time = int(time.time() - start_time)
    return {
        "requests": requests_count, 
        "uptime": f"{up_time} seconds"
        }, 200


#################################################
# Server monitoring functionality
#################################################

# Server Post and Get data Endpoint
@app.post('/server/data')
def post_hearbeat():
    data = request.get_json(silent=True)

    if data is None:
        return {"error": "Request body must contain valid JSON"}, 400
    
    serverID = data.get('server_id')
    status = data.get('server_status')

    if not serverID:
        return {"error": "Invalid Server ID data"}, 400
    
    if not status:
        return {"error": "Invalid data for server_status"}, 400
    
    try:
        connection = get_db_connection()
    except psycopg2.Error:
        return {"error": "Could not connect to database"}, 500
    
    try:
        with connection:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                INSERT INTO heartbeats (
                server_id,
                server_status
                )

                VALUES (%s,%s)
                RETURNING heartbeat_id, received_at;
                    """,
                (serverID,status)
                )
                
                heartbeat_id, received_at = cursor.fetchone()


        return {"message": "Heartbeat Recorded",
                "heartbeat_id": heartbeat_id,
                "time recorded": received_at}, 201
    
    except psycopg2.Error:
        app.logger.exception("Failed to store heartbeat")
        return {"error": "Database operation failure"}, 500
    
    finally:
        connection.close()

@app.get('/server/data')
def get_heartbeat(): 
    try:
        connection = get_db_connection()
    except psycopg2.Error:
        return {"error": "Could not connect to database"}, 500
    
    server = request.args.get("server_id")
    status = request.args.get("server_status")

    query, params = query_builder(server, status)

    try:
        with connection:
            with connection.cursor() as cursor:
                cursor.execute(query, params)

                rows = cursor.fetchall()

                results = []
                for row in rows:
                    results.append({
                        "id":row[0],
                        "server":row[1],
                        "received_at":row[2],
                        "status":row[3]
                    })

                return {"message" : "here are your rows",
                        "data" : results}
        
    except psycopg2.Error:
        app.logger.exception("Failed to retrieve heartbeat")
        return {"error": "Database operation failure"}, 500
    
    finally:
        connection.close()