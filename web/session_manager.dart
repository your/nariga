import 'dart:html';
import 'dart:core';
/* 
 * dart document.cookie lib
 *
 * ported from
 * http://www.quirksmode.org/js/cookies.html
 *
 */

void createCookie(String name, String value, int days) {
  String expires;
  DateTime now = new DateTime.now();
  if (days != null)  {
    DateTime date = now.add(new Duration(days: days));
    expires = '; expires=' + date.toString();    
  } else {
    DateTime then = now.add(new Duration(seconds: 0)); // expire now
    expires = '; expires=' + then.toString();
  }
  document.cookie = name + '=' + value + expires + '; path=/';
}

String readCookie(String name) {
  String nameEQ = name + '=';
  List<String> ca = document.cookie.split(';');
  for (int i = 0; i < ca.length; i++) {
    String c = ca[i];
    c = c.trim();
    if (c.indexOf(nameEQ) == 0) {
      return c.substring(nameEQ.length);
    }
  }
  return null;  
}

void eraseCookie(String name) {
  createCookie(name, '', null);
}
