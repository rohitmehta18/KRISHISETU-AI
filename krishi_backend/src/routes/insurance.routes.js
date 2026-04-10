const express = require('express');
const { getAvailableInsurance, getInsurancePurchaseDetails } = require('../services/insurance.service');
const router = express.Router();

/**
 * GET /api/insurance/plans
 * Get available insurance plans for a crop
 * Query params: crop (required), region (optional)
 */
router.get('/plans', async (req, res) => {
  try {
    const { crop, region = 'Default Region' } = req.query;

    if (!crop) {
      return res.status(400).json({
        error: 'Crop parameter is required',
        example: '/api/insurance/plans?crop=rice&region=Punjab',
      });
    }

    const insurancePlans = await getAvailableInsurance(crop, region);
    res.json(insurancePlans);
  } catch (error) {
    res.status(500).json({
      error: error.message || 'Failed to fetch insurance plans',
    });
  }
});

/**
 * POST /api/insurance/calculate
 * Calculate insurance premium and get purchase details
 * Body params: planId (required), crop (required), area (required), estimatedYield (required)
 */
router.post('/calculate', async (req, res) => {
  try {
    const { planId, crop, area, estimatedYield } = req.body;

    if (!planId || !crop || !area || !estimatedYield) {
      return res.status(400).json({
        error: 'Missing required fields: planId, crop, area, estimatedYield',
        example: {
          planId: 'pmfby',
          crop: 'rice',
          area: 2.5,
          estimatedYield: 50,
        },
      });
    }

    const purchaseDetails = await getInsurancePurchaseDetails(
      planId,
      crop,
      area,
      estimatedYield
    );

    res.json(purchaseDetails);
  } catch (error) {
    res.status(500).json({
      error: error.message || 'Failed to calculate insurance premium',
    });
  }
});

/**
 * POST /api/insurance/purchase
 * Submit insurance purchase request
 * Body params: planId, crop, area, estimatedYield, farmerInfo
 */
router.post('/purchase', async (req, res) => {
  try {
    const { planId, crop, area, estimatedYield, farmerInfo } = req.body;

    if (!planId || !crop || !area || !farmerInfo) {
      return res.status(400).json({
        error: 'Missing required fields: planId, crop, area, farmerInfo',
      });
    }

    // In a real app, this would save to database and send notification
    const purchaseRequest = {
      requestId: `INS-${Date.now()}`,
      status: 'pending_review',
      planId,
      crop,
      area,
      estimatedYield,
      farmerInfo,
      submittedAt: new Date().toISOString(),
      nextSteps: [
        'Application submitted successfully',
        'Your request is under review',
        'You will receive SMS confirmation within 24 hours',
        'Visit the office for document verification',
        'Premium payment and policy issuance',
      ],
      estimatedProcessingTime: '2-3 working days',
    };

    res.status(201).json({
      success: true,
      message: 'Insurance purchase request submitted',
      data: purchaseRequest,
    });
  } catch (error) {
    res.status(500).json({
      error: error.message || 'Failed to submit insurance purchase request',
    });
  }
});

/**
 * GET /api/insurance/plans/:planId
 * Get detailed information about a specific insurance plan
 */
router.get('/plans/:planId', async (req, res) => {
  try {
    const { planId } = req.params;

    if (!planId) {
      return res.status(400).json({
        error: 'Plan ID is required',
      });
    }

    // Get detailed plan info
    const planDetails = {
      pmfby: {
        name: 'Pradhan Mantri Fasal Bima Yojana',
        description: 'Government crop insurance scheme',
        eligibility: [
          'Farmers growing notified crops',
          'On their own land or leased land',
          'Crops must be notified for that season',
        ],
        benefits: [
          'Comprehensive crop loss coverage',
          'Low premium rates',
          'Government subsidy (48% for small farmers)',
          'Quick claim settlement',
        ],
      },
      weather_based: {
        name: 'Weather Based Crop Insurance',
        description: 'Index-based insurance for weather-related losses',
        eligibility: [
          'Farmers in notified districts',
          'Growing notified crops',
          'Any landholding size',
        ],
        benefits: [
          'Quick claim settlement (10-15 days)',
          'No individual assessment required',
          'Covers various weather events',
        ],
      },
      private_insurance: {
        name: 'Private Crop Insurance',
        description: 'Customizable plans from insurance companies',
        eligibility: ['Any farmer', 'Any crop', 'Any region'],
        benefits: [
          'Comprehensive customizable coverage',
          'Higher sum insured options',
          'Additional benefits available',
        ],
      },
      farmer_welfare: {
        name: 'State Farmer Welfare Schemes',
        description: 'State-level insurance programs',
        eligibility: [
          'Registered farmers in the state',
          'Meeting state-specific criteria',
        ],
        benefits: [
          'Heavily subsidized premiums',
          'State-customized coverage',
          'Quick local claim processing',
        ],
      },
      micro_insurance: {
        name: 'Micro Insurance Plan',
        description: 'Affordable insurance for marginal farmers',
        eligibility: [
          'Small and marginal farmers',
          'Landholding up to 2 hectares',
        ],
        benefits: [
          'Very affordable premiums',
          'Simplified claim process',
          'Community-based support',
        ],
      },
    };

    const details = planDetails[planId];

    if (!details) {
      return res.status(404).json({
        error: 'Insurance plan not found',
      });
    }

    res.json({
      planId,
      ...details,
    });
  } catch (error) {
    res.status(500).json({
      error: error.message || 'Failed to fetch plan details',
    });
  }
});

module.exports = router;
