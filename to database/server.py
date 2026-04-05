from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import os
from datetime import datetime

SAVE_DIR = "database"
os.makedirs(SAVE_DIR, exist_ok=True)

class Handler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self._cors()
        self.end_headers()

    def do_POST(self):
        length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(length)
        data = json.loads(body)

        # Save with timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        event_type = data.get("type", "event")
        filename = f"{SAVE_DIR}/{event_type}_{timestamp}.json"

        with open(filename, "w") as f:
            json.dump(data, f, indent=2)

        print(f"[{timestamp}] Saved: {filename}")

        self.send_response(200)
        self._cors()
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps({"status": "saved", "file": filename}).encode())

    def _cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")

    def log_message(self, format, *args):
        pass  # suppress default logs

print("Smart Home DB Server running on http://localhost:8080")
print(f"Saving files to: {os.path.abspath(SAVE_DIR)}/")
HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
