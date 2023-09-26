import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class AppInputIntegerButton extends StatefulWidget {
  final String name;
  final String displayValue;
  final String label;
  final Widget? suffix;
  final List<String? Function(int?)> validators;
  final num? initialValue;
  final Function? onChanged;

  const AppInputIntegerButton({
    Key? key,
    required this.name,
    this.displayValue = 'name',
    required this.label,
    this.validators = const [],
    this.initialValue,
    this.suffix,
    this.onChanged,
  }) : super(key: key);

  @override
  _AppInputIntegerButtonState createState() => _AppInputIntegerButtonState();
}

class _AppInputIntegerButtonState extends State<AppInputIntegerButton> {
  late TextEditingController _controller;
  int _value = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: (_value ?? widget.initialValue ?? 0).toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() {
      _value++;
      _updateController();
    });
    if (widget.onChanged != null) {
      widget.onChanged!(_value);
    }
  }

  void _decrement() {
    if (_value > 0) {
      setState(() {
        _value--;
        _updateController();
      });
      if (widget.onChanged != null) {
        widget.onChanged!(_value);
      }
    }
  }

  void _updateController() {
    _controller.text = _value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<int>(
      name: widget.name,
      validator: FormBuilderValidators.compose(widget.validators),
      builder: (field) {
        return Row(
          children: [
            IconButton(
              onPressed: _decrement,
              icon: Icon(Icons.remove),
            ),
            Expanded(
              child: TextFormField(
                controller: _controller,
                textAlign: TextAlign.end,
                decoration: InputDecoration(
                  errorText: field.errorText,
                  label: Text(widget.label),
                  suffix: widget.suffix,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final intValue = int.tryParse(value) ?? 0;
                  setState(() {
                    _value = intValue;
                  });
                  field.didChange(intValue);
                  if (widget.onChanged != null) {
                    widget.onChanged!(intValue);
                  }
                },
              ),
            ),
            IconButton(
              onPressed: _increment,
              icon: Icon(Icons.add),
            ),
          ],
        );
      },
    );
  }
}
