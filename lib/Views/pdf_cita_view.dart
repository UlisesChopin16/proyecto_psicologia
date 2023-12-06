import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:proyecto_psicologia/Components/boton_psicologia.dart';
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

  

  @override
  void initState() {
    super.initState();
  }

  // get screen size
  getSize() {
    setState(() {
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;
    });
  }

  
  @override
  Widget build(BuildContext context) {
    getSize();
    return Obx(
      ()=> Scaffold(
        backgroundColor: Colors.grey[400],
        body: Center(
          child: Column(
            children: [
              const Header(),
              if(servicios.vistaPsicologo.value)
                filaBotones(),
              if(!servicios.verificar.value)
                Expanded(
                  child: PdfPreview(
                    build: (format) => servicios.pdf.value,
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
                          Printing.sharePdf(bytes: servicios.pdf.value, filename: 'cita.pdf');
                        }, 
                        icon: const Icon(Icons.download)
                      ),
                    ],
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

  filaBotones(){
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: SizedBox(
          width: 800,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BotonPsicologia(
                iconData: Icons.arrow_back_rounded,
                text: 'Volver',
                onTap: (){
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}