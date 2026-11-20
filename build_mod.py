from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo


def build_mod() -> Path:
    root = Path(__file__).resolve().parent
    source = root / "mod"
    target = root / "dist" / "Daytona_Race_Control.zip"
    files = sorted(path for path in source.rglob("*") if path.is_file())
    if not files:
        raise FileNotFoundError(f"Missing mod source in {source}")

    target.parent.mkdir(exist_ok=True)
    temp = target.with_suffix(".tmp")
    with ZipFile(temp, "w") as archive:
        for path in files:
            entry = ZipInfo(path.relative_to(source).as_posix())
            archive.writestr(entry, path.read_bytes(), compress_type=ZIP_DEFLATED, compresslevel=9)
    temp.replace(target)
    return target


if __name__ == "__main__":
    print(build_mod())
