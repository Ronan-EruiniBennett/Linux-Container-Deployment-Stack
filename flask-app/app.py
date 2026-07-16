from flask import Flask, request
import time

app = Flask(__name__)

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
# IoT functionality
#################################################

# IoT Post and Get data Endpoint
@app.route('/IoT/data', methods=['GET', 'POST'])
def hearbeat():
    if request.method == 'POST':
        # TODO: parse request.get_json(), validate device_id is present,
        # INSERT INTO heartbeats (device_id, payload) VALUES (%s, %s) RETURNING id, received_at
        return {"message": "Heartbeat Recorded"}, 201
    if request.method == 'GET':
        # TODO: read request.args (device_id filter, limit), SELECT from heartbeats,
        # ORDER BY received_at DESC LIMIT %s
        return {"message": []}, 200