import os
from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        user = os.environ.get("TELEPORT_USER", "anonymous")
        role = os.environ.get("TELEPORT_ROLES", "unknown")

        if self.path == "/healthz":
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"ok")
            return

        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()
        body = f"hello from teleport demo app\nuser={user}\nroles={role}\npath={self.path}\n"
        self.wfile.write(body.encode("utf-8"))


def main():
    port = int(os.environ.get("APP_PORT", "8000"))
    server = HTTPServer(("0.0.0.0", port), Handler)
    print(f"Starting demo app on port {port}", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()

