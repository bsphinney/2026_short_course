#!/usr/bin/env python3
"""
make-slips-pdf.py -- all 30 credential slips as ONE printable PDF.

RUN THIS ON HIVE, as yourself:
    python3 make-slips-pdf.py

Accepts either the credential file or a folder of slips from
make-student-slips.sh, and writes ~/student-slips.pdf: two cards per
page, a dashed line to cut along, 15 pages for 30 students. Print it, cut, hand
one to each student.

WHY IT WRITES THE PDF BY HAND
-----------------------------
HIVE has no PDF tooling whatsoever -- no wkhtmltopdf, weasyprint, chromium,
libreoffice, pandoc, ghostscript, reportlab or fpdf. Rather than ask for an
install on a shared cluster, this emits the PDF directly: it is a text-based
format, and using only the 14 built-in fonts means nothing has to be embedded.
Python's standard library is therefore the whole dependency list.

Nothing is printed to the screen but counts, so no password lands in your
terminal scrollback.
"""
import os, sys

PW, PH = 612.0, 792.0          # US Letter, points
MARGIN = 40.0
CARDS_PER_PAGE = 2


def esc(s):
    """Escape for a PDF literal string, and drop anything outside the base
    font's encoding so a stray character cannot corrupt the page."""
    out = []
    for ch in str(s):
        if ch in "()\\":
            out.append("\\" + ch)
        elif 32 <= ord(ch) < 127:
            out.append(ch)
        else:
            out.append("?")          # non-ASCII would need an embedded font
    return "".join(out)


def card(x, y, w, h, user, pw, course):
    """One student's card, drawn downward from (x, y). Returns a content stream."""
    c = []
    c.append("q 0.90 0.88 0.85 RG 0.7 w")
    c.append(f"{x:.1f} {y-h:.1f} {w:.1f} {h:.1f} re S Q")

    tx = x + 18
    ty = y - 26
    c.append("BT /HB 11.5 Tf 0.11 0.10 0.09 rg "
             f"1 0 0 1 {tx:.1f} {ty:.1f} Tm ({esc('Proteomics Short Course 2026 - your Hive account')}) Tj ET")
    ty -= 14
    c.append("BT /H 8.5 Tf 0.42 0.40 0.36 rg "
             f"1 0 0 1 {tx:.1f} {ty:.1f} Tm ({esc('These are yours alone. Please do not share them.')}) Tj ET")

    # credential block — the part that has to be unmistakable
    ty -= 16
    bh = 46
    c.append("q 0.97 0.955 0.93 rg")
    c.append(f"{tx:.1f} {ty-bh:.1f} {w-36:.1f} {bh:.1f} re f Q")
    c.append("q 0.90 0.88 0.85 RG 0.6 w")
    c.append(f"{tx:.1f} {ty-bh:.1f} {w-36:.1f} {bh:.1f} re S Q")
    ly = ty - 17
    for label, value in (("Username", user), ("Password", pw)):
        c.append("BT /H 8.5 Tf 0.42 0.40 0.36 rg "
                 f"1 0 0 1 {tx+10:.1f} {ly:.1f} Tm ({esc(label)}) Tj ET")
        c.append("BT /CB 11.5 Tf 0.11 0.10 0.09 rg "
                 f"1 0 0 1 {tx+68:.1f} {ly:.1f} Tm ({esc(value)}) Tj ET")
        ly -= 18
    ty -= bh + 16

    lines = [
        ("H",  9,   "1. Open PowerShell (Windows) or Terminal (Mac) and connect:"),
        ("C",  8.5, f"     ssh {user}@hive.hpc.ucdavis.edu"),
        ("H",  8,   "   Nothing appears as you type the password - no dots, no stars. That is normal."),
        ("H",  9,   "2. Start Claude Code:"),
        ("C",  8.5, f"     bash {course}/start-claude.sh"),
        ("H",  8,   "   After the first time, just type:  claude-course"),
        ("H",  8.5, "No API key, nothing to install on your own computer. The handout covers the rest."),
        ("HB", 8.5, "Your account is switched off when the course ends - copy your work before then."),
    ]
    for font, size, text in lines:
        grey = "0.42 0.40 0.36 rg" if size <= 8 else "0.11 0.10 0.09 rg"
        c.append(f"BT /{font} {size} Tf {grey} 1 0 0 1 {tx:.1f} {ty:.1f} Tm ({esc(text)}) Tj ET")
        ty -= (size + 4.5)
    return "\n".join(c)


