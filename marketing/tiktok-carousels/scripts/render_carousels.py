from __future__ import annotations

import json
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source"
OUT_4X5 = ROOT / "4x5"
OUT_9X16 = ROOT / "9x16"
CONTACT = ROOT / "contact-sheets"

PALETTE = {
    "cream": "#F6EFE5",
    "paper": "#FFFDF8",
    "ink": "#2C2018",
    "espresso": "#4A352E",
    "ink_soft": "#5A4A3C",
    "crema": "#B8732E",
    "crema_soft": "#E7C79A",
    "line": "#E6DCCD",
}

FONT_DISPLAY = "/System/Library/Fonts/NewYork.ttf"
FONT_UTILITY = "/System/Library/Fonts/Avenir Next.ttc"

SLIDES = [
    {
        "file": "c01-s01-opening-bag.png",
        "carousel": "01",
        "title": "From Bean to Cup",
        "slide": "01",
        "eyebrow": "THE MORNING RITUAL",
        "headline": "Bean to cup, one quiet shot at a time.",
        "footer": "Coffii",
    },
    {
        "file": "c01-s02-weigh-grind.png",
        "carousel": "01",
        "title": "From Bean to Cup",
        "slide": "02",
        "eyebrow": "02 - WEIGH & GRIND",
        "headline": "Eighteen grams, dialed in.",
    },
    {
        "file": "c01-s03-dose-tamp.png",
        "carousel": "01",
        "title": "From Bean to Cup",
        "slide": "03",
        "eyebrow": "03 - DOSE & TAMP",
        "headline": "Level, press, breathe.",
    },
    {
        "file": "c01-s04-pull-payoff.png",
        "carousel": "01",
        "title": "From Bean to Cup",
        "slide": "04",
        "eyebrow": "04 - THE PULL",
        "headline": "Every shot, worth remembering.",
        "footer": "Log it. Share it. Coffii",
        "phone": True,
    },
    {
        "file": "c02-s01-bag-light.png",
        "carousel": "02",
        "title": "Slow Mornings",
        "slide": "01",
        "eyebrow": "SLOW MORNINGS",
        "headline": "Before the first cup.",
    },
    {
        "file": "c02-s02-hands-work.png",
        "carousel": "02",
        "title": "Slow Mornings",
        "slide": "02",
        "eyebrow": "WEIGH - GRIND - TAMP",
        "headline": "Eighteen grams of intention.",
    },
    {
        "file": "c02-s03-the-drop.png",
        "carousel": "02",
        "title": "Slow Mornings",
        "slide": "03",
        "eyebrow": "THE PULL",
        "headline": "Thirty seconds of amber.",
        "footer": "Coffii - your espresso, logged.",
    },
    {
        "file": "c03-s01-open.png",
        "carousel": "03",
        "title": "The Full Ritual",
        "slide": "01",
        "eyebrow": "01 - OPEN",
        "headline": "First breath of roast.",
    },
    {
        "file": "c03-s02-weigh.png",
        "carousel": "03",
        "title": "The Full Ritual",
        "slide": "02",
        "eyebrow": "02 - WEIGH",
        "headline": "Dial in the dose.",
    },
    {
        "file": "c03-s03-grind.png",
        "carousel": "03",
        "title": "The Full Ritual",
        "slide": "03",
        "eyebrow": "03 - GRIND",
        "headline": "Fine, not too fine.",
    },
    {
        "file": "c03-s04-level-tamp.png",
        "carousel": "03",
        "title": "The Full Ritual",
        "slide": "04",
        "eyebrow": "04 - LEVEL & TAMP",
        "headline": "A flat bed pulls.",
    },
    {
        "file": "c03-s05-pull.png",
        "carousel": "03",
        "title": "The Full Ritual",
        "slide": "05",
        "eyebrow": "05 - PULL",
        "headline": "Twenty-five seconds.",
    },
    {
        "file": "c03-s06-log-it.png",
        "carousel": "03",
        "title": "The Full Ritual",
        "slide": "06",
        "eyebrow": "06 - LOG IT",
        "headline": "Every shot remembered.",
        "footer": "Coffii",
        "phone": True,
    },
    {
        "file": "c04-s01-baseline.png",
        "carousel": "04",
        "title": "Dial In One Thing",
        "slide": "01",
        "eyebrow": "DIAL IN",
        "headline": "Start with eighteen.",
    },
    {
        "file": "c04-s02-adjust-grind.png",
        "carousel": "04",
        "title": "Dial In One Thing",
        "slide": "02",
        "eyebrow": "CHANGE ONE THING",
        "headline": "Finer by a notch.",
    },
    {
        "file": "c04-s03-taste-tune.png",
        "carousel": "04",
        "title": "Dial In One Thing",
        "slide": "03",
        "eyebrow": "TASTE, THEN TUNE",
        "headline": "Closer every pull.",
    },
    {
        "file": "c04-s04-review-pattern.png",
        "carousel": "04",
        "title": "Dial In One Thing",
        "slide": "04",
        "eyebrow": "SAVE THE SETUP",
        "headline": "Remember what worked.",
        "footer": "Coffii",
        "phone": True,
    },
    {
        "file": "c05-s01-after-pull.png",
        "carousel": "05",
        "title": "Shot in Review",
        "slide": "01",
        "eyebrow": "AFTER THE PULL",
        "headline": "What changed?",
    },
    {
        "file": "c05-s02-shot-tells-you.png",
        "carousel": "05",
        "title": "Shot in Review",
        "slide": "02",
        "eyebrow": "SHOT IN REVIEW",
        "headline": "The shot tells you.",
        "phone": True,
    },
    {
        "file": "c05-s03-share-good-ones.png",
        "carousel": "05",
        "title": "Shot in Review",
        "slide": "03",
        "eyebrow": "SHARE",
        "headline": "Send the good ones.",
        "footer": "Coffii",
        "phone": True,
    },
    {
        "file": "c06-s01-fresh-bag.png",
        "carousel": "06",
        "title": "New Bag Baseline",
        "slide": "01",
        "eyebrow": "FRESH BAG",
        "headline": "Reset the ritual.",
    },
    {
        "file": "c06-s02-first-pull.png",
        "carousel": "06",
        "title": "New Bag Baseline",
        "slide": "02",
        "eyebrow": "FIRST PULL",
        "headline": "Learn the roast.",
    },
    {
        "file": "c06-s03-keep-thread.png",
        "carousel": "06",
        "title": "New Bag Baseline",
        "slide": "03",
        "eyebrow": "NOTES",
        "headline": "Keep the thread.",
        "footer": "Coffii",
        "phone": True,
    },
    {
        "file": "c07-s01-espresso-only.png",
        "carousel": "07",
        "title": "Espresso Only",
        "slide": "01",
        "eyebrow": "NO MILK, NO NOISE",
        "headline": "Just the shot.",
    },
    {
        "file": "c07-s02-local-first.png",
        "carousel": "07",
        "title": "Espresso Only",
        "slide": "02",
        "eyebrow": "LOCAL FIRST",
        "headline": "Your notes stay yours.",
        "phone": True,
    },
    {
        "file": "c07-s03-remember-pull.png",
        "carousel": "07",
        "title": "Espresso Only",
        "slide": "03",
        "eyebrow": "COFFII",
        "headline": "Remember every pull.",
        "footer": "Coffii",
        "phone": True,
    },
]


