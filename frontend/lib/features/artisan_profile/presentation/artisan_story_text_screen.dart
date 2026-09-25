import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';

class ArtisanStoryTextInputScreen extends ConsumerStatefulWidget {
  const ArtisanStoryTextInputScreen({super.key});

  @override
  ConsumerState<ArtisanStoryTextInputScreen> createState() => _ArtisanStoryTextInputScreenState();
}

class _ArtisanStoryTextInputScreenState extends ConsumerState<ArtisanStoryTextInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'रमेश प्रजापति (Ramesh Prajapati)');
  final _craftController = TextEditingController(text: 'पारंपरिक टेराकोटा शिल्प (Terracotta)');
  final _locationController = TextEditingController(text: 'गोरखपुर (Gorakhpur, Uttar Pradesh)');
  final _storyController = TextEditingController(
    text: 'गोरखपुर के पारंपरिक टेराकोटा शिल्प में 3 पीढ़ियों से हमारा परिवार लगा हुआ है। प्राकृतिक नदी किनारे की चिकनी मिट्टी और हाथ की चाक से हम कलश, हाथी-घोड़े और सजावटी दीप बनाते हैं।',
  );
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _craftController.dispose();
    _locationController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    final isHindi = ref.read(localeProvider) == AppLocale.hindi;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceBright,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline, size: 36, color: AppColors.onSecondaryContainer),
            ),
            const SizedBox(height: 16),
            Text(
              isHindi ? 'कहानी सफलतापूर्वक जमा हुई!' : 'Story Submitted Successfully!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Literata',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isHindi
                  ? 'आपकी शिल्प कथा प्रोफ़ाइल पर अपडेट कर दी गई है और खरीदारों को दिखाई देगी।'
                  : 'Your craft heritage story has been updated on your seller profile.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            TerracottaButton(
              label: isHindi ? 'प्रोफ़ाइल पर लौटें' : 'Back to Profile',
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/artisan/profile');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = ref.watch(localeProvider) == AppLocale.hindi;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer.withValues(alpha: 0.95),
            border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.4), width: 0.8)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                    onPressed: () => context.pop(),
                  ),
                  Text(
                    isHindi ? 'लिखित शिल्प कथा' : 'Written Story Submission',
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  const LanguageTogglePill(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.edit_note, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isHindi ? 'लिखकर अपनी कहानी बताएं' : 'Type Your Artisan Story',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            isHindi
                                ? 'बोलने के स्थान पर विवरण लिखकर जमा करें'
                                : 'Prefer not to speak? Fill in your details manually below.',
                            style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Full Name Field
              Text(
                isHindi ? 'कारीगर का पूरा नाम' : 'Full Artisan Name',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onSurface),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: isHindi ? 'अपना नाम दर्ज करें' : 'Enter your name',
                  filled: true,
                  fillColor: AppColors.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? (isHindi ? 'कृपया नाम दर्ज करें' : 'Name is required') : null,
              ),
              const SizedBox(height: 16),

              // Craft Type Field
              Text(
                isHindi ? 'हस्तशिल्प विधा / क्राफ्ट' : 'Craft Type / Art Form',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onSurface),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _craftController,
                decoration: InputDecoration(
                  hintText: isHindi ? 'उदा. मिट्टी का काम, हथकरघा' : 'e.g. Terracotta, Handloom',
                  filled: true,
                  fillColor: AppColors.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? (isHindi ? 'कृपया शिल्प का प्रकार दर्ज करें' : 'Craft type is required') : null,
              ),
              const SizedBox(height: 16),

              // Location / Village Field
              Text(
                isHindi ? 'गाँव, ज़िला व राज्य' : 'Village, District & State',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onSurface),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: isHindi ? 'उदा. गोरखपुर, उत्तर प्रदेश' : 'e.g. Gorakhpur, Uttar Pradesh',
                  filled: true,
                  fillColor: AppColors.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Heritage Story Text Area
              Text(
                isHindi ? 'आपकी शिल्प कथा व विरासत' : 'Craft Heritage & Personal Story',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onSurface),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _storyController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: isHindi
                      ? 'अपनी कला, परिवार की परंपरा और सामग्री के बारे में विस्तार से लिखें...'
                      : 'Describe your craft traditions, techniques, and legacy...',
                  filled: true,
                  fillColor: AppColors.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                  ),
                ),
                validator: (val) => val == null || val.trim().length < 10
                    ? (isHindi ? 'कृपया कम से कम 10 अक्षरों में कहानी लिखें' : 'Please provide at least 10 characters')
                    : null,
              ),
              const SizedBox(height: 28),

              // Submit Button
              TerracottaButton(
                label: _isSubmitting
                    ? (isHindi ? 'जमा हो रहा है...' : 'Submitting...')
                    : (isHindi ? 'कहानी जमा करें' : 'Submit Story'),
                icon: Icons.check,
                onPressed: _isSubmitting ? () {} : _submitForm,
              ),
              const SizedBox(height: 16),

              // Cancel button
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    isHindi ? 'रद्द करें और बोलकर बताएं' : 'Cancel & Use Voice Instead',
                    style: const TextStyle(color: AppColors.tertiary, fontWeight: FontWeight.bold),
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
