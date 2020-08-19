import 'package:flutter/material.dart';
import 'preference_page.dart';

class PreferencePageLink extends StatelessWidget {
  final String title;
  final String pageTitle;
  final String desc;
  final PreferencePage page;
  final Widget leading;
  final Widget trailing;
  final TextStyle style;
  PreferencePageLink(this.title,
      {@required this.page,
      this.desc,
      this.pageTitle,
      this.leading,
      this.trailing,
      this.style});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Scaffold(
                appBar: AppBar(
                  title: Text(pageTitle ?? title),
                ),
                body: page,
              ))),
      title: Text(title, style: style ?? TextStyle()),
      subtitle: desc == null ? null : Text(desc),
      leading: leading,
      trailing: trailing,
    );
  }
}
