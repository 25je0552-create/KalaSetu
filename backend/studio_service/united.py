"""
united.py - Module 1: AI Virtual Studio & Image Enhancer for KalaSetu

This module provides the complete ML & OpenCV pipeline for artisan craft photos:
1. OpenCV Preprocessing:
   - Color space transformation (BGR -> LAB)
   - Contrast-Limited Adaptive Histogram Equalization (CLAHE) on Lightness channel
   - Edge-preserving bilateral denoising
2. AI Background Removal:
   - Deep learning segmentation via rembg (U2-Net)
   - Alpha matting for fine fringe/edge preservation
3. Studio Rendering:
   - Neutral studio canvas (RGB 248, 249, 250)
   - Dynamic soft-contact drop shadow generation via OpenCV + Gaussian Blur
   - High-precision RGBA alpha compositing
"""

import io
import sys
import os
import cv2
import numpy as np
from PIL import Image, ImageFilter

try:
    from rembg import new_session, remove
    HAS_REMBG = True
    SESSION = new_session("u2net")
except Exception as e:
    HAS_REMBG = False
    SESSION = None
    print(f"[united.py] Warning: rembg not initialized: {e}")


def preprocess_opencv(image_bytes: bytes) -> bytes:
    """
    Applies CLAHE on the L-channel of the LAB color space and bilateral denoising.
    Preserves intricate handicraft textures while enhancing local contrast and colors.
    """
    file_bytes = np.frombuffer(image_bytes, np.uint8)
    img_bgr = cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)

    if img_bgr is None:
        raise ValueError("Invalid image file provided.")

    # LAB Lightness adjustment
    lab = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2LAB)
    l, a, b = cv2.split(lab)

    clahe = cv2.createCLAHE(clipLimit=2.5, tileGridSize=(8, 8))
    l_enhanced = clahe.apply(l)

    lab_enhanced = cv2.merge((l_enhanced, a, b))
    img_contrast = cv2.cvtColor(lab_enhanced, cv2.COLOR_LAB2BGR)

    # Edge-preserving Bilateral Denoising
    img_denoised = cv2.bilateralFilter(img_contrast, d=7, sigmaColor=50, sigmaSpace=50)

    _, encoded = cv2.imencode('.jpg', img_denoised, [int(cv2.IMWRITE_JPEG_QUALITY), 95])
    return encoded.tobytes()


def remove_background(image_bytes: bytes) -> Image.Image:
    """
    Removes background using U2-Net deep learning model with alpha matting.
    Returns RGBA PIL Image.
    """
    input_image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    if not HAS_REMBG or SESSION is None:
        # Fallback if rembg is not installed: convert to RGBA directly
        return input_image.convert("RGBA")

    output_image = remove(
        input_image,
        session=SESSION,
        alpha_matting=True,
        alpha_matting_foreground_threshold=240,
        alpha_matting_background_threshold=10,
        alpha_matting_erode_size=10
    )
    return output_image


def create_studio_rendering(foreground_rgba: Image.Image, bg_color=(248, 249, 250)) -> Image.Image:
    """
    Creates realistic studio rendering by generating a soft drop shadow
    on a neutral studio canvas and alpha-compositing the foreground craft.
    """
    width, height = foreground_rgba.size
    canvas = Image.new("RGBA", (width, height), bg_color + (255,))

    # Extract alpha channel to compute shadow mask
    alpha_channel = foreground_rgba.split()[3]
    alpha_np = np.array(alpha_channel)

    # Scale shadow slightly to position at bottom
    shadow_height = int(height * 0.98)
    shadow_width = int(width * 0.98)
    resized_shadow = cv2.resize(alpha_np, (shadow_width, shadow_height), interpolation=cv2.INTER_AREA)

    shadow_mask_np = np.zeros((height, width), dtype=np.uint8)
    y_offset = int(height * 0.02)
    x_offset = int((width - shadow_width) / 2)
    shadow_mask_np[y_offset:y_offset + shadow_height, x_offset:x_offset + shadow_width] = resized_shadow

    # Gaussian blur for soft shadow dissipation
    shadow_pil = Image.fromarray(shadow_mask_np)
    shadow_blur_radius = max(10, int(min(width, height) * 0.03))
    blurred_shadow = shadow_pil.filter(ImageFilter.GaussianBlur(shadow_blur_radius))

    # Apply 30% shadow opacity
    shadow_opacity_np = (np.array(blurred_shadow) * 0.30).astype(np.uint8)
    shadow_final_alpha = Image.fromarray(shadow_opacity_np)

    black_shadow_layer = Image.new("RGBA", (width, height), (30, 30, 30, 0))
    black_shadow_layer.putalpha(shadow_final_alpha)

    # Composite canvas + shadow + foreground
    final_render = Image.alpha_composite(canvas, black_shadow_layer)
    final_render = Image.alpha_composite(final_render, foreground_rgba)

    return final_render.convert("RGB")


def process_image(image_bytes: bytes) -> bytes:
    """
    End-to-end pipeline:
    1. Preprocesses image using OpenCV (CLAHE + Bilateral Denoising)
    2. Segment/removes background using rembg U2-Net
    3. Renders soft studio shadow and backdrop
    Returns optimized JPEG bytes.
    """
    preprocessed_bytes = preprocess_opencv(image_bytes)
    foreground_rgba = remove_background(preprocessed_bytes)
    final_studio_img = create_studio_rendering(foreground_rgba)

    output_buffer = io.BytesIO()
    final_studio_img.save(output_buffer, format="JPEG", quality=92, optimize=True)
    return output_buffer.getvalue()


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python united.py <input_image_path> [output_image_path]")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else "studio_output.jpg"

    if not os.path.exists(input_path):
        print(f"Error: Input file {input_path} does not exist.")
        sys.exit(1)

    with open(input_path, "rb") as f:
        in_bytes = f.read()

    print(f"[united.py] Processing {input_path} through Module 1 pipeline...")
    out_bytes = process_image(in_bytes)

    with open(output_path, "wb") as f:
        f.write(out_bytes)

    print(f"[united.py] Saved enhanced studio image to {output_path} ({len(out_bytes)} bytes)")
