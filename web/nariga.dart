/** DA FARE:
 * 1. sistemare lo script in ruby di modo che prenda 
 *    in input un calendario da un url remoto e produca un json
 *    cn la struttura ke abbiamo visto
 * 2. un miliardo di cose
 * 3. segnati le cose per la libreria moddata in ruby ical e fai un fork su github
 */

import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'dart:core';
import 'package:avl_tree/avl_tree.dart';
import 'package:angular/angular.dart';
import 'package:ng_infinite_scroll/ng_infinite_scroll.dart';
import 'package:angular/application_factory.dart';

class NarigaModule extends Module {
  NarigaModule() {
    install(new InfiniteScrollModule());
  }
}

// how often update countdowns? (no json requests)
const int UPDATE_DELAY = 5000; // 5secs

DivElement deadList;
Map narigaMap;

@Controller(selector: "[nariga]", publishAs: "ctrl")
class TestController {
  var disabled = false;
  void loadMore() {
    loadData();
  }
}

void main() {
  
  narigaMap = new Map<int, int>();

  // init Angular module
  var module = new Module();
  module.bind(TestController);
  module.install(new InfiniteScrollModule());

  // ready to go
  applicationFactory().addModule(module).run();
  
  // first load
  loadData();
  
  // key: id nariga
  // valore: secs rimasti
//  neightboursMap = new Map<int, int>();
//  var tree = new AvlTree<List>();
//  tree.addAll([[0,1],[21,12]]);
//  print(tree.inorder.toList());  // -> [0,1,2]
//  tree.remove(3);
//  print(tree.inorder.toList());  // -> [0,1]
//  tree.add(90);
//  print(tree.inorder.toList());
//  print(tree.contains(0));       // true
  /*Map<String, int> scores = {'Bob': 36};
  for (var key in ['Bob', 'Rohan', 'Sophena']) {
    scores.putIfAbsent(key, () => key.length);
  }
  scores['Bob'];      // 36
  scores['Rohan'];    //  5
  scores['Sophena'];  //  7*/
  
}

// call the web server asynchronously
void loadData() {
  var url = "/data.json";
  var request = HttpRequest.request(url).then(onDataLoaded);
}

// parse json
void onDataLoaded(HttpRequest req) {
  List deadlines = JSON.decode(req.responseText);
  for (var soontodie in deadlines) {
    Map deaddata = soontodie;
    var course = deaddata["course"];
    var assign = deaddata["assign"];
    var deadline = deaddata["deadline"];
    var id = deaddata["id"];
    checkDead(course, assign, deadline, id);
    //addDeadList(course, assign, deadline, id);
  }
  scheduleAdjust();
}

void checkDead(course, assign, deadline, id) {

  if (!alreadyPresent(id)) {
    addDeadList(course, assign, deadline, id);
  } else {
    //print('trovata copia');
  }
  /*var lefts = computeRemaining(deadline); // remaining ones

  // functional style ftw:
  // if absent key with id, add it and set value to the one returned by computeRemaining()
  //neightboursMap.putIfAbsent(id, () => lefts);

  // time to setPlace to it
  // find the dead with a deadline value smaller then this
  for (var dead in deadList) {
    // dead.id
  }*/

  //var narigas = document.querySelectorAll('.nariga');
}

void sortMapByValue(map, val) {

}
/* Skeleton of narigassss....
 *  <div class="nariga">
      <div class="lefts left1w">1w</div>
      <div class="titles">
        <div class="coursename">The Data Scientist’s Toolbox</div>
        <div class="coursetask">Week 1 Quiz (Hard Deadline)</div>
      </div>
    </div>
 */

// building a new nariga!
void addDeadList(String course, String assign, int deadline, int id) {

  // find the dead anchor
  deadList = querySelector('#deadlist');

  // news divs are borning
  var newDivNariga = new DivElement();
  var newDivLefts = new DivElement();
  var newDivTitles = new DivElement();
  var newDivCoursename = new DivElement();
  var newDivCoursetask = new DivElement();

  // attacch classes
  newDivNariga.classes.add('nariga');
  newDivLefts.classes.add('lefts');
  newDivTitles.classes.add('titles');
  newDivCoursename.classes.add('coursename');
  newDivCoursetask.classes.add('coursetask');

  // fill shit
  newDivNariga.id = id.toString();
  newDivCoursename.text = course;
  newDivCoursetask.text = assign;
  newDivLefts.text = deadline.toString(); // poi penso a fare i calcoli, mo printa u dat grezz
  // putting pieces togheter
  newDivTitles.append(newDivCoursename);
  newDivTitles.append(newDivCoursetask);
  newDivNariga.append(newDivLefts); // choose deads carefully then
  newDivNariga.append(newDivTitles);

  // add it
  deadList.children.add(newDivNariga);

  // fit it
  setPlace(newDivLefts, deadline, int.parse(newDivNariga.id));

}

void scheduleAdjust() {
  var future = new Future.delayed(const Duration(milliseconds: UPDATE_DELAY), adjustTimers);
}

void adjustNariga(id, deadline) {
  print(deadline.toString());
  var narigaList = document.querySelectorAll('.nariga');
  for (var nariga in narigaList) {
    if (int.parse(nariga.id) == id) {
      var n = nariga.querySelector('.lefts');
      setPlace(n, deadline, id);
      break; // che cosa rozza lo so
    }
  }
}
void adjustTimers() {
  // print('aggiorno'); LOOP MORTALE AGGIISTA
  narigaMap.forEach((id, deadline) => adjustNariga(id, deadline));
  scheduleAdjust();
}

