import 'dart:async';
import 'dart:math';

import 'package:cronicalia_flutter/custom_widgets/persistent_bottom_bar.dart';
import 'package:cronicalia_flutter/flux/user_store.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/profile_screen/profile_image_picker.dart';

import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

enum ImageOrigin { CAMERA, GALLERY }
enum ImageType { BACKGROUND, PROFILE }
enum TextClickCategory { NAME, TWITTER_PROFILE, ABOUT_ME }

class ProfileScreen extends StatefulWidget {
  ProfileScreen();

  @override
  State createState() {
    return ProfileScreenState();
  }
}

class ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin, StoreWatcherMixin<ProfileScreen> {
  UserStore _userStore;
  bool _isEditModeOn = false;
  AnimationController _wiggleController;
  Animation<double> _wiggleAnimation;
  TextEditingController _textController;

  @override
  void initState() {
    super.initState();

    _textController = new TextEditingController();
    _wiggleController = new AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _wiggleAnimation = new Tween(begin: -pi / 60, end: pi / 60).animate(_wiggleController)
      ..addListener(() {
        setState(() {});
      });

    _wiggleController.addStatusListener((animationStatus) {
      switch (animationStatus) {
        case AnimationStatus.completed:
          {
            if (_isEditModeOn) {
              _wiggleController.reverse();
            } else {
              _wiggleController.reset();
            }
            break;
          }
        case AnimationStatus.dismissed:
          {
            if (_isEditModeOn) {
              _wiggleController.forward();
            } else {
              _wiggleController.reset();
            }
            break;
          }
        default:
          break;
      }
    });

    _userStore = listenToStore(userStoreToken);
  }

