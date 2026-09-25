// Mongoose Schema blueprint for Product
const ProductSchema = {
  name: { type: String, required: true },
  descriptionHi: { type: String },
  descriptionEn: { type: String },
  artisanId: { type: String, required: true },
  price: { type: Number, required: true },
  currency: { type: String, default: 'INR' },
  category: { type: String, required: true },
  cluster: { type: String },
  materials: [String],
  images: [String],
  stockQuantity: { type: Number, default: 1 },
  isGIProduct: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now }
};

module.exports = { ProductSchema };
