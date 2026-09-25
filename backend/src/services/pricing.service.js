// Pricing calculation service: calculates fair price recommendations for artisans
const calculateRecommendedPrice = ({ rawMaterialCost, laborHours, hourlyRate = 120, packagingCost = 50, shipping = 100 }) => {
  const baseCost = rawMaterialCost + (laborHours * hourlyRate) + packagingCost;
  const artisanMargin = baseCost * 0.25; // 25% minimum profit guarantee
  return {
    baseCost,
    artisanMargin,
    platformFee: 0, // 0% commission for rural artisans
    suggestedRetailPrice: Math.round(baseCost + artisanMargin + shipping)
  };
};

module.exports = { calculateRecommendedPrice };
