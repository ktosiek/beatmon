from datetime import datetime, timedelta
import getpass
from os.path import expanduser

from gql import gql, Client                                                                 
from gql.transport.requests import RequestsHTTPTransport                                                                                                        
import jwt


class Agent():
    def __init__(self):
        _transport = RequestsHTTPTransport(
            url='http://localhost:5000/graphql',
            use_json=True,
        )
         
        self.client = Client(
            transport=_transport,
            fetch_schema_from_transport=True,
        )
        self._token = None

    def main(self, argv):
        if len(argv) < 2:
            self.usage(argv[0])
        elif argv[1] == 'login':
            self.login(*argv[2:])
        elif argv[1] == 'beat':
            self.beat(*argv[2:])
        elif argv[1] == 'ls':
            self.ls(*argv[2:])
        elif argv[1] == 'beat-set-name':
            self.beat_set_name(*argv[2:])
        elif argv[1] == 'beat-set-timeout':
            self.beat_set_timeout(*argv[2:])
        elif argv[1] == 'beat-create':
            self.beat_create(*argv[2:])
        else:
            self.usage(argv[0])

    def login(self, username, password=None):
        if password is None:
            password = getpass.getpass()
        self._authenticate(username, password)

    def beat(self, heartbeat_id):
        self._load_token()
        self._send_heartbeat(heartbeat_id)
        if self.should_refresh_token:
            self._refresh_token()

    def ls(self):
        self._load_token()
        heartbeats = self._get_heartbeats()
        for hb in heartbeats:
            print("{} {} {}".format(hb['heartbeatId'], hb['lastSeen'] or 'never' + ' ' * 21, hb['name'] or ''))

    def beat_set_name(self, uuid, name):
        self._load_token()
        beat = self._get_heartbeat(uuid)
        self._update_heartbeat(dict(beat, name=name))

    def beat_set_timeout(self, uuid, timeout):
        self._load_token()
        beat = self._get_heartbeat(uuid)
        self._update_heartbeat(dict(beat, notifyAfterSeconds=int(timeout)))

    def beat_create(self, name=None):
        self._load_token()
        beat = self._create_heartbeat(name)
        print("Created new heartbeat {}".format(beat['heartbeatId']))

    def usage(self, progname):
        print("Usage: {} [login username|beat heartbeat_id|ls|beat-set-name id name|beat-set-timeout id seconds|beat-create [name]]".format(progname))

    @property
    def token(self):
        if not self._token:
            self._load_token()
        return self._token

    @property
    def claims(self):
        if self.token:
            return jwt.decode(self._token, verify=False)

    @property
    def should_refresh_token(self):
        time_left = datetime.fromtimestamp(self.claims['exp']) - datetime.now()
        return time_left < timedelta(days=1)

    def _load_token(self):
        with open(self._token_path, 'r') as f:
            raw_token = f.read()
        self._token = raw_token
        self.client.transport.headers = {
            'Authorization': 'Bearer ' + raw_token.strip(),
        }

    def _authenticate(self, username, password):
        response = self.client.execute(AUTHENTICATE, variable_values={
            'email': username,
            'password': password,
        })
        token = response['authenticate']['jwtToken']
        self._save_token(token)

    def _send_heartbeat(self, heartbeat_id):
        self.client.execute(HEARTBEAT, variable_values={
            'heartbeatId': heartbeat_id,
        })

    def _get_heartbeats(self):
        response = self.client.execute(ALL_HEARTBEATS)
        return response['allHeartbeats']['nodes']

    def _get_heartbeat(self, uuid):
        response = self.client.execute(HEARTBEATS_BY_ID, variable_values={
            'uuid': uuid,
        })
        nodes = response['allHeartbeats']['nodes']
        return nodes[0] if nodes else None

    def _update_heartbeat(self, beat):
        self.client.execute(UPDATE_HEARTBEAT, variable_values=beat)

    def _create_heartbeat(self, name):
        response = self.client.execute(CREATE_HEARTBEAT, variable_values={
            'name': name or None,
        })
        return response['createHeartbeat']['heartbeat']

    def _refresh_token(self):
        response = self.client.execute(REFRESH_TOKEN)
        token = response['refreshToken']['jwtToken']
        self._save_token(token)

    def _save_token(self, token):
        with open(self._token_path, 'wb') as f:
            f.write(token.encode('ascii'))
        self._token = None

    @property
    def _token_path(self):
        return expanduser('~/.beatmon-agent.jwt')


AUTHENTICATE = gql('''
mutation Authenticate($email:String!, $password:String!) {
  authenticate(input:{
    email:$email,
    password:$password,
  }) {
    jwtToken
  }
}
''')

HEARTBEAT = gql('''
mutation newHeartbeatLog($heartbeatId:UUID!) {
  createHeartbeatLog(input:{
    heartbeatLog:{
      heartbeatId: $heartbeatId,
    }
  }) {
    heartbeatLog {
      heartbeatId,
      date
    }
  }
}
''')

REFRESH_TOKEN = gql('''
mutation refreshToken {
  refreshToken(input:{}) {
    jwtToken
  }
}
''')

ALL_HEARTBEATS = gql('''
{
  allHeartbeats {
    nodes {
      nodeId
      heartbeatId
      lastSeen
      name
    }
  }
}
''')

HEARTBEATS_BY_ID = gql('''
query heartbeat($uuid:UUID!) {
  allHeartbeats(condition:{heartbeatId:$uuid}) {
    nodes {
      nodeId
      heartbeatId
      name
      notifyAfterSeconds
    }
  }
}
''')

CREATE_HEARTBEAT = gql('''
mutation createHeartbeat($name:String){
  createHeartbeat(input:{
    heartbeat:{
      name:$name,
    }
  }) {
    heartbeat{
      heartbeatId
      name
      notifyAfterSeconds
    }
  }
}
''')

UPDATE_HEARTBEAT = gql('''
mutation updateHeartbeat($nodeId:ID!, $name:String, $notifyAfterSeconds:Int){
  updateHeartbeat(input:{
    nodeId:$nodeId,
    heartbeatPatch:{
      name:$name,
      notifyAfterSeconds:$notifyAfterSeconds,
    }
  }) {
    heartbeat{
      heartbeatId
      name
      notifyAfterSeconds
    }
  }
}
''')


def main():
    import sys
    Agent().main(sys.argv)
