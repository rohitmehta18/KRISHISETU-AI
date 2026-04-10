/**
 * Crop Insurance Service
 * Manages crop insurance plans and provides recommendations
 */

// Comprehensive crop insurance database with plans and coverage
const INSURANCE_DATABASE = {
  pmfby: {
    id: 'pmfby',
    name: 'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
    type: 'Government Scheme',
    description: 'Agricultural insurance scheme providing coverage for crop losses due to natural calamities',
    crops: ['rice', 'wheat', 'cotton', 'sugarcane', 'pulses', 'oilseeds', 'vegetables'],
    regions: ['All India'],
    premiumRate: '2%', // Premium as percentage of Sum Insured for kharif
    sumInsured: '₹1,00,000 - ₹3,00,000',
    claimsPeriod: '72 hours - 30 days',
    coverageType: [
      'Prevented Sowing',
      'Crop Loss at Harvest',
      'Mid Season Adversity',
      'Localized Calamity',
    ],
    seasonality: ['Kharif', 'Rabi', 'Summer'],
    processingTime: '30-45 days',
    contact: 'Nearest Agriculture Department or NICS',
    website: 'https://pmfby.gov.in',
  },
  weather_based: {
    id: 'weather_based',
    name: 'Weather Based Crop Insurance (WBCIS)',
    type: 'Government Scheme',
    description: 'Index-based insurance providing quick payout based on weather parameters',
    crops: ['rice', 'wheat', 'cotton', 'sugarcane', 'pulses', 'groundnut', 'soyabean'],
    regions: ['Selected Districts'],
    premiumRate: '3-8%', // Depends on risk level and region
    sumInsured: '₹50,000 - ₹2,00,000',
    claimsPeriod: '10-15 days',
    coverageType: [
      'Excess Rainfall',
      'Deficit Rainfall',
      'High Temperature',
      'Low Temperature',
      'Frost',
    ],
    seasonality: ['Kharif', 'Rabi'],
    processingTime: '10-15 days',
    contact: 'Insurance Company or Authorized Agent',
    website: 'https://wbcis.nic.in',
  },
  private_insurance: {
    id: 'private_insurance',
    name: 'Private Crop Insurance',
    type: 'Private Scheme',
    description: 'Customizable insurance plans from private insurance companies',
    crops: ['rice', 'wheat', 'cotton', 'sugarcane', 'vegetables', 'fruits'],
    regions: ['All India'],
    premiumRate: '5-15%', // Highly variable
    sumInsured: '₹1,00,000 - ₹50,00,000',
    claimsPeriod: '5-30 days',
    coverageType: [
      'Comprehensive Crop Cover',
      'Fire & Perils',
      'Weather Damage',
      'Pest & Disease',
      'Premium Waiver',
    ],
    seasonality: ['Year Round'],
    processingTime: '15-30 days',
    contact: 'Insurance Company Agent',
    website: 'https://www.irdai.gov.in',
  },
  farmer_welfare: {
    id: 'farmer_welfare',
    name: 'State-level Farmer Welfare Schemes',
    type: 'State Scheme',
    description: 'State-specific insurance and welfare schemes for registered farmers',
    crops: ['rice', 'wheat', 'cotton', 'pulses', 'oilseeds', 'vegetables'],
    regions: ['State Specific'],
    premiumRate: '0-3%', // Subsidized by state
    sumInsured: '₹50,000 - ₹2,00,000',
    claimsPeriod: '15-45 days',
    coverageType: [
      'Crop Loss',
      'Livestock Loss',
      'Input Cost Recovery',
      'Income Support',
    ],
    seasonality: ['Kharif', 'Rabi'],
    processingTime: '30-60 days',
    contact: 'State Agriculture Department',
    website: 'State-specific portal',
  },
  micro_insurance: {
    id: 'micro_insurance',
    name: 'Micro Insurance Plan',
    type: 'Affordable Plan',
    description: 'Low-premium insurance for small-holder and marginal farmers',
    crops: ['rice', 'wheat', 'vegetables', 'pulses'],
    regions: ['All India'],
    premiumRate: '₹200-500 per season',
    sumInsured: '₹20,000 - ₹50,000',
    claimsPeriod: '30-45 days',
    coverageType: [
      'Basic Crop Loss',
      'Pest Damage',
      'Weather Events',
    ],
    seasonality: ['Kharif', 'Rabi'],
    processingTime: '20-30 days',
    contact: 'Microfinance Institutions / NGOs',
    website: 'Partner organization',
  },
};

