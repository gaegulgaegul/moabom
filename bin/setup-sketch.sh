#!/bin/bash

# Frame0 Sketch Style Environment Setup Script
# This script sets up the sketch-style UI dependencies for moabom

set -e

echo "==================================="
echo "Frame0 Sketch Environment Setup"
echo "==================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the project root
if [ ! -f "Gemfile" ]; then
    echo -e "${RED}Error: Please run this script from the project root directory${NC}"
    exit 1
fi

echo -e "${YELLOW}Step 1: Installing npm dependencies...${NC}"
if command -v yarn &> /dev/null; then
    yarn install
elif command -v npm &> /dev/null; then
    npm install
else
    echo -e "${YELLOW}Warning: Neither yarn nor npm found. Using importmap CDN pins only.${NC}"
fi
echo -e "${GREEN}Done!${NC}"
echo ""

echo -e "${YELLOW}Step 2: Building TailwindCSS with sketch tokens...${NC}"
bin/rails tailwindcss:build
echo -e "${GREEN}Done!${NC}"
echo ""

echo -e "${YELLOW}Step 3: Verifying sketch files...${NC}"

# Check required files
FILES=(
    "app/javascript/sketch/index.js"
    "app/javascript/controllers/sketch_border_controller.js"
    "app/assets/stylesheets/sketch-variables.css"
    "design-tokens.json"
)

ALL_PRESENT=true
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ${GREEN}✓${NC} $file"
    else
        echo -e "  ${RED}✗${NC} $file (missing)"
        ALL_PRESENT=false
    fi
done
echo ""

if [ "$ALL_PRESENT" = true ]; then
    echo -e "${GREEN}All sketch files are present!${NC}"
else
    echo -e "${YELLOW}Some files are missing. The sketch environment may not work correctly.${NC}"
fi
echo ""

echo -e "${YELLOW}Step 4: Checking importmap configuration...${NC}"
if grep -q "roughjs" config/importmap.rb; then
    echo -e "  ${GREEN}✓${NC} Rough.js pinned in importmap"
else
    echo -e "  ${RED}✗${NC} Rough.js not found in importmap"
fi

if grep -q "wired-elements" config/importmap.rb; then
    echo -e "  ${GREEN}✓${NC} Wired Elements pinned in importmap"
else
    echo -e "  ${RED}✗${NC} Wired Elements not found in importmap"
fi

if grep -q "stimulus-use" config/importmap.rb; then
    echo -e "  ${GREEN}✓${NC} Stimulus-use pinned in importmap"
else
    echo -e "  ${RED}✗${NC} Stimulus-use not found in importmap"
fi
echo ""

echo "==================================="
echo -e "${GREEN}Frame0 Sketch Environment Setup Complete!${NC}"
echo "==================================="
echo ""
echo "Usage examples:"
echo ""
echo "  1. Apply sketch border to an element:"
echo "     <div data-controller=\"sketch-border\""
echo "          data-sketch-border-roughness-value=\"1.5\">"
echo "       Content"
echo "     </div>"
echo ""
echo "  2. Use sketch CSS classes:"
echo "     <button class=\"sketch-btn-primary\">Click me</button>"
echo "     <div class=\"sketch-card\">Card content</div>"
echo "     <input class=\"sketch-input\" placeholder=\"Type here\">"
echo ""
echo "  3. Use Rough.js in JavaScript:"
echo "     import { createSketchCanvas, sketchRect } from 'sketch/index'"
echo "     const rc = createSketchCanvas(canvasElement)"
echo "     sketchRect(rc, 10, 10, 100, 100)"
echo ""
echo "  4. Use Wired Elements:"
echo "     <wired-button>Click</wired-button>"
echo "     <wired-input placeholder=\"Enter text\"></wired-input>"
echo ""
