"""Publish a stable entry page backed by commit-specific Godot assets."""
import pathlib
import re
import sys

page_path = pathlib.Path(sys.argv[1])
version = sys.argv[2]
if not re.fullmatch(r"[0-9a-f]{7,40}", version):
    raise SystemExit("Build version must be a Git commit SHA")
for suffix in (".js", ".wasm", ".pck"):
    asset = page_path.with_suffix(suffix)
    if not asset.is_file() or not asset.stat().st_size:
        raise SystemExit(f"Missing exported asset: {asset}")
page = page_path.read_text()
if page_path.with_suffix(".js").name not in page or page_path.stem not in page:
    raise SystemExit("Exported page does not reference its versioned assets")
badge = (
    '<div id="build-version" style="position:fixed;bottom:4px;right:8px;'
    'z-index:10;pointer-events:none;color:#bacbd2;background:#101820;'
    'padding:3px 6px;font:12px monospace">Build ' + version + '</div>'
)
if "</body>" not in page:
    raise SystemExit("Exported page has no closing body")
page = page.replace("</body>", badge + "\n</body>")
page_path.write_text(page)
(page_path.parent / "index.html").write_text(page)
print(f"Published build {version}: {page_path.name} and index.html")
