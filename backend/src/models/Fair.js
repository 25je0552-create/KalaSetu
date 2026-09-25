// Mongoose Schema blueprint for Craft Fair
const FairSchema = {
  titleHi: { type: String, required: true },
  titleEn: { type: String, required: true },
  venue: { type: String, required: true },
  city: { type: String, required: true },
  startDate: { type: Date, required: true },
  endDate: { type: Date, required: true },
  applicationDeadline: { type: Date, required: true },
  subsidyPercent: { type: Number, default: 0 },
  isGovtSponsored: { type: Boolean, default: true },
  expectedVisitors: { type: String },
  createdAt: { type: Date, default: Date.now }
};

module.exports = { FairSchema };
