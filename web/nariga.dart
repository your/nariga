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
//import 'package:avl_tree/avl_tree.dart';
//import 'package:angular/angular.dart';
//import 'package:ng_infinite_scroll/ng_infinite_scroll.dart';
//import 'package:angular/application_factory.dart';
import 'package:crypto/crypto.dart';
import 'package:bootjack/bootjack.dart';
import 'package:dquery/dquery.dart';
import 'session_manager.dart';

final NodeValidatorBuilder _htmlValidator=new NodeValidatorBuilder.common()
  ..allowElement('a', attributes: ['href', 'data-target', 'data-toggle', 'data-placement', 'data-html'])
  ..allowElement('button', attributes: ['data-target', 'data-toggle'])
  ..allowElement('span', attributes: ['aria-hidden']);

/*
class NarigaModule extends Module {
  NarigaModule() {
    install(new InfiniteScrollModule());
  }
}*/

// how often update countdowns? (no json requests)
const int UPDATE_DELAY = 5000; // 30secs

DivElement deadList;
Map courseMap;
Map narigaMap;
List narigaList;

/*
@Controller(selector: "[nariga]", publishAs: "ctrl")
class TestController {
  var disabled = false;
  void loadMore() {
    //loadData();
  }
}*/

class Nariga {

  String name;
  String assign;
  int deadline;
  String link;
  int id;

  Nariga(this.name, this.assign, this.deadline, this.link, this.id);

}

bool loadingData;
int loadedCourses;

