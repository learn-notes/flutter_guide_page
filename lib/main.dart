import 'package:flutter/material.dart';

import 'demo1_guide.dart';
import 'demo2_guide.dart';

///
/// 引导页案例
///
/// @author : Joh Liu
/// @date : 2019/7/3 12:14
///
void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: '首页',
      home: new Scaffold(
        appBar: AppBar(
          title: Text('首页'),
          centerTitle: true,
        ),
        body: Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        RaisedButton(
            child: Text('原案例'),
            onPressed: () {
              /// 页面跳转
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => GuideOnePage()));
            }),
        RaisedButton(
            child: Text('改动案例'),
            onPressed: () {
              /// 页面跳转
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => GuideTwoPage()));
            }),
      ],
    );
  }
}
