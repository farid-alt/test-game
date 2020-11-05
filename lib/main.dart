import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}
//awdaw

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Welcome(
        0,
      ),
    );
  }
}

class Welcome extends StatefulWidget {
  final int score;
  Welcome(this.score);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaisedButton(
                  child: Text('Start'),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MyHomePage()));
                  }),
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Text(
                    'Score',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    widget.score.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  ValueChanged<double> valueChanged;
  List balls = List();
  int score = 0;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AudioPlayer audioPlayer = AudioPlayer();
  static AudioCache cache = AudioCache();
  bool end = false;
  int flag = 0;
  int speed = 0;
  int lives = 3;
  ValueNotifier<double> valueListener = ValueNotifier(.0);
  random(min, max) {
    var rn = new Random();
    return min + rn.nextInt(max - min);
  }

  getAudio() async {
    audioPlayer = await cache.play('backMusic.mp3');
  }

  @override
  void initState() {
    getAudio();
    valueListener.addListener(notifyParent);
    Timer.periodic(Duration(milliseconds: 1000), ((val) {
      Map boll = {
        'x': random(30, MediaQuery.of(context).size.width.toInt() - 30),
        'y': 30.0,
        'type': random(1, 10)
      };
      setState(() {
        widget.balls.add(boll);
        speed = widget.score ~/ 100;
      });

      if (end) {
        val.cancel();
      }
    }));
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      for (var i in widget.balls)
        if (i['y'] >= MediaQuery.of(context).size.height - 50) {
          //   timer.cancel();

          if (num.parse((i['x'] / MediaQuery.of(context).size.width)
                      .toStringAsFixed(1)) ==
                  num.parse(valueListener.value.toStringAsFixed(1)) ||
              num.parse(((i['x'] / MediaQuery.of(context).size.width) + 0.1)
                      .toStringAsFixed(1)) ==
                  num.parse(valueListener.value.toStringAsFixed(1)) ||
              num.parse(((i['x'] / MediaQuery.of(context).size.width) - 0.1)
                      .toStringAsFixed(1)) ==
                  num.parse(valueListener.value.toStringAsFixed(1))) {
            if (i['type'] == 9) {
              setState(() {
                lives--;
              });
              if (lives == 0) {
                end = true;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Welcome(widget.score)));
              }
            } else {
              print(" VALUE ${valueListener.value}");
              setState(() {
                if (i['type'] == 5) {
                  widget.score += 50;
                  lives++;
                } else {
                  widget.score += 10;
                }
              });
            }
          } else {
            if (i['type'] != 9 && i['type'] != 5) {
              setState(() {
                lives--;
              });
              if (lives == 0) {
                end = true;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Welcome(widget.score)));
              }
            }
          }
          print(i['x'] / MediaQuery.of(context).size.width);

          widget.balls.remove(i);
        } else {
          setState(() {
            i['y'] = i['y'] + 5 + speed * 2;
          });
        }
      if (end) {
        timer.cancel();
      }
    });

    super.initState();
  }

  void notifyParent() {
    if (widget.valueChanged != null) {
      widget.valueChanged(valueListener.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/back.jpg'), fit: BoxFit.cover)),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Score: ${widget.score}',
                    style: TextStyle(color: Colors.yellow, fontSize: 25),
                  ),
                  Text(
                    'Speed: $speed',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  Text(
                    'Lives: $lives',
                    style: TextStyle(color: Colors.green, fontSize: 25),
                  )
                ],
              ),
            ),
            for (var i in widget.balls)
              Positioned(
                left: i['x'].toDouble(),
                top: i['y'].toDouble(),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: i['type'] == 9
                              ? Colors.red.withOpacity(0.5)
                              : i['type'] == 5
                                  ? Colors.green.withOpacity(0.5)
                                  : Colors.black.withOpacity(0.5),
                          blurRadius: 3)
                    ],
                    color: i['type'] == 9
                        ? Colors.red
                        : i['type'] == 5 ? Colors.green : Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Builder(
                  builder: (context) {
                    final handle = GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        valueListener.value = (valueListener.value +
                                details.delta.dx / context.size.width)
                            .clamp(.0, 1.0);
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20),
                        width: 35,
                        height: 20,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            // borderRadius: BorderRadius.circular(30),
                            image: DecorationImage(
                                image: AssetImage('assets/platform.png'),
                                fit: BoxFit.cover)),
                      ),
                    );

                    return AnimatedBuilder(
                      animation: valueListener,
                      builder: (context, child) {
                        return Align(
                          alignment: Alignment(valueListener.value * 2 - 1, .5),
                          child: child,
                        );
                      },
                      child: handle,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
