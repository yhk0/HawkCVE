import requests
import json
import sys
from datetime import datetime

def check_python_dependencies():
    try:
        import requests
    except ImportError:
        print(json.dumps({"error": "Python module 'requests' is not installed. Run 'pip install requests'."}))
        sys.exit(1)

def get_server_version(url):
    try:
        response = requests.get(url)
        server_header = response.headers.get('Server', '')
        return server_header
    except requests.exceptions.RequestException as e:
        return f"Error accessing the site: {e}"

def search_cves(version):
    try:
        url = f"https://cve.circl.lu/api/search/{version}"
        response = requests.get(url)
        if response.status_code == 200:
            return response.json()
        else:
            return {"error": "No CVEs found or API error."}
    except requests.exceptions.RequestException as e:
        return {"error": f"Error fetching CVEs: {e}"}

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "URL not provided."}))
        return

    url = sys.argv[1]
    print(f"Analyzing URL: {url}", file=sys.stderr)  # Log para depuração

    server_version = get_server_version(url)
    print(f"Server version: {server_version}", file=sys.stderr)  # Log para depuração

    if "Error" in server_version:
        print(json.dumps({"error": server_version}))
        return

    cves = search_cves(server_version)
    print(f"CVEs found: {cves}", file=sys.stderr)  # Log para depuração

    result = {
        "url": url,
        "server_version": server_version,
        "cves": cves,
        "timestamp": datetime.now().isoformat()
    }
    print(json.dumps(result, indent=2))

if __name__ == "__main__":
    check_python_dependencies()
    main()