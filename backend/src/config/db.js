// DB Connection configuration (MongoDB / Mongoose placeholder)
const connectDB = async () => {
  const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/kalasetu';
  console.log(`[Config] MongoDB connection target: ${uri}`);
  // In future: await mongoose.connect(uri);
};

module.exports = { connectDB };
