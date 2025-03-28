from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

# Create directory if it doesn't exist
os.makedirs('assets/images', exist_ok=True)

# Create a 1024x1024 image with a solid background instead of gradient
img = Image.new('RGBA', (1024, 1024), (73, 94, 226, 255))  # Bright indigo color
draw = ImageDraw.Draw(img)

# Draw rounded rectangle for the background
draw.rounded_rectangle([(0, 0), (1024, 1024)], 240, fill=(73, 94, 226, 255), outline=None)

# Add a simple, high-contrast microphone design
# Main microphone body
mic_color = (255, 255, 255)  # Solid white for high contrast
mic_x = 512  # Center x
mic_y = 400  # Center y
mic_width = 260
mic_height = 360
mic_radius = 120

# Microphone body - solid white
draw.rounded_rectangle(
    [(mic_x - mic_width//2, mic_y - mic_height//2), 
     (mic_x + mic_width//2, mic_y + mic_height//2)],
    mic_radius, 
    fill=mic_color,
    outline=(240, 240, 240, 200),
    width=3
)

# Microphone stand 
stand_width = 80
stand_height = 160
draw.rectangle(
    [(mic_x - stand_width//2, mic_y + mic_height//2), 
     (mic_x + stand_width//2, mic_y + mic_height//2 + stand_height)],
    fill=mic_color
)

# Microphone base
base_width = 320
base_height = 60
draw.rounded_rectangle(
    [(mic_x - base_width//2, mic_y + mic_height//2 + stand_height), 
     (mic_x + base_width//2, mic_y + mic_height//2 + stand_height + base_height)],
    30,
    fill=mic_color
)

# Add microphone grid
grid_color = (73, 94, 226, 180)  # Slightly transparent blue
grid_rows = 8
grid_cols = 6
grid_width = 180
grid_height = 220
grid_top = mic_y - grid_height//2 + 20
grid_left = mic_x - grid_width//2

# Draw horizontal grid lines
for i in range(grid_rows+1):
    y = grid_top + (grid_height / grid_rows) * i
    draw.line(
        [(grid_left, y), (grid_left + grid_width, y)], 
        fill=grid_color, 
        width=2
    )

# Draw vertical grid lines
for i in range(grid_cols+1):
    x = grid_left + (grid_width / grid_cols) * i
    draw.line(
        [(x, grid_top), (x, grid_top + grid_height)], 
        fill=grid_color, 
        width=2
    )

# Draw sound waves - bold and bright
wave_color = (255, 215, 0)  # Bright gold for visibility
wave_thickness = 12

# Left sound waves
for i in range(3):
    offset = i * 50
    draw.arc(
        [(mic_x - 400 + offset, mic_y - 250 + offset), 
         (mic_x - 100 - offset, mic_y + 150 - offset)],
        160, 270, 
        fill=wave_color, 
        width=wave_thickness - i*2
    )

# Right sound waves
for i in range(3):
    offset = i * 50
    draw.arc(
        [(mic_x + 100 + offset, mic_y - 250 + offset), 
         (mic_x + 400 - offset, mic_y + 150 - offset)],
        270, 380, 
        fill=wave_color, 
        width=wave_thickness - i*2
    )

# Add AI badge
badge_color = (30, 41, 99)  # Dark blue
badge_width = 180
badge_height = 80
badge_radius = 30
badge_x = mic_x - badge_width // 2
badge_y = 200

draw.rounded_rectangle(
    [(badge_x, badge_y), (badge_x + badge_width, badge_y + badge_height)], 
    badge_radius, 
    fill=badge_color
)

# Add "AI" text - bold and clear
ai_text_color = (255, 255, 255)
ai_text_thickness = 12

# Letter A
a_left = badge_x + 40
a_top = badge_y + 15
a_width = 40
a_height = 50

draw.line([(a_left, badge_y + badge_height - 15), (a_left + a_width/2, a_top)], 
          fill=ai_text_color, width=ai_text_thickness)
draw.line([(a_left + a_width/2, a_top), (a_left + a_width, badge_y + badge_height - 15)], 
          fill=ai_text_color, width=ai_text_thickness)
draw.line([(a_left + 10, badge_y + 50), (a_left + a_width - 10, badge_y + 50)], 
          fill=ai_text_color, width=ai_text_thickness)

# Letter I
i_left = badge_x + 100
i_top = badge_y + 15
i_width = 40
i_height = 50

draw.line([(i_left, i_top), (i_left + i_width, i_top)], 
          fill=ai_text_color, width=ai_text_thickness)
draw.line([(i_left + i_width/2, i_top), (i_left + i_width/2, i_top + i_height)], 
          fill=ai_text_color, width=ai_text_thickness)
draw.line([(i_left, i_top + i_height), (i_left + i_width, i_top + i_height)], 
          fill=ai_text_color, width=ai_text_thickness)

# Save the full icon
img.save('assets/images/app_logo.png', 'PNG')
print("Created app_logo.png")

# Create identical foreground image (for Android adaptive icons)
img.save('assets/images/app_logo_foreground.png', 'PNG')
print("Created app_logo_foreground.png")

print("Icon generation complete. Run 'dart run flutter_launcher_icons' to apply icons.") 