int cal(ranks) {
  double multiplier = .5;
  return (multiplier * ranks).toInt();
}

/*
 * <1h : 1px = 1min
 * <6h : 1px = 5min
 * <1d : 1px = 15min
 * <3d : 1px = 30min
 * <1w : 1px = 60min
 * >1w : 1px = 120min
 */

// how many secs in one pixel
const RAPPR_STEP_1H = 60;
const RAPPR_STEP_6H = 300;
const RAPPR_STEP_1D = 900;
const RAPPR_STEP_3D = 1800;
const RAPPR_STEP_1W = 3600;
const RAPPR_STEP_XN = 7200;

// lol
const SECS_1M = 60;
const SECS_1H = 3600;
const SECS_6H = SECS_1H * 6;
const SECS_1D = SECS_1H * 24;
const SECS_3D = SECS_1D * 3;
const SECS_1W = SECS_1D * 7;


String computeString(leftsecs) {
  var sb = new StringBuffer(); // no intln for now

  if (leftsecs > 0) {

    int weeks = leftsecs ~/ SECS_1W;
    int days = (leftsecs % SECS_1W) ~/ SECS_1D;
    int hours = (leftsecs % SECS_1D) ~/ SECS_1H;
    int mins = (leftsecs % SECS_1H) ~/ SECS_1M;

    (weeks > 0) ? sb.write(weeks.toString() + "w ") : null;
    (days > 0) ? sb.write(days.toString() + "d ") : null;
    (hours > 0) ? sb.write(hours.toString() + "h ") : null;
    (mins > 0) ? sb.write(mins.toString() + "m") : null;

  } else {
    sb.write("EXPIRED");
  }
  print(sb.toString());
  return sb.toString();
}
void updateDead(dead, leftsecs, id) {

  dead.text = computeString(leftsecs);
  dead.style..width = '${computeWidth(leftsecs).toString()}px'; // default for now
  
}

bool alreadyPresent(id) {
  return narigaMap.containsKey(id);
}

void setPlace(dead, deadsecs, id) {
  print(dead);
  print(deadsecs);
  print(id);
  // hey, we have a new nariga, add to map:
  narigaMap.addAll({id : deadsecs});
  print(narigaMap.length);
  updateDead(dead, computeRemaining(deadsecs), id);
}

int computeRemaining(deadsecs) {
  DateTime now = new DateTime.now();
  DateTime then = new DateTime.fromMillisecondsSinceEpoch(deadsecs * 1000, isUtc: true);
  Duration diff = then.difference(now);
  var leftsecs = diff.inSeconds;
//  print(now.toLocal());
//  print(then.toLocal()); // TO LOCAL!
  print('left:'+ leftsecs.toString());
  return leftsecs;
}
/* NOT NEEDED ANYMORE
DateTime convertDeadline(int deadline) {
  //IN: (int) seconds since epoch
  //OUT: (DatTime) 2012-02-27 13:27:00 (local time) NO UTC PLS!!!!!!:@@@@
  DateTime deadlineUTC =
      new DateTime.fromMillisecondsSinceEpoch(deadline*1000, isUtc:true);
  var deadlineLocal = deadlineUTC.toLocal();
  return deadlineLocal; // LOCAL TIME (browser)
}*/
int computeWidth(int leftsecs) {

  //var deadtimes = document.querySelectorAll('.nariga .lefts');
  //for (var dead in deadtimes) {
  // int leftsecs = double.parse(dead.text).toInt(); // there should be no loss, json already has rounded values

  var newwidth = 30;

  if (leftsecs > 0) {
    (leftsecs <= SECS_1H) ? newwidth = leftsecs ~/ RAPPR_STEP_1H : null;
    (leftsecs > SECS_1H && leftsecs <= SECS_6H) ? newwidth = leftsecs ~/ RAPPR_STEP_6H : null;
    (leftsecs > SECS_6H && leftsecs <= SECS_1D) ? newwidth = leftsecs ~/ RAPPR_STEP_1D : null;
    (leftsecs > SECS_1D && leftsecs <= SECS_3D) ? newwidth = leftsecs ~/ RAPPR_STEP_3D : null;
    (leftsecs > SECS_3D && leftsecs <= SECS_1W) ? newwidth = leftsecs ~/ RAPPR_STEP_1W : null;
    (leftsecs > SECS_1W) ? newwidth = leftsecs ~/ RAPPR_STEP_XN : null;
  }

  print(newwidth);

  return 10+newwidth;
}

/*
.left1m
.left5m
.left1h
.left6h
.left1d
.left3d
.left5d
.left1w 
.left3w
 */

//

/*void main() {
  querySelector("#sample_text_id")
      ..text = "Click me!"
      ..onClick.listen(reverseText);
}

void reverseText(MouseEvent event) {
  var text = querySelector("#sample_text_id").text;
  var buffer = new StringBuffer();
  for (int i = text.length - 1; i >= 0; i--) {
    buffer.write(text[i]);
  }
  querySelector("#sample_text_id").text = buffer.toString();
}*/
