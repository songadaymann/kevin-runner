#!/bin/bash

# Optimize GLB models with decimation + Draco compression
# This will create optimized versions alongside the originals

echo "🔧 Installing gltf-transform if needed..."
npm install -g @gltf-transform/cli 2>/dev/null || true

# Settings
SIMPLIFY_RATIO=0.5  # Keep 50% of polygons (adjust: 0.3 = aggressive, 0.7 = conservative)

echo ""
echo "📦 Optimizing punk models..."
echo "   Simplify ratio: ${SIMPLIFY_RATIO} (keeping ${SIMPLIFY_RATIO}00% of polygons)"
echo ""

# Process all punk GLBs
for punk_dir in assets/punks/*/; do
    punk_name=$(basename "$punk_dir")
    
    for glb_file in "$punk_dir"*.glb; do
        if [ -f "$glb_file" ]; then
            filename=$(basename "$glb_file" .glb)
            output_file="${punk_dir}${filename}_optimized.glb"
            
            # Skip if already an optimized file or animation-only file
            if [[ "$filename" == *"_optimized"* ]] || [[ "$filename" == *"_anim"* ]]; then
                continue
            fi
            
            original_size=$(ls -lh "$glb_file" | awk '{print $5}')
            echo "Processing: $glb_file ($original_size)"
            
            # Run gltf-transform: simplify + draco compress
            npx @gltf-transform/cli optimize "$glb_file" "$output_file" \
                --simplify --simplify-ratio $SIMPLIFY_RATIO \
                --compress draco \
                2>/dev/null
            
            if [ -f "$output_file" ]; then
                new_size=$(ls -lh "$output_file" | awk '{print $5}')
                echo "   ✅ Created: $output_file ($new_size)"
            else
                echo "   ❌ Failed to optimize $glb_file"
            fi
        fi
    done
done

# Also optimize Kevin
echo ""
echo "📦 Optimizing Kevin model..."
kevin_file="assets/kevin/glb/kevin_mixamo_withskin.glb"
kevin_output="assets/kevin/glb/kevin_mixamo_withskin_optimized.glb"

if [ -f "$kevin_file" ]; then
    original_size=$(ls -lh "$kevin_file" | awk '{print $5}')
    echo "Processing: $kevin_file ($original_size)"
    
    npx @gltf-transform/cli optimize "$kevin_file" "$kevin_output" \
        --simplify --simplify-ratio $SIMPLIFY_RATIO \
        --compress draco \
        2>/dev/null
    
    if [ -f "$kevin_output" ]; then
        new_size=$(ls -lh "$kevin_output" | awk '{print $5}')
        echo "   ✅ Created: $kevin_output ($new_size)"
    else
        echo "   ❌ Failed to optimize Kevin"
    fi
fi

echo ""
echo "🎉 Done! Optimized files have '_optimized' suffix."
echo ""
echo "To use them, update the paths in index.html, or rename them to replace originals."
echo ""

# Show size comparison
echo "📊 Size comparison:"
echo "───────────────────────────────────────────────────"
for f in assets/punks/*/*_optimized.glb assets/kevin/glb/*_optimized.glb; do
    if [ -f "$f" ]; then
        original="${f/_optimized/}"
        if [ -f "$original" ]; then
            orig_size=$(ls -lh "$original" | awk '{print $5}')
            new_size=$(ls -lh "$f" | awk '{print $5}')
            name=$(basename "$original")
            echo "$name: $orig_size → $new_size"
        fi
    fi
done

