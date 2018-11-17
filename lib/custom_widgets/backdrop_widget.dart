import 'package:flutter/material.dart';

class BackdropWidget extends StatefulWidget {
  final AnimationController controller;
  final Widget backChild;
  final Widget frontChild;

  BackdropWidget({@required this.controller, @required this.backChild, @required this.frontChild});


  @override
  State createState() {
    return _BackdropWidgetState();
  }
}

class _BackdropWidgetState extends State<BackdropWidget> with SingleTickerProviderStateMixin<BackdropWidget> {

	Animation<Alignment> _frontPanelAnimation;

  @override
  void initState() {
	  _frontPanelAnimation = AlignmentTween(begin: Alignment(-1.0, 2.0), end: Alignment(-1.0, 1.0)).animate(
		  new CurvedAnimation(parent: widget.controller, curve: Curves.easeInOut),
	  );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        widget.backChild,
        Container(
	        height: MediaQuery.of(context).size.height,
          child: AlignTransition(
            alignment: _frontPanelAnimation,
            child: new Material(
              elevation: 12.0,
              borderRadius:
                  new BorderRadius.only(topLeft: new Radius.circular(16.0), topRight: new Radius.circular(16.0)),
              child: Container(child: widget.frontChild),
            ),
          ),
        )
      ],
    );
  }
}
