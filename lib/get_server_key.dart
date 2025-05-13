
import 'package:googleapis_auth/auth_io.dart';

class get_server_key {
  Future<String> server_token() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];
    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "saaolhrmapp-cf6b9",
          "private_key_id": "b0e4fe24b9cd9f06cfa9f608c243552f160fd6f9",
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDb+fSflJBLRhjO\n1iy6p06IKeWLRIRDHbJOR/7y1a0i9vPU18kLzPzUdyLIxpP0rW5oPIhjPXnCXjvu\n5P3na/b+FtabT013HoKUdOXBTbQnvU52yzpbnk3KWEkisZ2BfpYC26DMsNFoJwQF\nLCedTl8rZHaSvR63jFe72MuiDIo+YUhH3HDPRr/n6gvlx8ESVhnknNN/TwAqMggo\n+3lXVlKBDjYLyLKqrSGazDn6YQzpygxoxqeC1rt6Wj8bTVcqzIPaPfY2cDIAIOQ1\nnrqPmvALNl4YspJB1XqAOdh5z+tMHhxB6nTGuGOqEpznmJSZV9qK8p8icHnJVJ/d\nEpRWWFSfAgMBAAECggEAHxYgPUsD5zdVOymmMYyCOxjcoQVCQa/ZKlnfTBbpPEc0\n5w/FkB7cXfQmHMR/VTULJLzlM00VP2QMyTJgNUubIIY+tr0Kv/o2Tt+ENoCSJImK\npJwMt7TT3nQChd4e2ZV3gpjiDPsx5Kua1FZMlNzl8x5j6VHDnQG+xkOZZ2GpSa43\ngz6E6OmtLLSOLTWdGU37K3Aclw2JPmKSm5YAc2xUfZjTG7KH2m/f1aZCau/HqkPr\nEo6qJ+5aHlIku4Z5r2BoqucDNDgrOYzDgvenpuT+HLJclJuo+iTJJGLn7j3Q/3ET\nMhe+jtWwMFWqgXp2VXZB5sG82NMSE2drIM3eod+ZlQKBgQD/2dZ6WPSLwH8yMpU6\nO0XHQryWozjkqYrAci7ZzcrqQiRDF4n0MZRhzDJ5gTYZBQhJm1QwEM8dbXpMrM4k\nuNthBt8aCGS6Qdu3r0GgYYtxSFVEgastoxWwprTeqegJ9CboTsQlmIJZk0wWndR7\ndNncO20wC4+y+ZtSLIlWbo6RrQKBgQDcGsRL6syY1zk8zPN35vgYi92cbMyIKahR\nHx1VtZxhoK+wdllR235S1JwnoBFFaBQUzRhWEN7Nug3fHpgKcDm/oE/jrZXXeQ6C\n8+3iV9Yckva8RhMcUNzNz7urUg/XzNvVkFx7axIJNC0QfZ862my8NL8sfGSdVhor\n62mC572A+wKBgG2bORL5AOrN8K/kk6F6uw3+PSSbkEgFifef8wpD62YoJ7jGYMdI\nZjTvccAz5qUZTs+Zx5s/2DrXJ8mpTjbVKsaKVxGj/uL8S9CJOCgpIb/KKR1MH7VR\nZH1lLZ8mUs3Q1so21Dj2+QC+5Z3ax6iMCrkajFBE467c1/mAMuXgPxuRAoGAKF5w\nakwiQlYXFWOxs+gU0Mu2VZ5O1Rpu2JIQW0v35qAGGSNbtnu/a4m7KjldcZFpPXdw\nYzis5KafLLD7yc5TiSXqASQxO1fkpXf/xWe+yXba8iUYFDVwif7zuLRQW5AjMcRM\ncgZtRGrhaQjhT3YIQ2yZM5uNCJ5mJnAC5hOC2kkCgYA79mQY8LKWTPOvFEe4xyZ/\nRIc6/jpkfRXmWphHELunOOQoqIa8Bsyr9mvaFWnUqIq363icj/Zq+U399UOR3aAi\n70VqVmf2gnG2y9hNyh8nRZAC3t2aTvE2LRXPaxGGaw6QA0uuBvXhH/uayl0OeySk\nwAZIDJBlBOB5FSQIgFon/g==\n-----END PRIVATE KEY-----\n",
          "client_email": "firebase-adminsdk-fbsvc@saaolhrmapp-cf6b9.iam.gserviceaccount.com",
          "client_id": "110012091027792641175",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40saaolhrmapp-cf6b9.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        scopes);
    final accessserverkey = client.credentials.accessToken.data;
    return accessserverkey;
  }
}