/**
 * Get available insurance plans for a crop
 * @param {string} cropName - Name of the crop
 * @param {string} region - Agricultural region
 * @returns {Promise<Object>} Available insurance plans
 */
async function getAvailableInsurance(cropName, region) {
  const availablePlans = [];
  const cropLower = cropName.toLowerCase();

  // Filter insurance plans available for the crop
  for (const [key, plan] of Object.entries(INSURANCE_DATABASE)) {
    if (plan.crops.includes(cropLower) || plan.crops.includes('All crops')) {
      availablePlans.push({
        id: plan.id,
        name: plan.name,
        type: plan.type,
        description: plan.description,
        premiumRate: plan.premiumRate,
        sumInsured: plan.sumInsured,
        claimsPeriod: plan.claimsPeriod,
        coverage: plan.coverageType,
        seasonality: plan.seasonality,
        processingTime: plan.processingTime,
        contactInfo: {
          contact: plan.contact,
          website: plan.website,
        },
      });
    }
  }

  return {
    crop: cropName,
    region,
    totalPlansAvailable: availablePlans.length,
    plans: availablePlans,
    recommendations: _getInsuranceRecommendations(cropLower),
    importantNotes: _getImportantNotes(),
  };
}

/**
 * Get insurance recommendations based on crop type
 */
function _getInsuranceRecommendations(cropName) {
  const recommendations = {
    rice: [
      'PMFBY is most popular for rice farmers',
      'Weather-based insurance recommended for regions prone to excess rainfall',
      'Register early before sowing season begins',
      'PMFBY premium is often subsidized by government',
    ],
    wheat: [
      'Rabi season insurance critical for wheat',
      'PMFBY covers frost and hail damage',
      'Weather-based insurance useful for drought-prone areas',
      'Coverage begins from sowing date',
    ],
    cotton: [
      'Cotton faces high pest and disease risk',
      'Comprehensive private insurance recommended',
      'PMFBY provides good coverage for cotton',
      'Weather-based insurance helpful for irrigation scheduling',
    ],
    sugarcane: [
      'Long-duration crop needs comprehensive coverage',
      'PMFBY covers till harvest',
      'Monitor for pest infestations throughout season',
      'Weather-based insurance useful for drought periods',
    ],
    vegetables: [
      'Short-duration vegetables need quick-claim insurance',
      'Weather-based insurance recommended',
      'Micro insurance plans available for small holdings',
      'Multiple cropping cycles in a year',
    ],
    default: [
      'Multiple insurance options available',
      'Choose plan based on risk profile and budget',
      'Government schemes offer subsidized premiums',
      'Register before sowing season for best coverage',
    ],
  };

  return recommendations[cropName] || recommendations.default;
}

/**
 * Get important notes for insurance purchase
 */
function _getImportantNotes() {
  return [
    'Insurance must be purchased before sowing begins',
    'Registered farmers get better benefits and subsidies',
    'Government schemes offer premium subsidies (up to 48% for small farmers)',
    'Claims must be filed within specified period of loss occurrence',
    'Documentation required: Land records, farmer ID, crop details',
    'Third-party beneficiaries may need lender\'s consent',
    'Claim settlement takes 30-45 days on average',
    'Annual renewal required for continuous coverage',
    'Some schemes have exclusions (self-inflicted damage, market loss)',
  ];
}

/**
 * Get insurance purchase details
 */
async function getInsurancePurchaseDetails(planId, cropName, area, estimatedYield) {
  const plan = INSURANCE_DATABASE[planId];

  if (!plan) {
    throw new Error('Insurance plan not found');
  }

  // Calculate premium based on area
  const estimatedSumInsured = _calculateSumInsured(cropName, area, estimatedYield);
  const premiumCalculation = _calculatePremium(planId, estimatedSumInsured);

  return {
    plan: plan.name,
    crop: cropName,
    fieldArea: `${area} acres`,
    estimatedYield: estimatedYield,
    estimatedSumInsured: estimatedSumInsured,
    premiumDetails: premiumCalculation,
    requiredDocuments: _getRequiredDocuments(planId),
    nextSteps: _getNextSteps(planId),
    contactInfo: plan.contactInfo,
  };
}

