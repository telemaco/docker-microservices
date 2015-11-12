from flask import Flask
from crossdomain import crossdomain

import socket
app = Flask(__name__)


@app.route('/')
@crossdomain(origin='*')
def hello():
    return 'Hello World from %s\n' % socket.gethostname()


if __name__ == "__main__":
    app.run()
