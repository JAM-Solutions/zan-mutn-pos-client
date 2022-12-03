import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class AppInputInteger extends StatelessWidget {
  final String fieldName;
  final String displayValue;
  final String label;
  final List<String? Function(int?)> validators;
  final num? initialValue;

  const AppInputInteger(
      {super.key,
      required this.fieldName,
      this.displayValue = 'name',
      required this.label,
      this.validators = const [],
      this.initialValue});

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<int>(
        name: fieldName,
        validator: FormBuilderValidators.compose(validators),
        builder: ((field) {
          return TextFormField(
              decoration: InputDecoration(
                  errorText: field.errorText,
                  label: Text(
                    label,
                  )),
              initialValue: (field.value ?? initialValue ?? 0).toString(),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                field.didChange(value.isNotEmpty ? int.parse(value) : 0);
              });
        }));
  }
}
