import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'utils/localeHelper.dart';

class AboutPage extends StatefulWidget {

  @override
  _AboutPageState createState() => _AboutPageState();

}

class _AboutPageState extends State<AboutPage> {

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  TextStyle _textStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontFamily: 'Poppins-Regular'
  );

  @override
  Widget build(BuildContext context) {
    //super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppLocalizations.of(context).translate('About')}', style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins-Regular'
        )),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[900],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(flex: 1, child: Container()),
                    Flexible(
                      flex: 3,
                      child: Image(
                        image: AssetImage('assets/cut_logo.png'),
                        alignment: Alignment.center,
                      )
                    ),
                    Flexible(flex: 1, child: Container())
                  ],
                ),
                Padding(padding: EdgeInsets.all(15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton.icon(
                      color: Colors.blue[900],
                      icon: Icon(Icons.email, color: Colors.white),
                      label: Text('${AppLocalizations.of(context).translate('ContactMe')}', style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins-Regular'
                      )),
                      onPressed: () => _launchURL('mailto:app.gymtimer@gmail.com?subject=Gym timer app')
                    ),

                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton.icon(
                      color: Colors.blue[900],
                      icon: Icon(Icons.code, color: Colors.white),
                      label: Text('${AppLocalizations.of(context).translate('GitHub')}', style: _textStyle),
                      onPressed: () => _launchURL('https://github.com/ClementJu/gym_timer'),
                    ),

                  ],
                ),
                Padding(padding: EdgeInsets.all(15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Text('© Copyright 2020 - Julien Clément', style: _textStyle),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Text('app.gymtimer@gmail.com', style: _textStyle),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Text('${AppLocalizations.of(context).translate('Version')} 1.0.0', style: _textStyle),
                    )
                  ],
                ),
              ],
            )
          ),
        ],
      ),
    );
  }
}