// Mongoose Schema blueprint for Order
const OrderSchema = {
  orderNumber: { type: String, required: true },
  customerId: { type: String, required: true },
  artisanId: { type: String, required: true },
  items: [{
    productId: String,
    name: String,
    price: Number,
    quantity: Number
  }],
  totalAmount: { type: Number, required: true },
  status: { 
    type: String, 
    enum: ['received', 'in_progress', 'dispatched', 'delivered', 'cancelled'],
    default: 'received'
  },
  shippingAddress: Object,
  createdAt: { type: Date, default: Date.now }
};

module.exports = { OrderSchema };
