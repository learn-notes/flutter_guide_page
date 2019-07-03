import 'dart:ui' as ui;
import 'package:flutter/material.dart';

///
/// flutter引导页
///
/// @author : Joh Liu
/// @date : 2019/7/2 12:12
///
List<String> cardList = [
  "assets/one.jpg",
  "assets/two.jpg",
  "assets/three.jpg",
  "assets/four.jpg",
];

enum Direction { LEFT, RIGHT }

class GuideTwoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GuideTwoPageState();
}

class _GuideTwoPageState extends State<GuideTwoPage>
    with TickerProviderStateMixin {
  double scrollPercent = 0.0;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          /// 桌面背景
          CardFlipper(
            cards: cardList,
            onScroll: (double sp) {
              setState(() {
                this.scrollPercent = sp;
              });
            },
          ),

          Column(
            children: <Widget>[
              Expanded(
                child: Container(width: 0.0, height: 0.0),
              ),

              /// 底部导航条
              BottomBar(
                cardCount: cardList.length,
                scrollPercent: scrollPercent,
              )
            ],
          )
        ],
      ),
    );
  }
}

///
/// 中部可滑动卡片
class CardFlipper extends StatefulWidget {
  CardFlipper({this.cards, this.onScroll});

  final List<String> cards;
  final Function(double scrollPercent) onScroll;

  @override
  _CardFlipperState createState() {
    return _CardFlipperState();
  }
}

class _CardFlipperState extends State<CardFlipper>
    with TickerProviderStateMixin {
  double scrollPercent = 0.0;
  Offset startDrag;
  double startDragPercentScroll;
  double finishScrollStart;
  double finishScrollEnd;

  AnimationController finishScrollController;
  Direction direction = Direction.LEFT;

  @override
  void initState() {
    super.initState();
    finishScrollController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    )..addListener(() {
        setState(() {
          scrollPercent = ui.lerpDouble(
              finishScrollStart, finishScrollEnd, finishScrollController.value);
          widget.onScroll(scrollPercent);
        });
      });
  }

  @override
  void dispose() {
    finishScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      ///
      /// 横向滑动监听
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: _buildCards(),
      ),
    );
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    startDrag = details.globalPosition;
    startDragPercentScroll = scrollPercent;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final currDrag = details.globalPosition;
    final dragDistance = currDrag.dx - startDrag.dx;
    final allCardDragDistance = dragDistance / context.size.width;
    final numCards = widget.cards.length;
    if (allCardDragDistance > 0) {
      direction = Direction.LEFT;
    } else {
      direction = Direction.RIGHT;
    }
    setState(() {
      scrollPercent =
          (startDragPercentScroll + (-allCardDragDistance / numCards))
              .clamp(0.0, 1.0 - (1 / numCards));
      widget.onScroll(scrollPercent);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final numCards = widget.cards.length;
    finishScrollStart = scrollPercent;
    if (direction == Direction.LEFT) {
      finishScrollEnd = (scrollPercent * numCards).floor() / numCards;
    } else {
      finishScrollEnd = (scrollPercent * numCards).ceil() / numCards;
    }

    finishScrollController.forward(from: 0.0);
    setState(() {
      startDrag = null;
      startDragPercentScroll = null;
    });
  }

  List<Widget> _buildCards() {
    int i = -1;
    return widget.cards.map<Widget>((image) {
      i++;
      return _buildCard(image, i, widget.cards.length, scrollPercent);
    }).toList();
  }

  Widget _buildCard(
      String img, int cardIndex, int cardCount, double scrollPercent) {
    /// 图片公共偏移量
    final cardScrollPercent = scrollPercent * cardCount;

    /// 图片展现和隐藏时的偏移点
    final parallax = scrollPercent - (cardIndex / cardCount);

    return FractionalTranslation(
      /// 当前图片偏移量
      /// 只要实现图片跟着手势切换
      translation: Offset(cardIndex - cardScrollPercent, 0.0),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ClipRect(
            child: FractionalTranslation(
              /// 设置图片控件内X轴偏移量
              /// 主要是实现图片切换时，图片内容跟着手势慢慢展现
              translation: Offset(parallax * 2.0, 0.0),
              child: Image.asset(
                img,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 底部导航
class BottomBar extends StatefulWidget {
  BottomBar({this.cardCount, this.scrollPercent});

  final int cardCount;
  final double scrollPercent;

  @override
  _BottomBarState createState() {
    return _BottomBarState();
  }
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 120.0, right: 120.0),
              width: double.infinity,

              /// 底部导航高度
              height: 5.0,
              child: CustomPaint(
                painter: ScrollIndicatorPainter(
                  cardCount: widget.cardCount,
                  scrollPercent: widget.scrollPercent,

                  /// 导航指针宽度，
                  /// 配合导航条高度的设置可实现 圆形导航指针、扁平导航指针
//                  trackW: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 导航条
class ScrollIndicatorPainter extends CustomPainter {
  ScrollIndicatorPainter({this.cardCount, this.scrollPercent, this.trackW = 20})
      : trackPaint = Paint()
          ..color = Color(0xFF444444)
          ..style = PaintingStyle.fill,
        thumbPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

  final int cardCount;
  final double scrollPercent;
  final Paint trackPaint;
  final Paint thumbPaint;

  /// 指针宽度
  final double trackW;

  @override
  void paint(Canvas canvas, Size size) {
    ///
    /// 指针预定轨道图
    double startL = size.width / 8 - trackW / 2;
    for (int i = 0; i < cardCount; i++) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(startL + size.width / 4 * i, 0.0, trackW, size.height),
          topLeft: Radius.circular(3.0),
          topRight: Radius.circular(3.0),
          bottomLeft: Radius.circular(3.0),
          bottomRight: Radius.circular(3.0),
        ),
        trackPaint,
      );
    }

    ///
    /// 指针图
    final thumbLeft = scrollPercent * size.width + startL;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(thumbLeft, 0.0, trackW, size.height),
        topLeft: Radius.circular(3.0),
        topRight: Radius.circular(3.0),
        bottomLeft: Radius.circular(3.0),
        bottomRight: Radius.circular(3.0),
      ),
      thumbPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
