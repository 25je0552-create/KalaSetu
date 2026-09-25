// Mongoose Schema blueprint for User
const UserSchema = {
  supabaseUid: { type: String, required: true, unique: true },
  phone: { type: String },
  email: { type: String },
  displayName: { type: String },
  role: { type: String, enum: ['artisan', 'customer', 'b2b'], default: 'customer' },
  preferredLanguage: { type: String, enum: ['hi', 'en'], default: 'hi' },
  createdAt: { type: Date, default: Date.now }
};

module.exports = { UserSchema };
