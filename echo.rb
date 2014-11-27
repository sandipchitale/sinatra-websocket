require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, []

get '/' do
  if !request.websocket?
    erb :index
  else
    request.websocket do |ws|
      ws.onopen do
        settings.sockets << ws
      end
      ws.onmessage do |msg|
        EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
      end
      ws.onclose do
        warn("wetbsocket closed")
        settings.sockets.delete(ws)
      end
    end
  end
end

__END__
@@ index
<html>
  <head>
    <link rel="icon" href="data:;base64,=">
  </head>
  <body>
     <h1>Simple Echo and Chat Server</h1>
     <form id="form">
       <input type="text" id="input" placeholder="send a message"></input>
     </form>
     <div id="msgs" style="font-family: 'Courier New', 'monospace';"></div>
  </body>

  <script type="text/javascript">
    window.onload = function(){
      (function(){
        var show = function(el){

          return function(msg){
            var ts = new Date();
            var ms = ts.getMilliseconds();
            ms = ((ms<10)?"00": (ms<100)?"0": "") + ms;
            el.innerHTML = ts.toLocaleString() + ':' + ms + ' ---- ' + msg + '<br />' + el.innerHTML;
          }
        }(document.getElementById('msgs'));

        var ws       = new WebSocket('wss://' + window.location.host + window.location.pathname);
        ws.onopen    = function()  { show("websocket opened"); };
        ws.onclose   = function()  { show("websocket closed"); }
        ws.onmessage = function(m) { show("websocket message: " +  m.data); };

        var sender = function(f){
          var input     = document.getElementById('input');
          f.onsubmit    = function(){
            ws.send(input.value);
            input.value = "";
            return false;
          }
        }(document.getElementById('form'));
      })();
    }
  </script>
</html>

