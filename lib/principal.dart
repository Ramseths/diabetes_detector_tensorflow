import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf;

class Principal extends StatefulWidget {
  Principal({Key? key}) : super(key: key);

  @override
  State<Principal> createState() => _PrincipalState();
}


class _PrincipalState extends State<Principal> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseCustomModel? model;
  tf.Interpreter? interpreter;
  final TextEditingController _pregnancies = TextEditingController();
  final TextEditingController _glucose = TextEditingController();
  final TextEditingController _bloodPressure = TextEditingController();
  final TextEditingController _skin = TextEditingController();
  final TextEditingController _bmi = TextEditingController();
  final TextEditingController _insulin = TextEditingController();
  final TextEditingController _pedigreeFunction = TextEditingController();
  final TextEditingController _age = TextEditingController();
  double _pregnanciesValue = 0;
  double _glucoseValue = 0;
  double _bloodPressureValue = 0;
  double _skinValue = 0;
  double _bmiValue = 0;
  double _insulinValue = 0;
  double _pedigreeFunctionValue = 0;
  double _ageValue = 0;

  @override
  void initState() {
    super.initState();
    initWithLocalModel();
  }

  Future signIn() async{
    try{
      UserCredential? result = await _auth.signInAnonymously();
      User? user = result.user;
      return user;
    }catch(e){
      print(e);
      return null;
    }
  }

  initWithLocalModel() async{
    final _model = await FirebaseModelDownloader.instance.getModel('my_model', FirebaseModelDownloadType.localModelUpdateInBackground);
    setState(() {
      model = _model;
    });
    initInterpreter();
  }

  initInterpreter(){
    interpreter = tf.Interpreter.fromFile(model!.file);
  }

  getPrediction(input){
    var output = List.filled(1, 0).reshape([1,1]);
    interpreter!.run(input, output);
    return output[0][0].round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predictor'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _input(_pregnancies, 'Número de embarazos'),
              _input(_glucose, 'Glucosa'),
              _input(_bloodPressure, 'Presión Arterial'),
              _input(_skin, 'Pliegue cutáneo'),
              _input(_insulin, 'Insulina'),
              _input(_bmi, 'índice de Masa'),
              _input(_pedigreeFunction, 'Función de Pedigree'),
              _input(_age, 'Edad'),
              TextButton(
                child: const Text('Obtener predicción'),
                onPressed: () {
                  var text = "No se detectó diabetes";
                  _pregnanciesValue = double.parse(_pregnancies.text);
                  _glucoseValue = double.parse(_glucose.text);
                  _bloodPressureValue = double.parse(_bloodPressure.text);
                  _skinValue = double.parse(_skin.text);
                  _insulinValue = double.parse(_insulin.text);
                  _bmiValue = double.parse(_bmi.text);
                  _pedigreeFunctionValue = double.parse(_pedigreeFunction.text);
                  _ageValue = double.parse(_age.text);
                  var pred = getPrediction([_pregnanciesValue, _glucoseValue, _bloodPressureValue,
                  _skinValue, _insulinValue, _bmiValue, _pedigreeFunctionValue, _ageValue]);
                  if(pred!=0){
                    text = 'Se ha detectado diabetes';
                  }
                  AwesomeDialog(context: context,
                  dialogType: DialogType.SUCCES,
                  animType: AnimType.BOTTOMSLIDE,
                  title: text,
                  desc: 'Este ha sido tu resultado',
                  btnOkOnPress: (){}).show();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller, String name){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
          labelText: name,
          hintText: 'Ingrese un valor...',
          icon: const Icon(Icons.dashboard)
        ),
      ),
    );
  }
}