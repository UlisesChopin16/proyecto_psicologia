import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:proyecto_psicologia/Services/firebase_services.dart';
class GenerarPdfServices {

  final servicios = Get.put(FirebaseServicesS());

  final pdf = pw.Document();
  PdfImage? logo;
  
  final format = PdfPageFormat.a4;
  pw.PageOrientation orientation = pw.PageOrientation.portrait;

  Future<void> initPDF() async {
    servicios.pdf.value = await generarPDF();
  }

  generarPDF () async {

    final img = await rootBundle.load('assets/images/logop.png');
    final imageBytes = img.buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        orientation: orientation,
        margin:const pw.EdgeInsets.all(10),
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(top: 20.0),
            child: pw.SizedBox(
              height: 450,
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.SizedBox(width: 40),
                  pw.Expanded(
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(height: 60),
                        textos(texto: 'Fecha de la cita:',fontWeight: pw.FontWeight.bold),
                        textos(texto: servicios.fecha.value,),
                        pw.SizedBox(height: 10),
                        textos(texto: 'Hora de la cita:',fontWeight: pw.FontWeight.bold),
                        textos(texto: servicios.hora.value),
                        pw.SizedBox(height: 10),
                        textos(texto: 'Periodo de ingreso:',fontWeight: pw.FontWeight.bold),
                        textos(texto: servicios.periodo.value),
                        pw.SizedBox(height: 40),
                        textos(texto: 'Nombre:',fontWeight: pw.FontWeight.bold),
                        textos(texto: servicios.nombre.value),
                        pw.SizedBox(height: 10),
                        textos(texto: 'Número de control:',fontWeight: pw.FontWeight.bold),
                        textos(texto: servicios.numeroControl.value),
                        pw.SizedBox(height: 10),
                        textos(texto: 'Carrera:',fontWeight: pw.FontWeight.bold),
                        textos(texto: servicios.carrera.value),
                        pw.SizedBox(height: 40),
                        textos(texto: 'Teléfono:',fontWeight: pw.FontWeight.bold),
                        textos(texto: servicios.telefono.value),
                        pw.SizedBox(height: 40),
                      ]
                    )
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 30.0),
                    child: pw.Image(
                      width: 150,
                      height: 150,
                      pw.MemoryImage(
                        imageBytes
                      )
                    ),
                  ),
                ]
              )
            ),
          );
        }
      )
    );

    return pdf.save();

  }

  textos({required String texto, pw.FontWeight? fontWeight}) {
    return pw.Text(
      texto,
      style: pw.TextStyle(
        fontSize: 16,
        fontWeight: fontWeight,
      )
    );
  }

}