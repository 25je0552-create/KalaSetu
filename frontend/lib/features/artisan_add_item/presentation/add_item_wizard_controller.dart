import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/add_item_wizard_state.dart';
import '../../../core/services/mock_delay.dart';

class AddItemWizardNotifier extends StateNotifier<AddItemWizardState> {
  AddItemWizardNotifier() : super(const AddItemWizardState());

  void setPhoto(String path) {
    state = state.copyWith(capturedPhotoPath: path);
  }

  void setAudio(String path) {
    state = state.copyWith(
      recordedAudioPath: path,
      transcriptionHi: '“मैं महेश्वर में पारंपरिक हाथ की बनी चंदेरी और सूती साड़ियाँ बनाता हूँ। इसमें प्राकृतिक नील और हल्दी के रंगों का प्रयोग किया गया है...”',
      transcriptionEn: '“I craft traditional handwoven Chanderi and cotton sarees in Maheshwar, using authentic natural indigo and turmeric vegetable dyes...”',
      productNameHi: 'हथकरघा महेश्वरी साड़ी',
      productNameEn: 'Handwoven Maheshwari Saree',
      tags: ['साड़ी (Saree)', 'प्राकृतिक रंग (Natural Dyes)', 'महेश्वर (Maheshwar)'],
    );
  }

  void updateDetails({
    String? nameHi,
    String? nameEn,
    String? category,
    double? rawMaterialCost,
    double? laborHours,
    double? suggestedPrice,
    int? stock,
  }) {
    state = state.copyWith(
      productNameHi: nameHi,
      productNameEn: nameEn,
      category: category,
      rawMaterialCost: rawMaterialCost,
      laborHours: laborHours,
      suggestedPrice: suggestedPrice,
      stock: stock,
    );
  }

  Future<bool> publishItem() async {
    state = state.copyWith(isSubmitting: true);
    await MockDelay.wait(600);
    state = state.copyWith(isSubmitting: false);
    return true;
  }

  void reset() {
    state = const AddItemWizardState();
  }
}

final addItemWizardProvider = StateNotifierProvider<AddItemWizardNotifier, AddItemWizardState>((ref) {
  return AddItemWizardNotifier();
});
