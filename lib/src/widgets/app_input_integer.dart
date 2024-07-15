import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class AppInputInteger extends StatefulWidget {
  final String name;
  final String displayValue;
  final String label;
  final Widget? suffix;
  final List<String? Function(int?)> validators;
  final num? initialValue;
  final Function? onChanged;
  final bool showSteps;

  const AppInputInteger(
      {super.key,
      required this.name,
      this.displayValue = 'name',
      required this.label,
      this.validators = const [],
      this.initialValue,
      this.suffix,
      this.onChanged,
      this.showSteps = false});

  @override
  State<AppInputInteger> createState() => _AppInputIntegerState();
}

class _AppInputIntegerState extends State<AppInputInteger> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = (widget.initialValue ?? 0).toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<int>(
        name: widget.name,
        validator: FormBuilderValidators.compose(widget.validators),
        builder: ((field) {
          return Column(
            children: [
              TextFormField(
                  textAlign: TextAlign.end,
                  controller: _controller,
                  decoration: InputDecoration(
                      errorText: field.errorText,
                      label: Text(
                        widget.label,
                      ),
                      suffix: widget.suffix),
                  // initialValue: (field.value ???? 0).toString(),
                  keyboardType: TextInputType.number,
                  onEditingComplete: () {
                    debugPrint("edit complete");
                  },
                  onChanged: (value) {
                    onChange(field, value);
                  }),
              if (widget.showSteps)
                const SizedBox(
                  height: 15,
                ),
              if (widget.showSteps)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          int old = int.parse(_controller.text ?? '0');
                          var newValue = (old > 0 ? old - 1 : 0).toString();
                          setState(() {
                            _controller.text = newValue;
                          });
                          onChange(field, newValue);
                        },
                        icon: const Icon(
                          Icons.remove_circle_outlined,
                          color: Colors.redAccent,
                        )),
                    const SizedBox(width: 60,),
                    IconButton(
                        onPressed: () {
                          var newValue =
                              (int.parse(_controller.text ?? '0') + 1)
                                  .toString();
                          setState(() {
                            _controller.text = newValue;
                          });
                          onChange(field, newValue);
                        },
                        icon: Icon(
                          Icons.add_circle,
                          color: Theme.of(context).primaryColor,
                        ))
                  ],
                )
            ],
          );
        }));
  }

  onChange(FormFieldState field, value) {
    field.didChange(value.isNotEmpty ? int.parse(value) : 0);
    if (widget.onChanged != null) {
      widget.onChanged!(field.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
