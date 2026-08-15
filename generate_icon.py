from PIL import Image, ImageDraw
import os
import math

size = 1024
image = Image.new("RGBA", (size, size), (255, 255, 255, 0))
draw = ImageDraw.Draw(image)

# Draw solid circle (Teal 600 - 0F766E)
draw.ellipse([0, 0, size, size], fill="#0F766E")

# Draw a heart using a mathematical formula
heart_image = Image.new("RGBA", (size, size), (255, 255, 255, 0))
heart_draw = ImageDraw.Draw(heart_image)

points = []
center_x = size / 2
center_y = size / 2
scale = 18

for t in range(0, 628):
    t_val = t / 100.0
    # heart equation
    x = 16 * (math.sin(t_val)**3)
    y = 13 * math.cos(t_val) - 5 * math.cos(2*t_val) - 2 * math.cos(3*t_val) - math.cos(4*t_val)
    
    # Scale and center (invert Y because image coordinates go down)
    px = center_x + (x * scale)
    py = center_y - (y * scale) - 30
    points.append((px, py))

heart_draw.polygon(points, fill=(255, 255, 255, 255))

image.paste(heart_image, (0, 0), heart_image)

os.makedirs("assets", exist_ok=True)
image.save("assets/icon.png")
print("Saved assets/icon.png with mathematical heart")
