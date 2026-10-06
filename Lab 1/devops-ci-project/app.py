from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({
        "status": "success",
        "message": "Welcome to DevOps CI/CD Automated Pipeline!",
        "developer": "Anurag Pandey",
        "course": "B.Tech CSE - DevOps Lab",
        "version": "1.0.0"
    }), 200

@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "service": "devops-ci-app",
        "uptime": "active"
    }), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
