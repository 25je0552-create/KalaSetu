class AddItemWizardState {
  final String? capturedPhotoPath;
  final String? recordedAudioPath;
  final String? transcriptionHi;
  final String? transcriptionEn;
  final String productNameHi;
  final String productNameEn;
  final String category;
  final String cluster;
  final List<String> tags;
  final double rawMaterialCost;
  final double laborHours;
  final double suggestedPrice;
  final int stock;
  final bool isSubmitting;

  const AddItemWizardState({
    this.capturedPhotoPath,
    this.recordedAudioPath,
    this.transcriptionHi,
    this.transcriptionEn,
    this.productNameHi = '',
    this.productNameEn = '',
    this.category = 'Clay Pottery',
    this.cluster = 'Gorakhpur Terracotta Cluster',
    this.tags = const ['साड़ी', 'प्राकृतिक रंग', 'महेश्वर'],
    this.rawMaterialCost = 150.0,
    this.laborHours = 3.5,
    this.suggestedPrice = 450.0,
    this.stock = 1,
    this.isSubmitting = false,
  });

  AddItemWizardState copyWith({
    String? capturedPhotoPath,
    String? recordedAudioPath,
    String? transcriptionHi,
    String? transcriptionEn,
    String? productNameHi,
    String? productNameEn,
    String? category,
    String? cluster,
    List<String>? tags,
    double? rawMaterialCost,
    double? laborHours,
    double? suggestedPrice,
    int? stock,
    bool? isSubmitting,
  }) {
    return AddItemWizardState(
      capturedPhotoPath: capturedPhotoPath ?? this.capturedPhotoPath,
      recordedAudioPath: recordedAudioPath ?? this.recordedAudioPath,
      transcriptionHi: transcriptionHi ?? this.transcriptionHi,
      transcriptionEn: transcriptionEn ?? this.transcriptionEn,
      productNameHi: productNameHi ?? this.productNameHi,
      productNameEn: productNameEn ?? this.productNameEn,
      category: category ?? this.category,
      cluster: cluster ?? this.cluster,
      tags: tags ?? this.tags,
      rawMaterialCost: rawMaterialCost ?? this.rawMaterialCost,
      laborHours: laborHours ?? this.laborHours,
      suggestedPrice: suggestedPrice ?? this.suggestedPrice,
      stock: stock ?? this.stock,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
