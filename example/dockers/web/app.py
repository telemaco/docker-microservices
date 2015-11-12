from flask import Flask
from crossdomain import crossdomain

import socket
app = Flask(__name__)


@app.route('/')
@crossdomain(origin='*')
def web():
    return """
<!DOCTYPE html>
<html>
<head>
<title>Hello web</title>
<script type='text/javascript' src='http://code.jquery.com/jquery-1.11.0.min.js'></script>
<script type="text/javascript">

function refresh() {
    $.get( "http://hello.api.dev", function( data ) {
        $( ".content" ).prepend( "<p>" + data + "</p>" );
    });
}
</script>
</head>
<body>


<button type="submit" onclick="refresh()">Say Hello! (from %s)</button>
<div class="content" ></div>
</body>
</html>

""" % (socket.gethostname())


if __name__ == "__main__":
    app.run()