def build(students, course):
    gap = 18.0
    ch = (PH - 2 * MARGIN - gap) / CARDS_PER_PAGE
    cw = PW - 2 * MARGIN

    pages = []
    for i in range(0, len(students), CARDS_PER_PAGE):
        chunk = students[i:i + CARDS_PER_PAGE]
        parts = []
        for j, (user, pw) in enumerate(chunk):
            top = PH - MARGIN - j * (ch + gap)
            parts.append(card(MARGIN, top, cw, ch, user, pw, course))
            if j == 0 and len(chunk) > 1:
                cy = top - ch - gap / 2
                parts.append("q 0.75 0.73 0.70 RG 0.6 w [4 3] 0 d "
                             f"{MARGIN:.1f} {cy:.1f} m {PW-MARGIN:.1f} {cy:.1f} l S Q")
                parts.append("BT /H 7 Tf 0.55 0.53 0.50 rg "
                             f"1 0 0 1 {PW/2-16:.1f} {cy+3:.1f} Tm (cut here) Tj ET")
        pages.append("\n".join(parts))
    return pages


def write_pdf(pages, path):
    """Assemble the file. Objects are numbered as they are appended, and the
    xref table needs each one's exact byte offset, so the buffer is built once
    and measured as it goes."""
    fonts = {"H": "Helvetica", "HB": "Helvetica-Bold", "C": "Courier", "CB": "Courier-Bold"}
    objs, out = [], bytearray()

    def add(body):
        objs.append(len(out) + 0)      # placeholder; real offset set on write
        return len(objs)

    # Build object bodies first, then lay them out.
    bodies = []
    font_ids = {}
    n = 2 + len(pages) * 2             # 1 catalog, 2 pages node, then page+stream pairs
    for k, base in fonts.items():
        n += 1
        font_ids[k] = n
        bodies.append((n, f"<< /Type /Font /Subtype /Type1 /BaseFont /{base} "
                          f"/Encoding /WinAnsiEncoding >>".encode()))

    fref = " ".join(f"/{k} {v} 0 R" for k, v in font_ids.items())
    kids = " ".join(f"{3 + 2*i} 0 R" for i in range(len(pages)))
    bodies.insert(0, (1, b"<< /Type /Catalog /Pages 2 0 R >>"))
    bodies.insert(1, (2, f"<< /Type /Pages /Count {len(pages)} /Kids [{kids}] >>".encode()))

    for i, content in enumerate(pages):
        pid, sid = 3 + 2*i, 4 + 2*i
        bodies.insert(2 + 2*i,
            (pid, (f"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 {PW} {PH}] "
                   f"/Resources << /Font << {fref} >> >> /Contents {sid} 0 R >>").encode()))
        data = content.encode("latin-1", "replace")
        bodies.insert(3 + 2*i,
            (sid, b"<< /Length " + str(len(data)).encode() + b" >>\nstream\n" + data + b"\nendstream"))

    bodies.sort(key=lambda t: t[0])
    out += b"%PDF-1.4\n%\xe2\xe3\xcf\xd3\n"
    offsets = {}
    for num, body in bodies:
        offsets[num] = len(out)
        out += f"{num} 0 obj\n".encode() + body + b"\nendobj\n"

    xref = len(out)
    total = max(offsets) + 1
    out += f"xref\n0 {total}\n".encode()
    out += b"0000000000 65535 f \n"
    for i in range(1, total):
        out += f"{offsets.get(i, 0):010d} 00000 n \n".encode()
    out += (f"trailer\n<< /Size {total} /Root 1 0 R >>\nstartxref\n{xref}\n%%EOF\n").encode()

    with open(path, "wb") as fh:
        fh.write(out)
    os.chmod(path, 0o600)
    return len(out)


def main():
    creds = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser("~/proteomics-class-users.txt")
    out   = sys.argv[2] if len(sys.argv) > 2 else os.path.expanduser("~/student-slips.pdf")
    course = "/quobyte/proteomics-grp/2026_shortcourse_data"

    if not (os.path.isfile(creds) or os.path.isdir(creds)):
        sys.exit(f"cannot read {creds}")

    students = []
    if os.path.isdir(creds):
        # A folder of slips written by make-student-slips.sh. Handy when the slips
        # have already been pulled down and the credential file has not.
        import glob, re
        for fn in sorted(glob.glob(os.path.join(creds, "*.txt"))):
            txt = open(fn, encoding="utf-8", errors="replace").read()
            u = re.search(r"^\s*Username:\s*(\S+)", txt, re.M)
            w = re.search(r"^\s*Password:\s*(\S+)", txt, re.M)
            if u and w:
                students.append((u.group(1), w.group(1)))
    else:
        with open(creds) as fh:
            for line in fh:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                f = line.split()
                if len(f) >= 2:
                    students.append((f[0], f[1]))
    if not students:
        sys.exit(f"no username/password pairs found in {creds}")

    pages = build(students, course)
    size = write_pdf(pages, out)

    print(f"wrote {out}")
    print(f"  students   : {len(students)}")
    print(f"  pages      : {len(pages)}  ({CARDS_PER_PAGE} per page, cut line between)")
    print(f"  size       : {size/1024:.0f} KB")
    print(f"  permissions: 600 (only you)")
    print()
    print("Bring it to your own computer with:")
    print(f"  scp {os.environ.get('USER','brettsp')}@hive.hpc.ucdavis.edu:{os.path.basename(out)} .")


if __name__ == "__main__":
    main()