void main() {

  Bootjack.useDefault();
  /*
  Collapse.use();
  Dropdown.use();
  Transition.use();
  */
  
  loadingData = true;
  loadedCourses = 0;
  courseMap = new Map<String, bool>();
  narigaList = new List<Nariga>();
  narigaMap = new Map<int, int>();

  /*
  // init angular module
  var module = new Module();
  module.bind(TestController);
  module.install(new InfiniteScrollModule());

  // ready to go with angular module
  applicationFactory().addModule(module).run();*/

  // load available courses
  loadCourses();

  // stream a periodic task to update timers
  var stream = new Stream.periodic(const Duration(milliseconds: UPDATE_DELAY), (count) {
    // do something every tot
    // return the result of that something
    adjustTimers();
    //print(count);
  });

  var load = new Stream.periodic(const Duration(milliseconds: 100), (count) {
    if (loadingData == false) {
      // it means all courses data have been loaded, hence we can
      // work on narigas (sort, etc) and draw them
      workNarigas();
    }
  });

  load.listen((result) {});

  stream.listen((result) {
    //print('lol');
    // listen for the result of the task
  });

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


var jsonsPath = "/jsons";
var coursesPath = "/courses";
void loadCourses() {
  var url = jsonsPath + coursesPath + "/courses.json";
  var request = HttpRequest.request(url).then(onCoursesLoaded);
}

// parse courses
void onCoursesLoaded(HttpRequest req) {
  print('ho ricevuto corsi');
  List courses = JSON.decode(req.responseText);
  for (var course in courses) {
    Map courseattr = course;
    courseMap.putIfAbsent(courseattr["course"], () => true); // default value 1 = enabled
  }
  // got courses, get related deadlines (all enabled by default)
  courseMap.forEach((String hash, bool enabled) => loadData(hash, enabled));
}

//
// Base64 decoder made by myself.
//
String base64Decode(String hash) {
  // thank you dart developers
  var bytes = CryptoUtils.base64StringToBytes(hash);
  var ud = new Utf8Decoder();
  String decoded = ud.convert(bytes);
  print(decoded);
  return decoded;
}

void loadData(String hash, bool enabled) {
  if (enabled) {
    var coursename = base64Decode(hash);
    var url = jsonsPath + coursesPath + "/" + hash + ".json";
    var request = HttpRequest.request(url).then(onDataLoaded);
  }

}

//
// Callback from loadData()
//
void onDataLoaded(HttpRequest req) {
  print('ho ricevuto json');
  List deadlines = JSON.decode(req.responseText);
  for (var soontodie in deadlines) {
    Map deaddata = soontodie;
    String course = deaddata["course"];
    String assign = deaddata["assign"];
    int deadline = deaddata["deadline"];
    String url = deaddata["url"];
    int id = deaddata["id"];

    // Add nariga object to exst list
    
    var newNariga = new Nariga(course, assign, deadline, url, id);
    narigaList.add(newNariga);

    // lol
    loadedCourses += 1;
    if (loadedCourses == courseMap.length) {
      loadingData = false;
    }

    // workNarigas() call was here, before I added the right above block
  }
}

//
// Got all the deadlines, sort those and work to draw them!
//
void workNarigas() {
  // functional style rocks
  narigaList.sort((x, y) => x.deadline.compareTo(y.deadline));
  DateTime now = new DateTime.now();
  for (var nariga in narigaList) {
    if (now.isBefore(new DateTime.fromMillisecondsSinceEpoch(nariga.deadline * 1000, isUtc: true))) {
      checkDead(nariga.name, nariga.assign, nariga.deadline, nariga.id);
    }
  }
}

//
// Check if nariga in in map (is this still useful?)
//
void checkDead(String course, String assign, int deadline, int id) {

  // add a new deadline only if not present in the map
  if (!alreadyPresent(id)) {
    addDeadList(course, assign, deadline, id);
  } else {
    //print('trovata copia');
  }
  //var lefts = computeRemaining(deadline); // remaining ones
  // functional style ftw:
  // if absent key with id, add it and set value to the one returned by computeRemaining()
  // NOT NEEDED ANYMORE:
  // neightboursMap.putIfAbsent(id, () => lefts);
}


//
// Building a new nariga div
//

/* Skeleton of narigassss....
 *  <div class="nariga">
      <div class="lefts left1w">1w</div>
      <div class="titles">
        <div class="coursename">The Data Scientist’s Toolbox</div>
        <div class="coursetask">Week 1 Quiz (Hard Deadline)</div>
      </div>
    </div>
 */

/*
       <div class="panel panel-default">
        <div class="panel-heading">
            <a data-toggle="collapse" data-parent="#accordion" href="#collapse1">
              <div class="nariga">
                <div class="lefts left1w">1w</div>
                <div class="titles">
                  <div class="coursename">The Data Scientist’s Toolbox</div>
                  <div class="coursetask">Week 1 Quiz (Hard Deadline)</div>
                </div>
              </div>
            </a>
        </div>
        <div id="collapse1" class="panel-collapse collapse">
          <div class="panel-body">
          <span class="label label-danger">Danger</span>
           </div>
        </div>
 */
/* old
 * void addDeadList(String course, String assign, int deadline, int id) {

  // find the dead anchor
  deadList = querySelector('#deadlist');

  // news divs are borning
  var newDivPanel = new DivElement();
  var newDivPanelHeading = new DivElement();
  var newDivPanelA = new Element.a();
  
  var collapse = 'collapse' + id.toString();
  newDivPanel.classes.add('panel panel-default');
  newDivPanelHeading.classes.add('panel-heading');
  newDivPanelA.setAttribute('data-toggle', 'collapse');
  newDivPanelA.setAttribute('data-parent', '#accordion');
  newDivPanelA.setAttribute('href', '#'+collapse);
  
  var newDivCollapse = new DivElement();
  var newDivPanelBody = new DivElement();
  
  newDivCollapse.id = collapse;
  newDivCollapse.classes.add('panel-collapse collapse');
  newDivPanelBody.classes.add('panel-body');
  newDivPanelBody.innerHtml = buildNarigaBody(deadline, id);
  //newDivPanelBody.text = buildNarigaBody(deadline);
  
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
  newDivPanelA.append(newDivNariga);
  newDivPanelHeading.append(newDivPanelA);
  
  newDivCollapse.append(newDivPanelBody);
  newDivPanel.append(newDivPanelHeading);
  newDivPanel.append(newDivCollapse);

  // add it
  deadList.children.add(newDivPanel);

  // fit it
  setPlace(newDivLefts, newDivTitles, deadline, id);
  

}
 */
void addDeadList(String course, String assign, int deadline, int id) {

  // find the dead anchor
  deadList = querySelector('#deadlist');
 
  
  var newDivNariga = new DivElement();
  var newDivLefts = new DivElement();
  var newDivTitles = new DivElement();
  var newDivCoursename = new DivElement();
  var newDivCoursetask = new DivElement();
  
  var newDivTools = new DivElement();
  var newDivToolbutt1 = new DivElement();
  var newDivToolbutt2 = new DivElement();
  var newDivToolbutt3 = new DivElement();

  // attacch classes
  newDivNariga.classes.add('nariga');
  newDivLefts.classes.add('lefts');
  newDivTitles.classes.add('titles');
  newDivCoursename.classes.add('coursename');
  newDivCoursetask.classes.add('coursetask');
  
  newDivTools.classes.add('tools');
  newDivToolbutt1.classes.add('toolbutt');
  newDivToolbutt2.classes.add('toolbutt');
  newDivToolbutt3.classes.add('toolbutt');
  newDivToolbutt1.id = 'buttone' + id.toString();
  newDivToolbutt2.id = 'butttwo' + id.toString();
  newDivToolbutt3.id = 'buttthree' + id.toString();

  // fill shit
  newDivNariga.id = id.toString();
  newDivCoursename.text = course;
  newDivCoursetask.text = assign;
  newDivLefts.text = deadline.toString(); // poi penso a fare i calcoli, mo printa u dat grezz
  
  newDivTools.append(newDivToolbutt1);
  newDivTools.append(newDivToolbutt2);
  newDivTools.append(newDivToolbutt3);

  // putting pieces togheter
  
  
  newDivTitles.append(newDivCoursename);
  newDivTitles.append(newDivCoursetask);
  newDivNariga.append(newDivLefts); // choose deads carefully then
  
  newDivNariga.append(newDivTools);
  
  newDivNariga.append(newDivTitles);
  

  // add it
  deadList.children.add(newDivNariga);

  // fit it
  setPlace(newDivLefts, newDivTitles, deadline, id);
  setButts(id);
  

}

void setButts(id) {
  
  var buttone = '#buttone' + id.toString();
  var butttwo = '#butttwo' + id.toString();
  var buttthree = '#buttthree' + id.toString();
  
  var b1 = document.querySelector(buttone);
  b1.setInnerHtml('''
    <a href="javascript:void(0)" data-toggle="tooltip" data-placement="top"    title="Work it now!"   >
    <span class="glyphicon glyphicon-fire" aria-hidden="true"></span>
    </a>''', validator: _htmlValidator);
  
  int progress = 0;
  
  $(buttone).on('click', (QueryEvent e) {
    
    
    var titles = ['Work it now!',
                  '<b>You are working on this deadline...</b> <br> (Click here again AFTER you\'ll have submitted it!)',
                  '<b>Completed!</b> <br> (Click again to RESET the status flag)'];
    
    var glyphs = ['glyphicon-fire',
                  'glyphicon-fire red',
                  'glyphicon-ok green'];
    
    progress++;
    progress = progress > 2? 0 : progress;
    print(progress);
    
    b1.setInnerHtml('''
    <a href="javascript:void(0)" data-toggle="tooltip" data-placement="top"
      title="${titles[progress]}"
      data-html="true">
    <span class="glyphicon ${glyphs[progress]}" aria-hidden="true"></span>
    </a>''', validator: _htmlValidator);
    
   //Tooltip.wire($(buttone).children('[data-toggle]').firstIfAny); 
    $('[data-toggle]').forEach((Element elem) => Tooltip.wire(elem));
  });
  
  document.querySelector(butttwo).setInnerHtml('''
    <a href="#" data-toggle="tooltip" data-placement="top"    title="Set alarm"   >
    <span class="glyphicon glyphicon-bell" aria-hidden="true"></span>
    </a>''', validator: _htmlValidator);
  
  document.querySelector(buttthree).setInnerHtml('''
    <a href="#" data-toggle="tooltip" data-placement="top"    title="Remove deadline"   >
    <span class="glyphicon glyphicon-remove" aria-hidden="true"></span>
    </a>''', validator: _htmlValidator);
  
  $('[data-toggle]').forEach((Element elem) => Tooltip.wire(elem));
}
//
// Look for nariga and adjust it!
//
void adjustNariga(int id, int deadline) {
  var narigas = document.querySelectorAll('.nariga');
  for (var nariga in narigas) {
    if (int.parse(nariga.id) == id) {
      var n = nariga.querySelector('.lefts');
      var t = nariga.querySelector('.titles');
      setPlace(n, t, deadline, id);
      break;
    }
  }
}

//
// Updater
//
void adjustTimers() {
  // update timers only if newest data has been loaded or there are no pending adjust
  print('aggiorno');
  narigaMap.forEach((id, deadline) => adjustNariga(id, deadline));
}

//
// Find a representation like: 1w 2d 14h 5m
// (no intln for now)
//
const SECS_1M = 60;
const SECS_1H = 3600;
const SECS_6H = SECS_1H * 6;
const SECS_1D = SECS_1H * 24;
const SECS_3D = SECS_1D * 3;
const SECS_1W = SECS_1D * 7;
const SECS_2W = SECS_1W * 2;

String computeString(int leftsecs) {

  var sb = new StringBuffer();

  if (leftsecs > 0) {

    int weeks = leftsecs ~/ SECS_1W;
    int days = (leftsecs % SECS_1W) ~/ SECS_1D;
    int hours = (leftsecs % SECS_1D) ~/ SECS_1H;
    int mins = (leftsecs % SECS_1H) ~/ SECS_1M;

    (weeks > 0) ? sb.write(weeks.toString() + "W ") : null;
    (days > 0) ? sb.write(days.toString() + "D ") : null;
    (hours > 0) ? sb.write(hours.toString() + "H ") : null;
    (mins > 0) ? sb.write(mins.toString() + "M") : null;
    (leftsecs < 60) ? sb.write(leftsecs.toString() + "S") : null;

  } else {
    sb.write("EXP"); // what to do then?
  }

  return sb.toString();

}

// Update css style to narigas
void updateDead(dead, title, int leftsecs, int id) {
  
  int browserWidth = window.innerWidth;
  int deadWidth = computeWidth(leftsecs, browserWidth);
  int titleMaxWidth = browserWidth-deadWidth-100;

  dead.text = computeString(leftsecs);
  dead.style
      ..width = '${deadWidth.toString()}px'
      ..background = '#${computeBackground(leftsecs)}';
  
  if (leftsecs < 129600) {
  var ct = title.querySelector('.coursetask');
  ct.style
      ..color = 'rgba(191, 47, 47, 0.87)';
  }
      
// IMPORTATNE: RIABILITA STE DUE LINEE DI QUA SOTTO SE VUOI LA SIZE DEI TITOLI
      //FIXATA ADATTIVA NELLA PAGINA
  title.style
      ..maxWidth = '${titleMaxWidth.toString()}px';

}

bool alreadyPresent(int id) {
  return narigaMap.containsKey(id);
}

// IS this still useful?
void setPlace(dead, title, int deadsecs, int id) {
  // hey, we have a new nariga, add to map:
  narigaMap.addAll({
    id: deadsecs
  }); // is this useful?
  updateDead(dead, title, computeRemaining(deadsecs), id);
}

//
// Find remaining time starting given deadline secs frome epoch
//
int computeRemaining(int deadsecs) {
  DateTime now = new DateTime.now();
  DateTime then = new DateTime.fromMillisecondsSinceEpoch(deadsecs * 1000, isUtc: true);
  Duration diff = then.difference(now);
  var leftsecs = diff.inSeconds;
//  print(now.toLocal());
//  print(then.toLocal()); // TO LOCAL!
  //(leftsecs > 0) ? print('left:' + leftsecs.toString()) : null;
  return leftsecs;
}

String buildNarigaBody(int deadline, int id) {
  var a = '<span class="label label-default">Due to: ' + getDueDate(deadline) + '</span>&nbsp;';
  var b = '<a href=#><span class="label label-primary">Work it now!</span></a>&nbsp;';
  var c = '''
      Alarm: <div class="btn-group btn-toggle" data-toggle="buttons-checkbox">
        <button class="btn btn-xs btn-primary active">6H</button>
        <button class="btn btn-xs btn-default">12H</button>
        <button class="btn btn-xs btn-default">1D</button>
        <button class="btn btn-xs btn-default">2D</button>
      </div>
'''; // check it out here http://www.bootply.com/92189
  // prob dovrai spostare sta roba e costrutrila poco per volta e settare l'onlckik event
  return a+b+c;
}
String getDueDate(int deadline) {
  DateTime then = new DateTime.fromMillisecondsSinceEpoch(deadline * 1000, isUtc: true);
  return then.toLocal().toString();
}

//
// Choose background according to left time
// Current: http://www.colourlovers.com/palette/138026/a_beautiful_day
//
const BG_1H = '000';
const BG_6H = 'F23C1F';//'FF4E50';//'FF003D';
const BG_1D = 'F26F1D';//'FC913A';//'FC930A';
const BG_3D = 'F2A41D';//'F9D423';//'F7C41F';
const BG_1W = 'F2D91D';//'EDE574';//E0E05A';
const BG_XN = 'E3E3E3';//'E1F5C4';//CCF390';

String computeBackground(int leftsecs) {

  var bg = "FFF"; // default

  if (leftsecs > 0) {
    (leftsecs <= SECS_1H) ? bg = BG_1H : null;
    (leftsecs > SECS_1H && leftsecs <= SECS_6H) ? bg = BG_6H : null;
    (leftsecs > SECS_6H && leftsecs <= SECS_1D) ? bg = BG_1D : null;
    (leftsecs > SECS_1D && leftsecs <= SECS_3D) ? bg = BG_3D : null;
    (leftsecs > SECS_3D && leftsecs <= SECS_1W) ? bg = BG_1W : null;
    (leftsecs > SECS_1W) ? bg = BG_XN : null;
  }

  return bg;
}

//
// How many secs to represent in one pixel?
// (anyway I switch to percentages then)
//
const RAPPR_STEP_1H = 60; // <1h : 1px = ?min orig:60 - 1min
const RAPPR_STEP_6H = 300; // <6h : 1px = ?min orig:300
const RAPPR_STEP_1D = 600; // <1d : 1px = 15min
const RAPPR_STEP_3D = 900; // <3d : 1px = 20min
const RAPPR_STEP_1W = 3600; // <1w : 1px = 25min
const RAPPR_STEP_2W = 7200; // <1w : 1px = 25min
const RAPPR_STEP_XN = 14400; // >1w : 1px = 30min

const PIX_1H = SECS_1H ~/ RAPPR_STEP_1H; // 60
const PIX_6H = SECS_6H ~/ RAPPR_STEP_6H; // 72
const PIX_1D = SECS_1D ~/ RAPPR_STEP_1D; // 96
const PIX_3D = SECS_3D ~/ RAPPR_STEP_3D; // 403
const PIX_1W = SECS_1W ~/ RAPPR_STEP_1W; // 465
const PIX_2W = SECS_2W ~/ RAPPR_STEP_2W; // 465


int computeWidth(int leftsecs, int browserWidth) {

  var newwidth = 30; // default

  // ok, I got crazy doing these calculations but it was fun.
  // guessing what I am doing here?
  if (leftsecs > 0) {
    
    if (leftsecs <= SECS_1H) {
      int range = leftsecs;
      newwidth = range ~/ RAPPR_STEP_1H;
    }

    if (leftsecs > SECS_1H && leftsecs <= SECS_6H) {
      int range1 = leftsecs - SECS_1H;
      int width1 = range1 ~/ RAPPR_STEP_6H;
      int range0 = SECS_1H;
      int width0 = SECS_1H ~/ RAPPR_STEP_1H;
      newwidth = width0 + width1;
    }
    
    if (leftsecs > SECS_6H && leftsecs <= SECS_1D) {
      int range2 = leftsecs - SECS_6H;
      int width2 = range2 ~/ RAPPR_STEP_1D;
      int range1 = SECS_6H - SECS_1H;
      int width1 = range1 ~/ RAPPR_STEP_6H;
      int range0 = SECS_1H;
      int width0 = range0 ~/ RAPPR_STEP_1H;
      newwidth = width0 + width1 + width2;
    }

    if (leftsecs > SECS_1D && leftsecs <= SECS_3D) {
      int range3 = leftsecs - SECS_1D;
      int width3 = range3 ~/ RAPPR_STEP_3D;
      int range2 = SECS_1D - SECS_6H;
      int width2 = range2 ~/ RAPPR_STEP_1D;
      int range1 = SECS_6H - SECS_1H;
      int width1 = range1 ~/ RAPPR_STEP_6H;
      int range0 = SECS_1H;
      int width0 = range0 ~/ RAPPR_STEP_1H;
      newwidth = width0 + width1 + width2 + width3;
    }

    if (leftsecs > SECS_3D && leftsecs <= SECS_1W) {
      int range4 = leftsecs - SECS_3D;
      int width4 = range4 ~/ RAPPR_STEP_1W;
      int range3 = SECS_3D - SECS_1D;
      int width3 = range3 ~/ RAPPR_STEP_3D;
      int range2 = SECS_1D - SECS_6H;
      int width2 = range2 ~/ RAPPR_STEP_1D;
      int range1 = SECS_6H - SECS_1H;
      int width1 = range1 ~/ RAPPR_STEP_6H;
      int range0 = SECS_1H;
      int width0 = range0 ~/ RAPPR_STEP_1H;
      newwidth = width0 + width1 + width2 + width3 + width4;
    }
 
    if (leftsecs > SECS_1W && leftsecs <= SECS_2W) {
      int range5 = leftsecs - SECS_1W;
      int width5 = range5 ~/ RAPPR_STEP_2W;
      int range4 = SECS_1W - SECS_3D;
      int width4 = range4 ~/ RAPPR_STEP_1W;
      int range3 = SECS_3D - SECS_1D;
      int width3 = range3 ~/ RAPPR_STEP_3D;
      int range2 = SECS_1D - SECS_6H;
      int width2 = range2 ~/ RAPPR_STEP_1D;
      int range1 = SECS_6H - SECS_1H;
      int width1 = range1 ~/ RAPPR_STEP_6H;
      int range0 = SECS_1H;
      int width0 = range0 ~/ RAPPR_STEP_1H;
      newwidth = width0 + width1 + width2 + width3 + width4 + width5;
    }
    
    if (leftsecs > SECS_2W) {
      int range6 = leftsecs - SECS_2W;
      int width6 = range6 ~/ RAPPR_STEP_XN;
      int range5 = SECS_2W - SECS_1W;
      int width5 = range5 ~/ RAPPR_STEP_2W;
      int range4 = SECS_1W - SECS_3D;
      int width4 = range4 ~/ RAPPR_STEP_1W;
      int range3 = SECS_3D - SECS_1D;
      int width3 = range3 ~/ RAPPR_STEP_3D;
      int range2 = SECS_1D - SECS_6H;
      int width2 = range2 ~/ RAPPR_STEP_1D;
      int range1 = SECS_6H - SECS_1H;
      int width1 = range1 ~/ RAPPR_STEP_6H;
      int range0 = SECS_1H;
      int width0 = range0 ~/ RAPPR_STEP_1H;
      newwidth = width0 + width1 + width2 + width3 + width4 + width5 + width6;
    }

  }
  //print((leftsecs - SECS_1H - SECS_6H - SECS_1D - SECS_3D - SECS_1W) ~/ RAPPR_STEP_XN);

  //newwidth = newwidth * 100 ~/ 800; // adapt to my choosen proportions
  
  newwidth = newwidth * browserWidth ~/ 1280 ; // I choose the proportions on 1280
  
  if (newwidth <= 150) {newwidth = 150;} // dont collapse any furthur.. but check this later joe

  print(newwidth);
  
  return newwidth;
}


/////////////////////////////////////////////////////////////////////////////////////////////
/* NOT NEEDED ANYMORE
DateTime convertDeadline(int deadline) {
  //IN: (int) seconds since epoch
  //OUT: (DatTime) 2012-02-27 13:27:00 (local time) NO UTC PLS!!!!!!:@@@@
  DateTime deadlineUTC =
      new DateTime.fromMillisecondsSinceEpoch(deadline*1000, isUtc:true);
  var deadlineLocal = deadlineUTC.toLocal();
  return deadlineLocal; // LOCAL TIME (browser)
}*/

//void lunchFutureTimer() {
//    var future = new Future.delayed(const Duration(milliseconds: UPDATE_DELAY), adjustTimers);
//}

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
