import 'package:flutter/material.dart';
import 'package:gym_timer/preferences-mod/preference_service.dart';

class DropdownPreference extends StatefulWidget {
  final Text title;
  final TextStyle style;
  final String desc;
  final String localKey;
  final dynamic defaultVal;

  final List values;
  final List displayValues;

  final Function onChange;

  final bool disabled;

  DropdownPreference(
    this.title,
    this.localKey, {
    this.style,
    this.desc,
    @required this.defaultVal,
    @required this.values,
    this.displayValues,
    this.onChange,
    this.disabled = false,
  });

  _DropdownPreferenceState createState() => _DropdownPreferenceState();
}

class _DropdownPreferenceState extends State<DropdownPreference> {
  @override
  void initState() {
    super.initState();
    if (PrefService.get(widget.localKey) == null)
      PrefService.setDefaultValues({widget.localKey: widget.defaultVal});
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: widget.title,
      subtitle: widget.desc == null ? null : Text(widget.desc),
      trailing: DropdownButton(
        items: widget.values.map((var val) {
          return DropdownMenuItem(
            value: val,
            child: Text(
              widget.displayValues == null
                  ? val
                  : widget.displayValues[widget.values.indexOf(val)],
              textAlign: TextAlign.end,
            style: widget.style),
          );
        }).toList(),
        onChanged: widget.disabled
            ? null
            : (newVal) async {
                onChange(newVal);
              },
        value: PrefService.get(widget.localKey) ?? widget.defaultVal,
      ),
    );
  }

  onChange(var val) {
    if (val is String) {
      this.setState(() => PrefService.setString(widget.localKey, val));
    } else if (val is int) {
      this.setState(() => PrefService.setInt(widget.localKey, val));
    } else if (val is double) {
      this.setState(() => PrefService.setDouble(widget.localKey, val));
    } else if (val is bool) {
      this.setState(() => PrefService.setBool(widget.localKey, val));
    }
    if (widget.onChange != null) widget.onChange(val);
  }
}
