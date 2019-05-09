import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_turtle_v2/models/doktorModel.dart';
import 'package:fast_turtle_v2/models/hospitalModel.dart';
import 'package:fast_turtle_v2/models/sectionModel.dart';
import 'package:fast_turtle_v2/screens/showHospitals.dart';
import 'package:fast_turtle_v2/screens/showSections.dart';
import 'package:flutter/material.dart';
import 'package:fast_turtle_v2/mixins/validation_mixin.dart';

class AddDoctor extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddDoctorState();
  }
}

class AddDoctorState extends State with ValidationMixin {
  final doktor = Doktor();
  Hospital hastane = Hospital();
  Section section = Section();
  bool hastaneSecildiMi = false;
  bool bolumSecildiMi = false;
  String textMessage = " ";
  double goruntu = 0.0;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Doktor Ekle",
            style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 20.0, left: 9.0, right: 9.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      _kimlikNoField(),
                      _passwordField(),
                      _nameField(),
                      _surnameField(),
                      SizedBox(
                        height: 13.0,
                      ),
                      RaisedButton(
                        child: Text("Hastane Seçmek İçin Tıkla"),
                        onPressed: () {
                          bolumSecildiMi = false;
                          hospitalNavigator(BuildHospitalList());
                        },
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      _showSelectedHospital(hastaneSecildiMi),
                      SizedBox(
                        height: 16.0,
                      ),
                      RaisedButton(
                        child: Text("Bölüm Seçmek İçin Tıkla"),
                        onPressed: () {
                          if (hastaneSecildiMi) {
                            sectionNavigator(BuildSectionList(hastane));
                          } else {
                            alrtHospital(
                                context, "Hastane seçmeden bölüm seçemezsiniz");
                          }
                        },
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      _showSelectedSection(bolumSecildiMi),
                      SizedBox(
                        height: 16.0,
                      ),
                      _buildDoneButton(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget _kimlikNoField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "T.C. Kimlik Numarası:",
          labelStyle: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold)),
      validator: validateTCNo,
      keyboardType: TextInputType.number,
      onSaved: (String value) {
        doktor.kimlikNo = value;
      },
    );
  }

  Widget _passwordField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Şifre:",
          labelStyle: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold)),
      obscureText: true,
      onSaved: (String value) {
        doktor.sifre = value;
      },
    );
  }

  Widget _nameField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Ad:",
          labelStyle: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold)),
      validator: validateFirstName,
      onSaved: (String value) {
        doktor.adi = value;
      },
    );
  }

  Widget _surnameField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Soyad:",
          labelStyle: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold)),
      validator: validateLastName,
      onSaved: (String value) {
        doktor.soyadi = value;
      },
    );
  }

  void alrtHospital(BuildContext context, String message) {
    var alertDoctor = AlertDialog(
      title: Text("Uyarı!"),
      content: Text(message),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDoctor;
        });
  }

  void hospitalNavigator(dynamic page) async {
    hastane = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => page));

    if (hastane == null) {
      hastaneSecildiMi = false;
    } else {
      hastaneSecildiMi = true;
    }
  }

  void sectionNavigator(dynamic page) async {
    section = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => page));

    if (section == null) {
      bolumSecildiMi = false;
    } else {
      bolumSecildiMi = true;
    }
  }

  _showSelectedHospital(bool secildiMi) {
    String textMessage = " ";
    if (secildiMi) {
      setState(() {
        textMessage = this.hastane.hastaneAdi.toString();
      });
      goruntu = 1.0;
    } else {
      goruntu = 0.0;
    }

    return Container(
        decoration: BoxDecoration(),
        child: Row(
          children: <Widget>[
            Text(
              "Seçilen Hastane : ",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            Opacity(
                opacity: goruntu,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    textMessage,
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ))
          ],
        ));
  }

  _showSelectedSection(bool secildiMi) {
    double goruntu = 0.0;

    if (secildiMi) {
      setState(() {
        textMessage = this.section.bolumAdi.toString();
      });
      goruntu = 1.0;
    } else {
      goruntu = 0.0;
    }

    return Container(
        decoration: BoxDecoration(),
        child: Row(
          children: <Widget>[
            Text(
              "Seçilen Bölüm : ",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            Opacity(
                opacity: goruntu,
                child: Container(
                    alignment: Alignment.center,
                    child: _buildTextMessage(textMessage)))
          ],
        ));
  }

  _buildTextMessage(String gelenText) {
    return Text(
      textMessage,
      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
    );
  }

  _buildDoneButton() {
    return Container(
      padding: EdgeInsets.only(top: 17.0),
      child: RaisedButton(
        child: Text(
          "Tamamla",
          style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          if (hastaneSecildiMi && bolumSecildiMi) {
            if (formKey.currentState.validate()) {
              formKey.currentState.save();
              saveDoctor(this.doktor, this.section, this.hastane);
            }
          } else {
            alrtHospital(context,
                "İşlemi tamamlamak için gerekli alanları doldurmanız gerekmektedir");
          }
        },
      ),
    );
  }

  void saveDoctor(Doktor dr, Section bolumu, Hospital hastanesi) {
    Firestore.instance.collection('tblDoktor').document().setData({
      'kimlikNo': dr.kimlikNo,
      'ad': dr.adi,
      'soyad': dr.soyadi,
      'sifre': dr.sifre,
      'bolumId': bolumu.bolumId,
      'hastaneId': hastanesi.hastaneId
    });
  }
}