def font(path: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(path, size)


def hex_to_rgba(value: str, alpha: int = 255) -> tuple[int, int, int, int]:
    value = value.lstrip("#")
    return tuple(int(value[i : i + 2], 16) for i in (0, 2, 4)) + (alpha,)


def cover_crop(img: Image.Image, size: tuple[int, int], focal_y: float = 0.55) -> Image.Image:
    target_w, target_h = size
    source_w, source_h = img.size
    scale = max(target_w / source_w, target_h / source_h)
    resized = img.resize((math.ceil(source_w * scale), math.ceil(source_h * scale)), Image.LANCZOS)
    excess_x = resized.width - target_w
    excess_y = resized.height - target_h
    left = max(0, min(excess_x, round(excess_x * 0.5)))
    top = max(0, min(excess_y, round(resized.height * focal_y - target_h * 0.5)))
    return resized.crop((left, top, left + target_w, top + target_h))


def text_size(draw: ImageDraw.ImageDraw, text: str, text_font: ImageFont.FreeTypeFont) -> tuple[int, int]:
    bbox = draw.textbbox((0, 0), text, font=text_font)
    return bbox[2] - bbox[0], bbox[3] - bbox[1]


def tracked_text(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    text: str,
    text_font: ImageFont.FreeTypeFont,
    fill: tuple[int, int, int, int],
    tracking: int,
) -> None:
    x, y = xy
    for char in text:
        draw.text((x, y), char, font=text_font, fill=fill)
        char_w = text_size(draw, char, text_font)[0]
        x += char_w + tracking


def wrap_lines(draw: ImageDraw.ImageDraw, text: str, text_font: ImageFont.FreeTypeFont, max_width: int) -> list[str]:
    lines: list[str] = []
    for explicit in text.split("\n"):
        words = explicit.split()
        current = ""
        for word in words:
            candidate = word if not current else f"{current} {word}"
            if text_size(draw, candidate, text_font)[0] <= max_width:
                current = candidate
            else:
                if current:
                    lines.append(current)
                current = word
        if current:
            lines.append(current)
    return lines


def draw_phone_mockup(base: Image.Image, format_name: str) -> None:
    if format_name == "9x16":
        phone_w, phone_h = 315, 620
        margin_right, margin_bottom = 58, 166
    else:
        phone_w, phone_h = 250, 492
        margin_right, margin_bottom = 58, 80

    phone = Image.new("RGBA", (phone_w, phone_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(phone)
    radius = round(phone_w * 0.12)
    draw.rounded_rectangle((0, 0, phone_w, phone_h), radius=radius, fill=hex_to_rgba(PALETTE["ink"], 248))
    inset = round(phone_w * 0.055)
    screen = (inset, inset * 2, phone_w - inset, phone_h - inset)
    draw.rounded_rectangle(screen, radius=round(radius * 0.62), fill=hex_to_rgba(PALETTE["cream"]))

    sx0, sy0, sx1, sy1 = screen
    card_pad = round(phone_w * 0.09)
    card = (sx0 + card_pad, sy0 + card_pad * 2, sx1 - card_pad, sy1 - card_pad)
    draw.rounded_rectangle(card, radius=8, fill=hex_to_rgba(PALETTE["paper"]), outline=hex_to_rgba(PALETTE["line"]), width=2)

    small = font(FONT_UTILITY, max(12, round(phone_w * 0.042)))
    small_bold = font(FONT_UTILITY, max(12, round(phone_w * 0.047)))
    display = font(FONT_DISPLAY, max(22, round(phone_w * 0.092)))
    stat = font(FONT_DISPLAY, max(17, round(phone_w * 0.066)))

    tx = card[0] + round(phone_w * 0.055)
    ty = card[1] + round(phone_w * 0.062)
    tracked_text(draw, (tx, ty), "SHOT IN REVIEW", small_bold, hex_to_rgba(PALETTE["ink_soft"]), 1)
    ty += round(phone_w * 0.115)
    draw.text((tx, ty), "Worth", font=display, fill=hex_to_rgba(PALETTE["ink"]))
    ty += round(phone_w * 0.105)
    draw.text((tx, ty), "remembering.", font=display, fill=hex_to_rgba(PALETTE["ink"]))
    ty += round(phone_w * 0.15)
    draw.rounded_rectangle((tx, ty, card[2] - round(phone_w * 0.055), ty + 5), radius=3, fill=hex_to_rgba(PALETTE["crema"]))
    ty += round(phone_w * 0.075)
    draw.text((tx, ty), "18.0g   36g   28s", font=stat, fill=hex_to_rgba(PALETTE["espresso"]))
    ty += round(phone_w * 0.116)
    draw.text((tx, ty), "Balanced / sweet", font=small, fill=hex_to_rgba(PALETTE["ink_soft"]))
    draw.text((tx, card[3] - round(phone_w * 0.12)), "Coffii", font=small_bold, fill=hex_to_rgba(PALETTE["ink_soft"]))

    rotated = phone.rotate(-7, resample=Image.Resampling.BICUBIC, expand=True)
    shadow = Image.new("RGBA", rotated.size, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle(
        (18, 30, rotated.width - 20, rotated.height - 12),
        radius=round(phone_w * 0.12),
        fill=(44, 32, 24, 70),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(18))
    x = base.width - rotated.width - margin_right
    y = base.height - rotated.height - margin_bottom
    base.alpha_composite(shadow, (x + 12, y + 18))
    base.alpha_composite(rotated, (x, y))


def draw_overlay(img: Image.Image, slide: dict[str, object], format_name: str) -> Image.Image:
    out = img.convert("RGBA")
    draw = ImageDraw.Draw(out)
    w, h = out.size

    if slide.get("phone"):
        draw_phone_mockup(out, format_name)

    if format_name == "9x16":
        x, y = 86, 170
        max_width = 760
        eyebrow_font = font(FONT_UTILITY, 30)
        headline_font = font(FONT_DISPLAY, 76)
        footer_font = font(FONT_UTILITY, 30)
        line_gap = 14
    else:
        x, y = 74, 96
        max_width = 760
        eyebrow_font = font(FONT_UTILITY, 25)
        headline_font = font(FONT_DISPLAY, 63)
        footer_font = font(FONT_UTILITY, 25)
        line_gap = 10

    tracked_text(
        draw,
        (x, y),
        str(slide["eyebrow"]).upper(),
        eyebrow_font,
        hex_to_rgba(PALETTE["ink_soft"]),
        2,
    )
    y += round(eyebrow_font.size * 1.58)

    lines = wrap_lines(draw, str(slide["headline"]), headline_font, max_width)
    while len(lines) > 4 and headline_font.size > 48:
        headline_font = font(FONT_DISPLAY, headline_font.size - 4)
        lines = wrap_lines(draw, str(slide["headline"]), headline_font, max_width)

    for line in lines:
        draw.text((x, y), line, font=headline_font, fill=hex_to_rgba(PALETTE["ink"]))
        y += headline_font.size + line_gap

    hair_y = y + (10 if format_name == "9x16" else 4)
    draw.line((x, hair_y, x + 118, hair_y), fill=hex_to_rgba(PALETTE["line"]), width=2)

    footer = str(slide.get("footer", "Coffii"))
    footer_w = text_size(draw, footer, footer_font)[0]
    footer_y = h - (236 if format_name == "9x16" else 96)
    footer_x = x if slide.get("phone") else (w - footer_w) / 2
    draw.text((footer_x, footer_y), footer, font=footer_font, fill=hex_to_rgba(PALETTE["ink_soft"]))
    return out.convert("RGB")


def export_slide(slide: dict[str, object]) -> dict[str, str]:
    source_path = SOURCE / str(slide["file"])
    src = Image.open(source_path).convert("RGB")
    stem = source_path.stem
    exported: dict[str, str] = {}

    for format_name, size, out_dir in (
        ("4x5", (1080, 1350), OUT_4X5),
        ("9x16", (1080, 1920), OUT_9X16),
    ):
        carousel_dir = out_dir / f"carousel-{slide['carousel']}"
        carousel_dir.mkdir(parents=True, exist_ok=True)
        cropped = cover_crop(src, size, float(slide.get("focal_y", 0.55)))
        rendered = draw_overlay(cropped, slide, format_name)
        out_path = carousel_dir / f"{stem}-{format_name}.png"
        rendered.save(out_path, optimize=True)
        exported[format_name] = str(out_path.relative_to(ROOT))
    return exported


def make_contact_sheets() -> None:
    CONTACT.mkdir(parents=True, exist_ok=True)
    for carousel in sorted({str(slide["carousel"]) for slide in SLIDES}):
        slides = [slide for slide in SLIDES if str(slide["carousel"]) == carousel]
        for format_name, folder, thumb_w in (("4x5", OUT_4X5, 220), ("9x16", OUT_9X16, 180)):
            thumbs = []
            for slide in slides:
                path = folder / f"carousel-{carousel}" / f"{Path(str(slide['file'])).stem}-{format_name}.png"
                img = Image.open(path).convert("RGB")
                thumb_h = round(img.height * (thumb_w / img.width))
                img = img.resize((thumb_w, thumb_h), Image.LANCZOS)
                thumbs.append(img)

            gap = 16
            label_h = 46
            sheet_w = gap + len(thumbs) * (thumb_w + gap)
            sheet_h = max(img.height for img in thumbs) + label_h + gap * 2
            sheet = Image.new("RGB", (sheet_w, sheet_h), PALETTE["paper"])
            draw = ImageDraw.Draw(sheet)
            label_font = font(FONT_UTILITY, 18)
            title = f"Carousel {carousel} / {format_name}"
            draw.text((gap, 14), title, font=label_font, fill=PALETTE["ink_soft"])
            x = gap
            y = label_h
            for index, img in enumerate(thumbs, start=1):
                sheet.paste(img, (x, y))
                draw.text((x, y + img.height + 5), f"{index:02d}", font=label_font, fill=PALETTE["ink_soft"])
                x += thumb_w + gap
            sheet.save(CONTACT / f"carousel-{carousel}-{format_name}.jpg", quality=92)


def main() -> None:
    for directory in (OUT_4X5, OUT_9X16, CONTACT):
        directory.mkdir(parents=True, exist_ok=True)

    manifest = []
    for slide in SLIDES:
        exported = export_slide(slide)
        manifest.append(
            {
                "carousel": slide["carousel"],
                "carousel_title": slide["title"],
                "slide": slide["slide"],
                "source": f"source/{slide['file']}",
                "eyebrow": slide["eyebrow"],
                "headline": slide["headline"],
                "footer": slide.get("footer", "Coffii"),
                "exports": exported,
            }
        )

    make_contact_sheets()
    (ROOT / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")


if __name__ == "__main__":
    main()
