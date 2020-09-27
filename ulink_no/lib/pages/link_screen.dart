import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ulink/shared/common_utils.dart';

import '../models/user_repository.dart';

class LinkScreen extends StatefulWidget {
  LinkScreen({Key key}) : super(key: key);

  @override
  _LinkScreenState createState() => _LinkScreenState();
}

class _LinkScreenState extends State<LinkScreen> {
  UserRepository _userRepository;

  @override
  Widget build(BuildContext buildContext) {
    _userRepository =
        _userRepository ?? RepositoryProvider.of<UserRepository>(buildContext);

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(4.0),
      child: Center(
        child: _linkEditorForm(buildContext),
      ),
    );
  }

  Map<String, dynamic> _formInput = new Map();
  TextEditingController _textEditingController =
      TextEditingController(text: '');
  final _formKey = GlobalKey<FormState>();
  _linkEditorForm(BuildContext buildContext) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            validator: (inputValue) {
              Map<String, dynamic> _validateURL =
                  CommonUtils.isValidUrl(inputValue);
              if (!_validateURL['isValid']) {
                return _validateURL['message'];
              }

              setState(() {
                _formInput['long_link'] = inputValue.toString();
              });
              return null;
            },
            textCapitalization: TextCapitalization.none,
            autofocus: false,
            keyboardType: TextInputType.url,
            controller: _textEditingController,
            cursorColor: Colors.deepOrange,
            style: TextStyle(color: Colors.deepOrangeAccent),
            decoration: const InputDecoration(
              icon:
                  Icon(Icons.http, size: 24.0, color: Colors.deepOrangeAccent),
              hintText: 'Paste a long link (URL)',
              hintStyle: TextStyle(
                  color: Colors.deepOrangeAccent, fontStyle: FontStyle.normal),
              //hasFloatingPlaceholder: true,
              helperText: 'https://www.montypython.com/pythonland/',
              helperStyle: TextStyle(
                  color: Colors.orangeAccent, fontStyle: FontStyle.italic),
              errorStyle: TextStyle(
                  color: Colors.deepOrange, fontStyle: FontStyle.italic),
            ),
          ),
          SizedBox(
            width: 20,
            height: 20,
          ),
          MaterialButton(
            color: Colors.white,
            child: Icon(
              Icons.transform_rounded,
              size: 40,
              color: Colors.deepOrange,
            ),
            onPressed: () {
              //CommonUtils.logger.d('${_formKey.currentState}');
              if (_formKey.currentState.validate()) {
                CommonUtils.logger.d('form VALID... $_formInput');
              } else {
                CommonUtils.logger.d('form INVALID...  $_formInput');
              }
            },
          ),
        ],
      ),
    );
  }
  /*final GlobalKey<FormBuilderState> _linkEditorFormKey = GlobalKey<FormBuilderState>();
  _linkEditorForm(BuildContext buildContext) {
    return ListView(children: <Widget>[
      FormBuilder(
          key: _linkEditorFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FormBuilderTextField(
                attribute: "content",
                decoration: InputDecoration(labelText: "URL"),
                //initialValue: widget.appIdea != null ? widget.appIdea.content : '',
                validators: [
                  FormBuilderValidators.required(),
                  FormBuilderValidators.max(255),
                ],
              ),
              //FormBuilderChipsInput()
            ],
          )),
      SizedBox(
        width: 20,
        height: 20,
      ),
      MaterialButton(
        color: Colors.white,
        child: Icon(
          Icons.transform_rounded,
          size: 40,
          color: Colors.deepOrange,
        ),
        onPressed: () {
          if (_linkEditorFormKey.currentState.saveAndValidate()) {
            CommonUtils.logger.d(_linkEditorFormKey.currentState.value);

            // TODO: process
          } else {
            CommonUtils.logger.d(_linkEditorFormKey.currentState.value);
            CommonUtils.logger.d('validation failed');
          }
        },
      ),
    ]);
  } */
}
