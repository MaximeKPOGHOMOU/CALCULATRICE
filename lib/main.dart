import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const Calculatrice());
}

class Calculatrice extends StatelessWidget {
  const Calculatrice({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Calculatrice",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: SimpleCalculatrice(),
    );
  }
}

class SimpleCalculatrice extends StatefulWidget {
  const SimpleCalculatrice({super.key});

  @override
  State<SimpleCalculatrice> createState() => _SimpleCalculatriceState();
}

class _SimpleCalculatriceState extends State<SimpleCalculatrice> {
  String equation = '0';
  String resultat = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: textAvecStyle("Calculatrice", 1.5),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
            margin: const EdgeInsets.only(left: 0, top: 20, right: 0, bottom: 0),
            child: Text(
              equation,
              style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.fromLTRB(20, 30, 10, 0),
            child: Text(
              resultat,
              style: const TextStyle(
                  fontSize: 35, color: Colors.grey, fontWeight: FontWeight.w300),
            ),
          ),
          const Expanded(child: Divider(color: Colors.white,)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: Colors.black12,
                width: MediaQuery.of(context).size.width,
                child: Table(
                  children: [
                    TableRow(
                      children: [
                        calculatriceButton('AC', Colors.blue, Colors.white),
                        calculatriceButton('√', Colors.blue, Colors.white),
                        calculatriceButton('%', Colors.blue, Colors.white),
                        calculatriceButton('÷', Colors.blue, Colors.white),
                      ],
                    ),
                    TableRow(
                      children: [
                        calculatriceButton('7', Colors.black, Colors.white),
                        calculatriceButton('8', Colors.black, Colors.white),
                        calculatriceButton('9', Colors.black, Colors.white),
                        calculatriceButton('x', Colors.blue, Colors.white),
                      ],
                    ),
                    TableRow(
                      children: [
                        calculatriceButton('4', Colors.black, Colors.white),
                        calculatriceButton('5', Colors.black, Colors.white),
                        calculatriceButton('6', Colors.black, Colors.white),
                        calculatriceButton('-', Colors.blue, Colors.white),
                      ],
                    ),
                    TableRow(
                      children: [
                        calculatriceButton('1', Colors.black, Colors.white),
                        calculatriceButton('2', Colors.black, Colors.white),
                        calculatriceButton('3', Colors.black, Colors.white),
                        calculatriceButton('+', Colors.blue, Colors.white),
                      ],
                    ),
                    TableRow(
                      children: [
                        calculatriceButton('0', Colors.black, Colors.white),
                        calculatriceButton(',', Colors.black, Colors.white),
                        calculatriceButton('⌫', Colors.blue, Colors.white),
                        calculatriceButton('=', Colors.white, Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Text textAvecStyle(String data, double scale) {
    return Text(
      data,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontStyle: FontStyle.normal,
      ),
      textScaleFactor: scale,
    );
  }
  Widget calculatriceButton(String textBouton, Color couleurText, Color couleurBouton) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      margin: const EdgeInsets.all(4), // Ajout du margin pour arrondir un peu les boutons
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8), // Bordure arrondie pour les boutons
        color: couleurBouton,
      ),
      child: MaterialButton(
        onPressed: () => ButtonOnPressed(textBouton),
        padding: const EdgeInsets.all(16),
        child: Text(
          textBouton,
          style: TextStyle(color: couleurText, fontSize: 30, fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
  void ButtonOnPressed(String textButton) {
    setState(() {
      if (textButton == 'AC') {
        resetEquation();
      }else if((equation == '0' || equation == '√') &&  (textButton == '+' || textButton == 'x' || textButton == '%' || textButton == '÷' || textButton == '-' || textButton == ',')){
          return;
      } else if (textButton == '⌫') {
        if (equation.isNotEmpty) {
          equation = equation.substring(0, equation.length - 1);
          if (equation.isEmpty) {
            resetEquation();
          }
          //===== Mettre à jour le résultat après l'effacement=======
          if (isCompleteExpression(equation)) {
            calculateResult();
          } else {
            resultat = '';
          }
        }
      } else if (textButton == '=') {
        calculateResultAndUpdateEquation();
      } else {
        if (equation == '0') {
          equation = textButton;
          resultat = '';
        } else {
          if (isOperator(equation[equation.length - 1])) {
            // =====Si le nouveau caractère est également un opérateur, remplacer l'ancien=====
            if (isOperator(textButton)) {
              equation = equation.substring(0, equation.length - 1) + textButton;
              return;
            }
          }
          equation += textButton;
        }
        if (textButton == '√') {
          // Handle sqrt symbol
          calculateSqrt();
        } else if (isCompleteExpression(equation)) {
          calculateResult();
        }
      }
    });
  }

  void calculateSqrt() {
    // Automatically evaluate the sqrt expression if the last part of the equation is a valid sqrt expression
    String tempEq = formatEquation(equation);
    if (RegExp(r'√(\d+(\.\d+)?)$').hasMatch(tempEq)) {
      calculateResult();
    }
  }

  void calculateResultAndUpdateEquation() {
    String tempEq = formatEquation(equation);
    try {
      Parser p = Parser();
      Expression exp = p.parse(tempEq);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      String tempResultat;
      if(eval % 1 == 0){
        tempResultat = eval.toInt().toString();
      }else{
        tempResultat = eval.toString();
      }
      resultat = tempResultat.replaceAll('.', ',');
      equation = resultat;
      resultat = '';
    } catch (e) {
      print( e);
    }
  }
  void calculateResult() {
    String tempEq = formatEquation(equation);
    try {
      Parser p = Parser();
      Expression exp = p.parse(tempEq);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      String tempResultat;
      if(eval % 1 == 0){
        tempResultat = eval.toInt().toString();
      }else{
        tempResultat = eval.toString();
      }
      resultat = tempResultat.replaceAll('.', ',');
    } catch (e) {
      print(e);
    }
  }

  String formatEquation(String eq) {
    // Convert sqrt symbol and wrap the number in parentheses
    eq = eq.replaceAllMapped(RegExp(r'(\d*)√(\d+(\.\d+)?)'), (match) {
      String? coefficient = match[1];
      String? number = match[2];
      if (coefficient!.isEmpty) {
        return 'sqrt($number)';
      } else {
        return '$coefficient*sqrt($number)';
      }
    });
    return eq.replaceAll('÷', '/')
        .replaceAll('x', '*')
        .replaceAll(',', '.');
  }

  bool isCompleteExpression(String eq) {
    // Regex to check if the equation contains at least one operator with numbers on both sides or a sqrt expression
    RegExp regex = RegExp(r'\d+[\+\-x÷%]\d+|√(\d+(\.\d+)?)$');
    return regex.hasMatch(eq) && !isOperator(eq[eq.length - 1]);
  }

  bool isOperator(String input) {
    return input == '+' || input == '-' || input == 'x' || input == '÷' || input == '%' || input == '√' || input == ',';
  }
  void resetEquation(){
    setState(() {
      equation = '0';
      resultat = '';
    });
  }
}




