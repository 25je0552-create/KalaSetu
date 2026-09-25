// Mongoose Schema blueprint for Artisan
const ArtisanSchema = {
  name: { type: String, required: true },
  phone: { type: String, required: true },
  craftType: { type: String, required: true },
  village: { type: String },
  district: { type: String },
  state: { type: String },
  isCertified: { type: Boolean, default: false },
  artisanCardNumber: { type: String },
  voiceBioUrl: { type: String },
  totalEarnings: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now }
};

module.exports = { ArtisanSchema };
