/**
 * Pesticide Recommendation Service
 * Recommends appropriate pesticides based on crop type and health issues
 */

// Comprehensive pesticide database with target pests and conditions
const PESTICIDE_DATABASE = {
  neem_oil: {
    name: 'Neem Oil',
    type: 'Organic',
    targets: ['aphids', 'mites', 'whiteflies', 'scale', 'caterpillars'],
    crops: ['rice', 'wheat', 'cotton', 'sugarcane', 'vegetables'],
    concentration: '3-5%',
    sprayInterval: '7-14 days',
    withholding: '3 days',
    safety: 'Low toxicity, eco-friendly',
    timing: 'Early morning or evening',
  },
  carbofuran: {
    name: 'Carbofuran',
    type: 'Systemic Insecticide',
    targets: ['stem borers', 'leaf folders', 'plant hoppers', 'bugs'],
    crops: ['rice', 'sugarcane'],
    concentration: '50g per 10L',
    sprayInterval: '10-15 days',
    withholding: '7 days',
    safety: 'Moderate toxicity, use with caution',
    timing: 'Morning spray',
  },
  deltamethrin: {
    name: 'Deltamethrin',
    type: 'Synthetic Pyrethroid',
    targets: ['bollworms', 'leaf rollers', 'cutworms', 'thrips'],
    crops: ['cotton', 'vegetables', 'pulses'],
    concentration: '2.8% EC',
    sprayInterval: '10-15 days',
    withholding: '7 days',
    safety: 'Moderate toxicity, not for honey bees',
    timing: 'Early morning',
  },
  copper_fungicide: {
    name: 'Copper Fungicide',
    type: 'Fungicide',
    targets: ['leaf spots', 'blast', 'blight', 'powdery mildew'],
    crops: ['rice', 'vegetables', 'fruits'],
    concentration: '1% Bordeaux mixture',
    sprayInterval: '10-15 days',
    withholding: '5 days',
    safety: 'Low toxicity, traditional agent',
    timing: 'Early morning',
  },
  sulfur_dust: {
    name: 'Sulfur Dust',
    type: 'Fungicide/Acaricide',
    targets: ['powdery mildew', 'rust', 'mites', 'scale'],
    crops: ['fruits', 'vegetables', 'grapes'],
    concentration: '4-6 kg per hectare',
    sprayInterval: '7-14 days',
    withholding: '3 days',
    safety: 'Very low toxicity, organic approved',
    timing: 'Morning or evening (not noon)',
  },
  metalaxyl: {
    name: 'Metalaxyl',
    type: 'Systemic Fungicide',
    targets: ['late blight', 'damping off', 'downy mildew'],
    crops: ['potato', 'vegetables', 'tobacco'],
    concentration: '68% WP',
    sprayInterval: '10-14 days',
    withholding: '7 days',
    safety: 'Moderate toxicity',
    timing: 'Preventive spray',
  },
  triazophos: {
    name: 'Triazophos',
    type: 'Organophosphate Acaricide',
    targets: ['red spider mites', 'scale insects', 'plant hoppers'],
    crops: ['cotton', 'rice', 'sugarcane'],
    concentration: '40% EC',
    sprayInterval: '15-20 days',
    withholding: '10 days',
    safety: 'Moderate toxicity, harmful to bees',
    timing: 'Evening spray',
  },
};

/**
 * Get pesticide recommendations based on crop and health issues
 * @param {string} cropName - Name of the crop
 * @param {Object} healthMetrics - Health analysis metrics
 * @param {string} region - Agricultural region
 * @returns {Promise<Object>} Pesticide recommendations
 */
async function getPesticideRecommendations(cropName, healthMetrics, region) {
  const recommendations = [];
  const { metrics, overall } = healthMetrics;

  // Detect pest/disease risk based on health metrics
  const riskFactors = [];

  if (metrics.moisture.score < 40) {
    riskFactors.push('dry_stress');
  }
  if (metrics.humidity.score < 40) {
    riskFactors.push('mites_risk');
    riskFactors.push('scale_insects');
  }
  if (metrics.humidity.score > 85) {
    riskFactors.push('fungal_diseases');
    riskFactors.push('powdery_mildew');
  }
  if (metrics.ph.score < 50) {
    riskFactors.push('poor_plant_health');
  }
  if (overall < 50) {
    riskFactors.push('general_infestation_risk');
  }

  // Map crop names to pesticide recommendations
  const cropPesticides = _getCropPesticides(cropName.toLowerCase());
  
  // Recommend pesticides based on detected risks
  for (const pestKey of cropPesticides) {
    const pesticide = PESTICIDE_DATABASE[pestKey];
    if (pesticide) {
      recommendations.push({
        pesticide: pesticide.name,
        type: pesticide.type,
        reason: _generateReason(pestKey, riskFactors, healthMetrics),
        concentration: pesticide.concentration,
        sprayInterval: pesticide.sprayInterval,
        withholding: pesticide.withholding,
        safety: pesticide.safety,
        sprayTiming: pesticide.timing,
        riskLevel: overall < 50 ? 'high' : overall < 75 ? 'medium' : 'low',
      });
    }
  }

  return {
    crop: cropName,
    region,
    overallHealthScore: overall,
    detectedRisks: riskFactors,
    recommendations,
    preventiveMeasures: _getPreventiveMeasures(riskFactors, healthMetrics),
    bestPractices: _getBestPractices(cropName.toLowerCase()),
  };
}

