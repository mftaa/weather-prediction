#!/bin/bash

# AI Model Integration - Verification Script
# Usage: bash verify_ai_integration.sh
# Purpose: Check if AI model integration is complete and working

echo "🔍 AI Model Integration Verification"
echo "===================================="
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0

# Check 1: Model file exists
echo -n "1. Checking AI model file exists... "
if [ -f "models - Random Forest - Prediksi cuma pake tanggal/new/v4_weather_model_combined.joblib" ]; then
    echo -e "${GREEN}✓${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗${NC}"
    echo "   → File not found at: models - Random Forest - Prediksi cuma pake tanggal/new/v4_weather_model_combined.joblib"
    ((FAILED++))
fi

# Check 2: Backend main.py has AI imports
echo -n "2. Checking backend has joblib import... "
if grep -q "import joblib" backend/main.py; then
    echo -e "${GREEN}✓${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗${NC}"
    echo "   → joblib import not found in backend/main.py"
    ((FAILED++))
fi

# Check 3: Backend has AI endpoints
echo -n "3. Checking /ai-prediction/daily endpoint exists... "
if grep -q "def predict_daily_weather" backend/main.py; then
    echo -e "${GREEN}✓${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗${NC}"
    echo "   → predict_daily_weather function not found"
    ((FAILED++))
fi

echo -n "4. Checking /ai-prediction/hourly endpoint exists... "
if grep -q "def predict_hourly_weather" backend/main.py; then
    echo -e "${GREEN}✓${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗${NC}"
    echo "   → predict_hourly_weather function not found"
    ((FAILED++))
fi

echo -n "5. Checking /ai-model/info endpoint exists... "
if grep -q "def get_model_info" backend/main.py; then
    echo -e "${GREEN}✓${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗${NC}"
    echo "   → get_model_info function not found"
    ((FAILED++))
fi

# Check 4: Flutter service exists
echo -n "6. Checking Flutter AI service file... "
if [ -f "Weather-Station/lib/services/ai_prediction_service.dart" ]; then
    echo -e "${GREEN}✓${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗${NC}"
    echo "   → ai_prediction_service.dart not found"
    ((FAILED++))
fi

# Check 5: Flutter UI example exists
echo -n "7. Checking Flutter AI prediction page... "
if [ -f "Weather-Station/lib/pages/ai_prediction_page.dart" ]; then
    echo -e "${GREEN}✓${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗${NC}"
    echo "   → ai_prediction_page.dart not found"
    ((FAILED++))
fi

# Check 6: Documentation files
echo -n "8. Checking documentation files... "
DOCS_OK=true
if [ ! -f "AI_INTEGRATION_GUIDE.md" ]; then
    DOCS_OK=false
fi
if [ ! -f "AI_SETUP_GUIDE.md" ]; then
    DOCS_OK=false
fi
if [ ! -f "AI_QUICK_REFERENCE.md" ]; then
    DOCS_OK=false
fi

if [ "$DOCS_OK" = true ]; then
    echo -e "${GREEN}✓${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗${NC}"
    echo "   → Missing documentation files"
    ((FAILED++))
fi

echo ""
echo "===================================="
echo "Results:"
echo -e "  ${GREEN}Passed: $PASSED${NC}"
echo -e "  ${RED}Failed: $FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Install dependencies: pip install joblib pandas scikit-learn"
    echo "2. Start backend: cd backend && python main.py"
    echo "3. Test API: curl http://localhost:8000/ai-model/info"
    echo "4. Run Flutter app with AI features"
    echo ""
    exit 0
else
    echo ""
    echo -e "${RED}✗ Some checks failed. See details above.${NC}"
    echo ""
    exit 1
fi
