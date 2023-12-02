import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:proyecto_psicologia/Components/header.dart';
import 'package:proyecto_psicologia/Services/firebase_services.dart';

class PdfCitaView extends StatefulWidget {
  const PdfCitaView({ Key? key }) : super(key: key);

  @override
  _PdfCitaViewState createState() => _PdfCitaViewState();
}

class _PdfCitaViewState extends State<PdfCitaView> {

  final servicios = Get.put(FirebaseServicesS());

  double width = 0;
  double height = 0;

  final pdf = pw.Document();
  PdfImage? logo;
  Uint8List? archivoPDF;
  final format = PdfPageFormat.a4;
  pw.PageOrientation orientation = pw.PageOrientation.portrait;

  @override
  void initState() {
    super.initState();
    initPDF();
  }

  // get screen size
  getSize() {
    setState(() {
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;
    });
  }

  initPDF() async {
    archivoPDF = await generarPDF();
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
                        textos(texto: 'Cita N. 135',),
                        pw.SizedBox(height: 40),
                        textos(texto: '${servicios.fecha.value}\n${servicios.hora.value}',),
                        pw.SizedBox(height: 40),
                        textos(texto: servicios.periodo.value,),
                        pw.SizedBox(height: 40),
                        textos(texto: '${servicios.nombre.value}\n${servicios.numeroControl.value}\n${servicios.carrera.value}',),
                        pw.SizedBox(height: 40),
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

  textos({required String texto}) {
    return pw.Text(
      texto,
      style: const pw.TextStyle(
        fontSize: 16,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    getSize();
    return Obx(
      ()=> Scaffold(
        body: Center(
          child: Column(
            children: [
              const Header(),
              if(!servicios.verificar.value)
                Expanded(
                  child: FutureBuilder(
                    future: initPDF(),
                    builder: (context, snapshot) {
                      return PdfPreview(
                        build: (format) => archivoPDF!,
                        canDebug: false,
                        canChangePageFormat: false,
                        canChangeOrientation: false,
                        allowSharing: false,
                        maxPageWidth: width * 0.6,
                        pdfPreviewPageDecoration: const BoxDecoration(
                          color: Colors.black,
                        ),
                        actions: [
                          IconButton(
                            onPressed: (){
                              Printing.sharePdf(bytes: archivoPDF!, filename: 'cita.pdf');
                            }, 
                            icon: const Icon(Icons.download)
                          ),
                        ],
                      );
                    }
                  ),
                )
              else
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:[
                      CircularProgressIndicator(),
                    ] 
                  ),
                ),
            ],
          )
        ),
      ),
    );
  }
}