/**
 * Calculate sum insured based on crop and area
 */
function _calculateSumInsured(cropName, area, yield) {
  const pricePerUnit = {
    rice: 2000,
    wheat: 2300,
    cotton: 5500,
    sugarcane: 250,
    pulses: 5000,
    vegetables: 20000,
  };

  const price = pricePerUnit[cropName.toLowerCase()] || 2000;
  const sumInsured = Math.round((area * yield * price) / 100);
  
  return Math.min(Math.max(sumInsured, 50000), 3000000); // Cap between 50k-30L
}

/**
 * Calculate premium amount
 */
function _calculatePremium(planId, sumInsured) {
  const rates = {
    pmfby: { rate: 0.02, government: 0.48 },
    weather_based: { rate: 0.05, government: 0.50 },
    private_insurance: { rate: 0.10, government: 0 },
    farmer_welfare: { rate: 0.02, government: 0.80 },
    micro_insurance: { rate: 0.04, government: 0.60 },
  };

  const rateInfo = rates[planId] || rates.pmfby;
  const farmerPremium = Math.round(sumInsured * rateInfo.rate);
  const govtSubsidy = Math.round(farmerPremium * rateInfo.government);
  const finalFarmerPay = farmerPremium - govtSubsidy;

  return {
    totalPremium: farmerPremium,
    governmentSubsidy: govtSubsidy,
    farmerPayable: finalFarmerPay,
    subsidy_percentage: `${Math.round(rateInfo.government * 100)}%`,
  };
}

/**
 * Get required documents for insurance purchase
 */
function _getRequiredDocuments(planId) {
  const baseDocuments = [
    'Valid Farmer ID / Aadhaar Card',
    'Land ownership certificate / Revenue record (Jamabandi)',
    'Bank account details (for claim transfer)',
  ];

  const planSpecific = {
    pmfby: [...baseDocuments, 'Loan certificate (if availed crop loan)'],
    weather_based: [...baseDocuments, 'GPS coordinates of field'],
    private_insurance: [...baseDocuments, 'Crop history records'],
    farmer_welfare: [...baseDocuments, 'State agricultural registration'],
    micro_insurance: [...baseDocuments, 'Annual income declaration'],
  };

  return planSpecific[planId] || baseDocuments;
}

/**
 * Get next steps for purchasing insurance
 */
function _getNextSteps(planId) {
  const steps = {
    pmfby: [
      '1. Visit nearest Agriculture office or NICS center',
      '2. Fill insurance form with farm details',
      '3. Submit required documents',
      '4. Pay premium (farmer share)',
      '5. Receive insurance certificate',
      '6. Keep safe for claim purposes',
    ],
    weather_based: [
      '1. Contact authorized insurance agent',
      '2. Provide field GPS coordinates',
      '3. Fill insurance proposal form',
      '4. Submit documents and make payment',
      '5. Receive policy document',
      '6. Register for SMS alerts on weather warnings',
    ],
    private_insurance: [
      '1. Contact insurance company agent',
      '2. Get quote based on risk assessment',
      '3. Customize coverage options',
      '4. Submit documents and complete KYC',
      '5. Make premium payment',
      '6. Receive policy document',
    ],
    farmer_welfare: [
      '1. Check eligibility with State Agriculture Department',
      '2. Apply through official portal or office',
      '3. Submit required documents',
      '4. Pay nominal premium if applicable',
      '5. Receive registration confirmation',
      '6. Keep track of application status',
    ],
    micro_insurance: [
      '1. Contact microfinance institution or NGO partner',
      '2. Complete simple registration form',
      '3. Verify field details',
      '4. Make small premium payment',
      '5. Receive policy certificate',
      '6. Claim process simplified and fast',
    ],
  };

  return steps[planId] || steps.pmfby;
}

module.exports = {
  getAvailableInsurance,
  getInsurancePurchaseDetails,
};
