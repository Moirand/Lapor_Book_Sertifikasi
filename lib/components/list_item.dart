import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:lapor_book_sertifikasi/components/styles.dart';
import 'package:lapor_book_sertifikasi/components/vars.dart';
import 'package:lapor_book_sertifikasi/models/akun.dart';
import 'package:lapor_book_sertifikasi/models/laporan.dart';

class ListItem extends StatefulWidget {
  final Akun akun;
  final bool isLaporanku;
  final Laporan laporan;
  const ListItem(
      {super.key,
      required this.laporan,
      required this.akun,
      required this.isLaporanku});

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;

  void deleteLaporan() async {
    try {
      await _firestore.collection('laporan').doc(widget.laporan.docId).delete();

      if (widget.laporan.foto != '') {
        await _storage.refFromURL(widget.laporan.foto!).delete();
      }
      if (context.mounted) Navigator.popAndPushNamed(context, '/dashboard');
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 2),
          borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/detail', arguments: {
            'laporan': widget.laporan,
            'akun': widget.akun,
          });
        },
        onLongPress: () {
          if (widget.isLaporanku) {
            showDialog(
                context: context,
                builder: (BuildContext) {
                  return AlertDialog(
                    title: Text('Delete ${widget.laporan.judul}?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteLaporan();
                        },
                        child: const Text('Hapus'),
                      ),
                    ],
                  );
                });
          }
        },
        child: Column(
          children: [
            widget.laporan.foto != ''
                ? Image.network(
                    widget.laporan.foto!,
                    width: 130,
                    height: 130,
                  )
                : Image.asset(
                    'assets/istock-default.jpg',
                    width: 130,
                    height: 130,
                  ),
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                  border: Border.symmetric(horizontal: BorderSide(width: 2))),
              child: Text(
                widget.laporan.judul,
                style: headerStyle(level: 4),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        color: widget.laporan.status == dataStatus[0]
                            ? warnaStatus[0]
                            : widget.laporan.status == dataStatus[1]
                                ? warnaStatus[1]
                                : warnaStatus[2],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                        ),
                        border: const Border.symmetric(
                            vertical: BorderSide(width: 1))),
                    alignment: Alignment.center,
                    child: Text(
                      widget.laporan.status,
                      style: headerStyle(level: 5, dark: false),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(5)),
                        border: const Border.symmetric(
                            vertical: BorderSide(width: 1))),
                    alignment: Alignment.center,
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(widget.laporan.tgl_lapor),
                      style: headerStyle(level: 5, dark: false),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}