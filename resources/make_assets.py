import cv2
import numpy as np
import os
from PIL import Image, ImageDraw, ImageFont

base = r"C:\Users\1\Desktop\fake\FakeDiia\Assets.xcassets"

# --- tryzub: white -> alpha, autocrop ---
raw = cv2.imread(r"C:\Users\1\Desktop\fake\FakeDiia\resources\tryzub_raw.png")
g = cv2.cvtColor(raw, cv2.COLOR_BGR2GRAY)
alpha = 255 - g  # black strokes opaque
ys, xs = np.where(alpha > 8)
x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
a = alpha[y0:y1 + 1, x0:x1 + 1]
h, w = a.shape
rgba = np.zeros((h, w, 4), dtype=np.uint8)
rgba[:, :, 0:3] = 26  # #1A1A1C ink
rgba[:, :, 3] = a
cv2.imwrite(os.path.join(base, "Tryzub.imageset", "tryzub.png"), rgba)
print("tryzub", w, "x", h)

# --- app icon: black tile, white "dia" ---
icon = Image.new("RGB", (1024, 1024), (13, 13, 15))
d = ImageDraw.Draw(icon)
f = ImageFont.truetype(r"C:\Windows\Fonts\arialbd.ttf", 340)
d.text((512, 522), "дія", font=f, fill=(255, 255, 255), anchor="mm")
icon.save(os.path.join(base, "AppIcon.appiconset", "icon1024.png"))
print("icon ok")


def cj(path, data):
    with open(os.path.join(base, path), "w") as fh:
        fh.write(data)


cj("Tryzub.imageset/Contents.json", """{
  "images" : [ { "filename" : "tryzub.png", "idiom" : "universal", "scale" : "1x" } ],
  "info" : { "author" : "xcode", "version" : 1 }
}""")
cj("AppIcon.appiconset/Contents.json", """{
  "images" : [ { "filename" : "icon1024.png", "idiom" : "universal", "platform" : "ios", "size" : "1024x1024" } ],
  "info" : { "author" : "xcode", "version" : 1 }
}""")
cj("AccentColor.colorset/Contents.json", """{
  "colors" : [ { "color" : { "color-space" : "srgb", "components" : { "alpha" : "1.000", "blue" : "0x1C", "green" : "0x1A", "red" : "0x1A" } }, "idiom" : "universal" } ],
  "info" : { "author" : "xcode", "version" : 1 }
}""")
cj("Contents.json", "{ \"info\" : { \"author\" : \"xcode\", \"version\" : 1 } }")
print("catalogs ok")
