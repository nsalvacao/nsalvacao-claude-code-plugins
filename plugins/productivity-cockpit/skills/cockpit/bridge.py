import http.server
import json
import os
import socketserver
import subprocess
import urllib.request
from pathlib import Path

PORT = 8001
DIRECTORY = Path(__file__).parent

# Allowed CLI binaries for /api/exec (whitelist for security)
ALLOWED_CLIS = {"claude", "gemini", "copilot", "codex", "ollama"}


def load_config():
    """Load .cockpit.json from the project root, with defaults."""
    root = get_project_root_static()
    config_path = root / ".cockpit.json"
    config = {}
    if config_path.exists():
        with open(config_path, encoding="utf-8") as f:
            config = json.load(f)
    # Defaults
    ai = config.get("ai", {})
    ai.setdefault("mode", "cli")
    ai.setdefault("cli", "claude")
    ai.setdefault("args", [])
    ai.setdefault("provider", "anthropic")
    ai.setdefault("model", "")
    config["ai"] = ai
    return config


def get_project_root_static():
    """Walk up from DIRECTORY to find project root."""
    root = DIRECTORY.resolve()
    for _ in range(6):
        if (root / ".git").exists() or (root / ".cockpit.json").exists():
            return root
        root = root.parent
    return Path.cwd()


def exec_cli(cli_name, args):
    """Execute an AI CLI binary as a subprocess."""
    if cli_name not in ALLOWED_CLIS:
        return {"error": f"CLI '{cli_name}' not in whitelist. Allowed: {', '.join(sorted(ALLOWED_CLIS))}"}

    cmd_to_run = cli_name
    if os.name == "nt":
        try:
            subprocess.run(
                [cli_name, "--version"],
                capture_output=True, text=True, check=False,
            )
        except FileNotFoundError:
            cmd_to_run = f"{cli_name}.cmd"

    try:
        result = subprocess.run(
            [cmd_to_run] + list(args),
            capture_output=True, text=True, check=False,
        )
        return {
            "stdout": result.stdout,
            "stderr": result.stderr,
            "exit_code": result.returncode,
        }
    except FileNotFoundError:
        return {"error": f"Command '{cmd_to_run}' not found. Make sure it is installed and on your PATH."}
    except Exception as e:
        return {"error": str(e)}


def exec_api(provider, model, prompt):
    """Call an AI provider API directly via HTTP."""
    providers = {
        "anthropic": {
            "url": "https://api.anthropic.com/v1/messages",
            "env_key": "ANTHROPIC_API_KEY",
            "build_request": lambda key, model, prompt: (
                {"Content-Type": "application/json", "x-api-key": key, "anthropic-version": "2023-06-01"},
                json.dumps({"model": model or "claude-sonnet-4-5-20250929", "max_tokens": 1024, "messages": [{"role": "user", "content": prompt}]}).encode(),
            ),
            "parse_response": lambda data: data.get("content", [{}])[0].get("text", ""),
        },
        "openai": {
            "url": "https://api.openai.com/v1/chat/completions",
            "env_key": "OPENAI_API_KEY",
            "build_request": lambda key, model, prompt: (
                {"Content-Type": "application/json", "Authorization": f"Bearer {key}"},
                json.dumps({"model": model or "gpt-4o", "messages": [{"role": "user", "content": prompt}]}).encode(),
            ),
            "parse_response": lambda data: data.get("choices", [{}])[0].get("message", {}).get("content", ""),
        },
        "google": {
            "url": "https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent",
            "env_key": "GOOGLE_API_KEY",
            "build_request": lambda key, model, prompt: (
                {"Content-Type": "application/json", "x-goog-api-key": key},
                json.dumps({"contents": [{"parts": [{"text": prompt}]}]}).encode(),
            ),
            "parse_response": lambda data: data.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", ""),
        },
        "ollama": {
            "url": "http://localhost:11434/api/generate",
            "env_key": None,
            "build_request": lambda key, model, prompt: (
                {"Content-Type": "application/json"},
                json.dumps({"model": model or "llama3.1:8b", "prompt": prompt, "stream": False}).encode(),
            ),
            "parse_response": lambda data: data.get("response", ""),
        },
    }

    if provider not in providers:
        return {"error": f"Unknown provider '{provider}'. Supported: {', '.join(sorted(providers))}"}

    spec = providers[provider]
    api_key = os.environ.get(spec["env_key"], "") if spec["env_key"] else ""
    if spec["env_key"] and not api_key:
        return {"error": f"Set {spec['env_key']} environment variable for {provider} API access."}

    try:
        url = spec["url"].format(model=model or "gemini-2.0-flash")
        headers, body = spec["build_request"](api_key, model, prompt)
        req = urllib.request.Request(url, data=body, headers=headers, method="POST")
        with urllib.request.urlopen(req, timeout=60) as resp:
            data = json.loads(resp.read().decode())
        text = spec["parse_response"](data)
        return {"stdout": text, "stderr": "", "exit_code": 0}
    except urllib.error.HTTPError as e:
        error_body = e.read().decode() if e.fp else str(e)
        return {"error": f"{provider} API error ({e.code}): {error_body}"}
    except Exception as e:
        return {"error": f"{provider} API call failed: {str(e)}"}


class CockpitHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(DIRECTORY), **kwargs)

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "http://localhost:8001")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def do_GET(self):
        if self.path == "/api/status":
            config = load_config()
            self.send_json({
                "status": "online",
                "version": "2.0.0",
                "project_root": str(get_project_root_static()),
                "ai": config["ai"],
            })
        elif self.path == "/api/config":
            self.send_json(load_config())
        else:
            super().do_GET()

    def do_POST(self):
        try:
            content_length = int(self.headers["Content-Length"])
            post_data = json.loads(self.rfile.read(content_length))
        except Exception as e:
            self.send_error_json(f"Invalid JSON: {str(e)}")
            return

        if self.path == "/api/exec":
            config = load_config()
            ai = config["ai"]
            prompt = post_data.get("prompt", "")

            # Allow override from request, fall back to config
            mode = post_data.get("mode", ai["mode"])

            if mode == "api":
                provider = post_data.get("provider", ai.get("provider", "anthropic"))
                model = post_data.get("model", ai.get("model", ""))
                result = exec_api(provider, model, prompt)
            else:
                cli = post_data.get("cli", ai.get("cli", "claude"))
                extra_args = ai.get("args", [])
                result = exec_cli(cli, extra_args + [prompt])

            if "error" in result:
                self.send_error_json(result["error"])
            else:
                self.send_json(result)

        elif self.path == "/api/fs/write":
            rel_path = post_data.get("path")
            content = post_data.get("content")
            project_root = get_project_root_static()
            full_path = (project_root / rel_path).resolve()

            if not str(full_path).startswith(str(project_root)):
                self.send_response(403)
                self.end_headers()
                self.wfile.write(b"Forbidden: Path outside project root")
                return

            try:
                os.makedirs(full_path.parent, exist_ok=True)
                with open(full_path, "w", encoding="utf-8") as f:
                    f.write(content)
                self.send_json({"success": True})
            except Exception as e:
                self.send_error_json(str(e))
        else:
            self.send_response(404)
            self.end_headers()

    def send_json(self, data):
        self.send_response(200)
        self.send_header("Content-type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode("utf-8"))

    def send_error_json(self, message):
        self.send_response(500)
        self.send_header("Content-type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps({"error": message}).encode("utf-8"))


def run_server(port):
    try:
        with socketserver.TCPServer(("", port), CockpitHandler) as httpd:
            config = load_config()
            ai = config["ai"]
            print(f"Cockpit Bridge running at http://localhost:{port}")
            print(f"AI mode: {ai['mode']} ({ai.get('cli') or ai.get('provider')})")
            print(f"Serving files from: {DIRECTORY}")
            httpd.serve_forever()
    except OSError as e:
        if e.errno in (98, 10048):
            print(f"Port {port} is busy, trying {port + 1}...")
            run_server(port + 1)
        else:
            raise e


if __name__ == "__main__":
    try:
        run_server(PORT)
    except KeyboardInterrupt:
        print("\nStopping Bridge...")
