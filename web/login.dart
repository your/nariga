import 'dart:html';
import 'dart:convert';
import 'package:bootjack/bootjack.dart';
import 'session_manager.dart';

void main() {

  var s = querySelector('form#naraForm');
  s.onSubmit.listen((Event e) {
    e.preventDefault();

    String w = querySelector('#w').getAttribute('value');
    InputElement u = querySelector('#u');
    InputElement p = querySelector('#p');

    var what = Uri.encodeQueryComponent(w);
    var user = Uri.encodeQueryComponent(u.value);
    var pass = Uri.encodeQueryComponent(p.value);

    HttpRequest.request('http://107.150.3.151:8070/?w=$what&u=$user&p=$pass').then((HttpRequest resp) {
      String session_id = resp.responseText.toString();
      print(resp.responseText.toString());
      if (session_id == "-1") {
        print("Username/password mismatch");
      } else {
        createCookie('session', session_id, 1);
        print("Cookie set: " + readCookie('session'));
      }
    });
  });

}