  @override
  void dispose() {
    _wiggleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(
          child: new Stack(
            children: [
              new Container(
                height: double.infinity,
                child: Image(
                  image: ProfileImagePicker.getBackgroundImageProvider(
                      _userStore.user.localBackgroundPictureUri, _userStore.user.remoteBackgroundPictureUri),
                  alignment: Alignment.topCenter,
                ),
                foregroundDecoration: new BoxDecoration(
                  gradient: new LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, AppThemeColors.primaryColor, AppThemeColors.canvasColor],
                  ),
                ),
              ),
              new Center(
                child: new SingleChildScrollView(
                  padding: new EdgeInsets.only(top: 125.0, bottom: 16.0),
                  child: new Stack(children: [
                    Card(
                      child: new FractionallySizedBox(
                        widthFactor: 0.90,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _buildEditButton(
                                buttonTitle: "CHANGE POSTER",
                                onClick: () {
                                  if (_userStore.isLoggedIn) {
                                    print("User logged in");
                                    _showImageOriginDialog(ImageType.BACKGROUND);
                                  } else {
                                    Navigator.of(context).pushNamed(Constants.ROUTE_LOGIN_SCREEN);
                                  }
                                },
                                padding: const EdgeInsets.only(top: 8.0, right: 12.0, left: 8.0)),
                            _buildEditButton(
                              buttonTitle: "CHANGE PROFILE",
                              onClick: () {
                                if (_userStore.isLoggedIn) {
                                  print("User logged in");
                                  _showImageOriginDialog(ImageType.PROFILE);
                                } else {
                                  Navigator.of(context).pushNamed(Constants.ROUTE_LOGIN_SCREEN);
                                }
                              },
                            ),
                            _buildEditButton(
                              buttonTitle: "CHANGE TEXTS",
                              onClick: () {
                                _isEditModeOn = !_isEditModeOn;
                                if (_isEditModeOn) {
                                  _wiggleController.forward();
                                }
                              },
                            ),
                            new Padding(
                              padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
                              child: new GestureDetector(
                                onTap: () {
                                  if (_isEditModeOn) {
                                    _showAboutMeTextInputDialog();
                                    _isEditModeOn = false;
                                  }
                                },
                                child: new Transform.rotate(
                                  angle: (_isEditModeOn == true) ? _wiggleAnimation.value : 0.0,
                                  child: new Text(
                                    _userStore.user.aboutMe != null ? _userStore.user.aboutMe : "Tell your readers about you",
                                    textAlign: TextAlign.justify,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 8,
                                    style: TextStyle(color: TextColorDarkBackground.secondary),
                                  ),
                                ),
                              ),
                            ),
                            _userStatsWidget(context)
                          ],
                        ),
                      ),
                    ),
                    userIdentificationWidget(context),
                  ]),
                ),
              ),
            ],
          ),
        ),
        PersistentBottomBar(
          selectedItemIdex: 4,
        ),
      ]),
    );
  }

  Widget _buildEditButton(
      {@required String buttonTitle, @required Function onClick, EdgeInsets padding = const EdgeInsets.only(left: 8.0, right: 16.0)}) {
    return new Align(
      alignment: Alignment.centerRight,
      child: new Padding(
        padding: padding,
        child: ButtonTheme(
          minWidth: 135.0,
          child: OutlineButton(
            child: Text(
              buttonTitle,
              style: TextStyle(fontSize: 12.0),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            onPressed: onClick,
            textColor: AppThemeColors.accentColor,
            borderSide: BorderSide(color: AppThemeColors.accentColor, width: 1.5),
            highlightColor: Colors.white,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Future<Null> _showImageOriginDialog(ImageType imageType) async {
    switch (await showDialog<ImageOrigin>(
        context: context,
        builder: (BuildContext context) {
          return new SimpleDialog(
            title: const Text('Select image from?'),
            children: <Widget>[
              new SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ImageOrigin.CAMERA);
                },
                child: const Text('CAMERA'),
              ),
              new SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ImageOrigin.GALLERY);
                },
                child: const Text('GALLERY'),
              ),
            ],
          );
        })) {
      case ImageOrigin.CAMERA:
        ProfileImagePicker.pickImageFromCamera(imageType, _userStore.user);
        break;
      case ImageOrigin.GALLERY:
        ProfileImagePicker.pickImageFromGallery(imageType, _userStore.user);
        break;
    }
  }

  Future<Null> _showNameTextInputDialog() async {
    _textController.text = _userStore.user.name != null ? _userStore.user.name : "Unknown user";

    const Text title = Text(
      "Edit user name",
      style: const TextStyle(fontSize: 20.0),
    );
    TextFormField textFormField = TextFormField(
      controller: _textController,
      maxLength: 40,
      maxLengthEnforced: true,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(labelText: "Profile name", helperText: "3 characters minimum"),
      onFieldSubmitted: (value) {
        if (value.length >= 3) {
          Navigator.pop(context, value);
        }
      },
    );

    String userInput = (await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return new Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: title,
                ),
                new Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: textFormField,
                ),
                new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      new FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("CANCEL"),
                        textColor: AppThemeColors.accentColor,
                      ),
                      new FlatButton(
                        onPressed: () {
                          if (_textController.text.length >= 3) {
                            Navigator.pop(context, _textController.text);
                          }
                        },
                        child: Text("SUBMIT"),
                        textColor: AppThemeColors.accentColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }));

    if (userInput != null && userInput.length >= 3) {
      updateUserNameAction(userInput);
    }
  }

  Future<Null> _showTwitterTextInputDialog() async {
    if (_userStore.user.twitterProfile != null) {
      _textController.text =
          (_userStore.user.twitterProfile.startsWith('@') ? _userStore.user.twitterProfile.substring(1) : _userStore.user.twitterProfile);
    } else {
      _textController.text = '';
    }

    const Text title = Text(
      "Edit twitter profile",
      style: const TextStyle(fontSize: 20.0),
    );
    TextFormField textFormField = TextFormField(
      controller: _textController,
      maxLength: 15,
      maxLengthEnforced: true,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(labelText: "Twitter handle", helperText: "3 characters minimum", prefixText: "@"),
      onFieldSubmitted: (value) {
        String twitterProfile = value;
        if (!twitterProfile.startsWith('@')) {
          twitterProfile = "@$twitterProfile";
        }
        if (twitterProfile.length >= 3) {
          Navigator.pop(context, twitterProfile);
        }
      },
    );

    String userInput = (await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return new Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: title,
                ),
                new Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: textFormField,
                ),
                new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      new FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("CANCEL"),
                        textColor: AppThemeColors.accentColor,
                      ),
                      new FlatButton(
                        onPressed: () {
                          String twitterProfile = _textController.text;
                          if (!twitterProfile.startsWith('@')) {
                            twitterProfile = "@$twitterProfile";
                          }
                          if (twitterProfile.length >= 3) {
                            Navigator.pop(context, twitterProfile);
                          }
                        },
                        child: Text("SUBMIT"),
                        textColor: AppThemeColors.accentColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }));

    if (userInput != null && userInput.length >= 3) {
      updateUserTwitterProfileAction(userInput);
    }
  }

  Future<Null> _showAboutMeTextInputDialog() async {
    _textController.text = _userStore.user.aboutMe != null ? _userStore.user.aboutMe : "";

    const Text title = Text(
      "Tell users about you",
      style: const TextStyle(fontSize: 20.0),
    );
    TextFormField textFormField = TextFormField(
      controller: _textController,
      maxLines: 8,
      maxLength: 3000,
      maxLengthEnforced: true,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(labelText: "About me"),
      onFieldSubmitted: (value) {
        if (value.length <= 3000) {
          Navigator.pop(context, value);
        }
      },
    );

    String userInput = (await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return new SingleChildScrollView(
            child: new Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: title,
                  ),
                  new Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: textFormField,
                  ),
                  new Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        new FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("CANCEL"),
                          textColor: AppThemeColors.accentColor,
                        ),
                        new FlatButton(
                          onPressed: () {
                            if (_textController.text.length <= 3000) {
                              Navigator.pop(context, _textController.text);
                            }
                          },
                          child: Text("SUBMIT"),
                          textColor: AppThemeColors.accentColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }));

    if (userInput != null) {
      updateUserAboutMeAction(userInput);
    }
  }

  Widget _userStatsWidget(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(16.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.favorite, color: TextColorDarkBackground.tertiary,),
              ),
              Text(
                _userStore.user.fans.toString(),
                style: TextStyle(color: TextColorDarkBackground.secondary, fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ],
          ),
          new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.remove_red_eye, color: TextColorDarkBackground.tertiary,),
              ),
              Text(
                _calculateUserTotalViews().toString(),
                style: TextStyle(color: TextColorDarkBackground.secondary, fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ],
          ),
          new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, bottom: 8.0),
                child: Icon(Icons.attach_money, color: TextColorDarkBackground.tertiary,),
              ),
              new Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  _calculateUserTotalIncome().toString(),
                  style: TextStyle(color: TextColorDarkBackground.secondary, fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  int _calculateUserTotalViews() {
    int userTotalViews = 0;
    _userStore.user.books.forEach((_, book) {
      userTotalViews += book.readingsNumber;
    });

    return userTotalViews;
  }

  double _calculateUserTotalIncome() {
    double userTotalIncome = 0.0;
    _userStore.user.books.forEach((_, book) {
      userTotalIncome += book.income;
    });

    return userTotalIncome;
  }

  Widget userIdentificationWidget(BuildContext context) {
    return new FractionalTranslation(
      translation: Offset(0.13, -0.25),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildProfilePictureWidget(),
          new Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: 4.0),
            child: new GestureDetector(
              onTap: () {
                if (_isEditModeOn) {
                  _showNameTextInputDialog();
                  _isEditModeOn = false;
                }
              },
              child: new Transform.rotate(
                angle: (_isEditModeOn == true) ? _wiggleAnimation.value : 0.0,
                child: Text(
                  _userStore.user.name,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                  maxLines: 2,
                ),
              ),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            child: new GestureDetector(
              onTap: () {
                if (_isEditModeOn) {
                  _showTwitterTextInputDialog();
                  _isEditModeOn = false;
                }
              },
              child: new Transform.rotate(
                angle: (_isEditModeOn == true) ? _wiggleAnimation.value : 0.0,
                child: Text(
                  _userStore.user.twitterProfile != null ? _userStore.user.twitterProfile : "yourTwitterProfile",
                  style: TextStyle(color: TextColorDarkBackground.secondary),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProfilePictureWidget() {
    return Container(
      width: 120.0,
      height: 120.0,
      foregroundDecoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor, offset: Offset(2.0, 2.0), blurRadius: 6.0, spreadRadius: 1.0)],
        border: Border.all(color: Theme.of(context).accentColor),
        shape: BoxShape.circle,
        image: DecorationImage(
            image:
                ProfileImagePicker.getProfileImageProvider(_userStore.user.localProfilePictureUri, _userStore.user.remoteProfilePictureUri),
            fit: BoxFit.fill),
      ),
    );
  }
}
