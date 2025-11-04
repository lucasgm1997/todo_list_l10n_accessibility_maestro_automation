import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:maestro_test/main.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  File? _cachedPdfFile;
  bool _isLoading = false;
  String? _errorMessage;

  // URL de exemplo de um PDF público
  static const String pdfUrl =
      'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

  /// Demonstra o uso do flutter_cache_manager
  /// Baixa e cacheia um arquivo PDF da internet
  Future<void> _downloadAndCachePdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Usa o CustomCacheManager para baixar e cachear o PDF
      final fileInfo = await CustomCacheManager.instance.downloadFile(pdfUrl);

      setState(() {
        _cachedPdfFile = fileInfo.file;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao baixar PDF: $e';
        _isLoading = false;
      });
    }
  }

  /// Limpa o cache usando o flutter_cache_manager
  Future<void> _clearCache() async {
    await CustomCacheManager.instance.emptyCache();

    setState(() {
      _cachedPdfFile = null;
      _errorMessage = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache limpo com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer Demo'),
        actions: [
          if (_cachedPdfFile != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _clearCache,
              tooltip: 'Limpar cache',
            ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Baixando e renderizando PDF...'),
                ],
              )
            : _errorMessage != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _downloadAndCachePdf,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  )
                : _cachedPdfFile != null
                    ? Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'PDF cacheado e renderizado com sucesso!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              // Usa o widget PdfViewer do pdf_render_widgets
                              // que automaticamente carrega, renderiza e exibe o PDF
                              child: PdfViewer.openFile(
                                _cachedPdfFile!.path,
                                params: const PdfViewerParams(
                                  padding: 10,
                                  minScale: 0.5,
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Informações:\n'
                              '• flutter_cache_manager: Arquivo baixado e cacheado\n'
                              '• pdf_render: PDF renderizado com widget PdfViewer',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.picture_as_pdf,
                              size: 100,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Demonstração de PDF Cache e Render',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Este exemplo demonstra:\n\n'
                              '1. flutter_cache_manager:\n'
                              '   - Download de arquivos da internet\n'
                              '   - Armazenamento em cache local\n\n'
                              '2. pdf_render:\n'
                              '   - Renderização de páginas PDF\n'
                              '   - Visualização de documentos',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: _downloadAndCachePdf,
                              icon: const Icon(Icons.download),
                              label: const Text('Baixar e Visualizar PDF'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }
}
