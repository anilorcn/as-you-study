import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool isModeStudy = true;
  bool isStarted = false;
  int timeLeft = 15;
  IconData modIcon = Icons.mode_edit_outlined;
  IconData startStopIcon = Icons.play_arrow_outlined;
  late Timer _timer;

  double timePassedDouble = 0;
  double timeEarnedDouble = 0;

  int timePassedInt = 0;
  int timeEarnedInt = 0;
  int timeSpendable = 0;
  int timeSpent = 0;

  String data1 = "00:00:00";
  String data2 = "00:00:00";
  String data3 = "00:00:00";
  String data4 = "00:00:00";

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  late DateTime pausedTime;
  late DateTime resumedTime;
  late Duration duration;
  double calculatedTimeToSeconds = 0;

  void _startStopButtonFunc() {
    if (isStarted == false) {
      _countdownFunc();
      isStarted = true;
      setState(() {
        startStopIcon = Icons.pause_outlined;
      });
    } else {
      _countdownFunc();
      isStarted = false;
      setState(() {
        startStopIcon = Icons.play_arrow_outlined;
      });
      saveData();
    }
  }

  void _stopButtonFunc() {
    if (isStarted == true) {
      _countdownFunc();
      isStarted = false;
      saveData();
    }
  }

  void sumPrintDuration() {
    setState(() {
      data1 =
          _printDuration(Duration(hours: 0, minutes: 0, seconds: timePassedInt))
              .toString();
      data2 =
          _printDuration(Duration(hours: 0, minutes: 0, seconds: timeEarnedInt))
              .toString();
      data3 =
          _printDuration(Duration(hours: 0, minutes: 0, seconds: timeSpendable))
              .toString();
      data4 = _printDuration(Duration(hours: 0, minutes: 0, seconds: timeSpent))
          .toString();
    });
  }

  void _countdownFunc() {
    if (isModeStudy == true) {
      if (isStarted == false) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            timePassedDouble = timePassedDouble + 1;
            timeEarnedDouble = (timePassedDouble * 0.6);
            timePassedInt = timePassedDouble.toInt();
            timeEarnedInt = timeEarnedDouble.toInt();
            timeSpendable = timeEarnedInt - timeSpent;
          });
          sumPrintDuration();
        });
      } else {
        _timer.cancel();
      }
    } else {
      if (isStarted == false) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            if (timeSpendable > 0) {
              timeSpent = timeSpent + 1;
              timeSpendable = timeEarnedInt - timeSpent;
            } else {
              _timer.cancel();
              _changeModFunc();
            }
            sumPrintDuration();
          });
        });
      } else {
        _timer.cancel();
      }
    }
  }

  void _changeModFunc() {
    _stopButtonFunc();
    setState(() {
      startStopIcon = Icons.play_arrow_outlined;
    });
    if (timeSpendable > 0) {
      if (isModeStudy == true) {
        setState(() {
          modIcon = Icons.sports_esports_outlined;
        });
        isModeStudy = false;
      } else {
        setState(() {
          modIcon = Icons.mode_edit_outlined;
        });
        isModeStudy = true;
      }
    } else {
      setState(() {
        modIcon = Icons.mode_edit_outlined;
      });
      isModeStudy = true;
    }
  }

  Future<void> saveData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble("timePassedDoubleData", timePassedDouble);
    prefs.setDouble("timeEarnedDoubleData", timeEarnedDouble);
    prefs.setInt("timeSpendableData", timeSpendable);
    prefs.setInt("timeSpentData", timeSpent);
  }

  void loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      timePassedDouble = prefs.getDouble("timePassedDoubleData")!;
      timeEarnedDouble = prefs.getDouble("timeEarnedDoubleData")!;
      timeSpendable = prefs.getInt("timeSpendableData")!;
      timeSpent = prefs.getInt("timeSpentData")!;
      timePassedInt = timePassedDouble.toInt();
      timeEarnedInt = timeEarnedDouble.toInt();
    });
    sumPrintDuration();
  }

  void resetData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble("timePassedDoubleData", 0);
    prefs.setDouble("timeEarnedDoubleData", 0);
    prefs.setInt("timeSpendableData", 0);
    prefs.setInt("timeSpentData", 0);
    loadData();
    setState(() {
      modIcon = Icons.mode_edit_outlined;
    });
    isModeStudy = true;
  }

  void _showDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            titleTextStyle: GoogleFonts.roboto(
                textStyle: TextStyle(color: Colors.white),
                fontWeight: FontWeight.w700),
            contentTextStyle: GoogleFonts.roboto(
                textStyle: TextStyle(color: Colors.white),
                fontWeight: FontWeight.w700),
            backgroundColor: Colors.grey[600],
            title: Text("ATTENTION!"),
            content: Text("Data will be erased. Do you want to continue?"),
            actions: [
              MaterialButton(
                onPressed: () {
                  resetData();
                  Navigator.of(context).pop();
                },
                child: Text(
                  "YES",
                  style: GoogleFonts.roboto(
                      textStyle: TextStyle(color: Colors.white),
                      fontWeight: FontWeight.w700),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "NO",
                  style: GoogleFonts.roboto(
                      textStyle: TextStyle(color: Colors.white),
                      fontWeight: FontWeight.w700),
                ),
              )
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    WidgetsBinding.instance!.addObserver(this);
    loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      pausedTime = DateTime.now();
      _stopButtonFunc();
    } else if (state == AppLifecycleState.resumed) {
      resumedTime = DateTime.now();
      _startStopButtonFunc();
      calculatedTimeToSeconds =
          resumedTime.difference(pausedTime).inSeconds.toDouble();
      if (isModeStudy == true) {
        setState(() {
          timePassedDouble = timePassedDouble + calculatedTimeToSeconds;
          timeEarnedDouble = (timePassedDouble * 0.6);
          timePassedInt = timePassedDouble.toInt();
          timeEarnedInt = timeEarnedDouble.toInt();
          timeSpendable = timeEarnedInt - timeSpent;
          sumPrintDuration();
        });
      } else if (isModeStudy == false) {
        if (timeSpendable - calculatedTimeToSeconds > 0) {
          setState(() {
            timeSpent = timeSpent + calculatedTimeToSeconds.toInt();
            timeSpendable = timeEarnedInt - timeSpent;
          });
        } else {
          setState(() {
            timeSpent = timeSpent + calculatedTimeToSeconds.toInt();
            timeSpendable = 0;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: SingleChildScrollView(
        child: Center(
            child: Padding(
          padding:
              const EdgeInsets.only(left: 50, right: 50, top: 50, bottom: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 250,
                height: 500,
                decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.all(Radius.circular(60)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[900]!,
                        offset: Offset(5.0, 5.0),
                        blurRadius: 15.0,
                        spreadRadius: 1.0,
                      ),
                      BoxShadow(
                        color: Colors.grey[800]!,
                        offset: Offset(-5.0, -5.0),
                        blurRadius: 15.0,
                        spreadRadius: 1.0,
                      )
                    ]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data1,
                          style: GoogleFonts.roboto(
                              textStyle:
                                  TextStyle(fontSize: 45, color: Colors.white),
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          "TIME STUDIED",
                          style: GoogleFonts.roboto(
                              textStyle:
                                  TextStyle(fontSize: 15, color: Colors.white),
                              fontWeight: FontWeight.w900),
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data2,
                          style: GoogleFonts.roboto(
                              textStyle:
                                  TextStyle(fontSize: 45, color: Colors.white),
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          "TIME EARNED",
                          style: GoogleFonts.roboto(
                              textStyle:
                                  TextStyle(fontSize: 15, color: Colors.white),
                              fontWeight: FontWeight.w900),
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data3,
                          style: GoogleFonts.roboto(
                              textStyle:
                                  TextStyle(fontSize: 45, color: Colors.white),
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          "TIME SPENDABLE",
                          style: GoogleFonts.roboto(
                              textStyle:
                                  TextStyle(fontSize: 15, color: Colors.white),
                              fontWeight: FontWeight.w900),
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data4,
                          style: GoogleFonts.roboto(
                              textStyle:
                                  TextStyle(fontSize: 45, color: Colors.white),
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          "TIME SPENT",
                          style: GoogleFonts.roboto(
                              textStyle:
                                  TextStyle(fontSize: 15, color: Colors.white),
                              fontWeight: FontWeight.w900),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Container(
                width: 250,
                height: 180,
                decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.all(Radius.circular(60)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[900]!,
                        offset: Offset(5.0, 5.0),
                        blurRadius: 15.0,
                        spreadRadius: 1.0,
                      ),
                      BoxShadow(
                        color: Colors.grey[800]!,
                        offset: Offset(-5.0, -5.0),
                        blurRadius: 15.0,
                        spreadRadius: 1.0,
                      )
                    ]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          icon: Icon(
                            startStopIcon,
                            color: Colors.white,
                          ),
                          iconSize: 70,
                          onPressed: _startStopButtonFunc,
                        ),
                        IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          icon: Icon(
                            modIcon,
                            color: Colors.white,
                          ),
                          iconSize: 60,
                          onPressed: _changeModFunc,
                        ),
                      ],
                    ),
                    IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: const Icon(
                        Icons.clear_outlined,
                        color: Colors.white,
                      ),
                      iconSize: 60,
                      onPressed: _showDialog,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