/**
 * Get recommended pesticides for a specific crop
 */
function _getCropPesticides(cropName) {
  const cropPesticideMap = {
    rice: ['neem_oil', 'carbofuran', 'copper_fungicide', 'sulfur_dust'],
    wheat: ['neem_oil', 'sulfur_dust', 'metalaxyl'],
    cotton: ['deltamethrin', 'neem_oil', 'triazophos'],
    sugarcane: ['carbofuran', 'neem_oil', 'triazophos'],
    potato: ['metalaxyl', 'neem_oil', 'copper_fungicide'],
    vegetables: ['neem_oil', 'deltamethrin', 'copper_fungicide', 'sulfur_dust'],
    fruits: ['neem_oil', 'copper_fungicide', 'sulfur_dust'],
    pulses: ['deltamethrin', 'neem_oil'],
    default: ['neem_oil', 'copper_fungicide', 'sulfur_dust'],
  };

  return cropPesticideMap[cropName] || cropPesticideMap.default;
}

/**
 * Generate reason for pesticide recommendation
 */
function _generateReason(pestKey, riskFactors, healthMetrics) {
  const reasonMap = {
    neem_oil: 'Organic broad-spectrum pesticide effective against multiple insects and mites',
    carbofuran: 'Highly effective against rice stem borers and leaf folders',
    deltamethrin: 'Synthetic pyrethroid for cotton bollworms and leaf-feeding insects',
    copper_fungicide: 'Traditional fungicide for fungal diseases and leaf spots',
    sulfur_dust: 'Organic acaricide for mites and powdery mildew',
    metalaxyl: 'Systemic fungicide for late blight and downy mildew',
    triazophos: 'Effective against red spider mites in cotton',
  };

  return reasonMap[pestKey] || 'Recommended for your crop';
}

/**
 * Get preventive measures based on detected risks
 */
function _getPreventiveMeasures(riskFactors, healthMetrics) {
  const measures = [];

  if (riskFactors.includes('mites_risk') || riskFactors.includes('scale_insects')) {
    measures.push('Maintain adequate humidity (60-75%) through irrigation');
    measures.push('Improve air circulation to reduce mite population');
  }
  if (riskFactors.includes('fungal_diseases') || riskFactors.includes('powdery_mildew')) {
    measures.push('Reduce waterlogging and improve soil drainage');
    measures.push('Avoid overhead watering; use drip irrigation');
  }
  if (riskFactors.includes('dry_stress')) {
    measures.push('Ensure consistent irrigation schedule');
    measures.push('Mulch soil to retain moisture');
  }
  if (riskFactors.includes('poor_plant_health')) {
    measures.push('Adjust soil pH through lime or sulfur application');
    measures.push('Apply balanced NPK fertilizer');
  }

  return measures.length > 0 ? measures : ['Maintain regular monitoring routine', 'Practice crop rotation'];
}

/**
 * Get best practices for the crop
 */
function _getBestPractices(cropName) {
  const practices = {
    rice: [
      'Monitor fields weekly for pests',
      'Use light traps to monitor night-flying insects',
      'Apply pesticides in early morning',
      'Maintain 5cm water level during vegetation',
    ],
    cotton: [
      'Scout fields 3 times weekly',
      'Use pheromone traps for bollworms',
      'Avoid unnecessary sprays to preserve natural enemies',
      'Follow integrated pest management (IPM)',
    ],
    wheat: [
      'Monitor for leaf spots and rust',
      'Remove infected plant parts',
      'Maintain field hygiene',
      'Apply fungicides at booting stage for disease control',
    ],
    default: [
      'Follow integrated pest management (IPM) principles',
      'Use pesticides only when pest threshold is reached',
      'Rotate different pesticide classes to prevent resistance',
      'Always wear protective equipment when spraying',
      'Follow withholding period before harvest',
    ],
  };

  return practices[cropName] || practices.default;
}

module.exports = {
  getPesticideRecommendations,
};
