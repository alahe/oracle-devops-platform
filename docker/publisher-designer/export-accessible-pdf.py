#!/usr/bin/env python3
# ==============================================================================
# Oracle Analytics Publisher Accessible PDF/UA & Tagged PDF Exporter
# Generates PDF/UA-1 (ISO 14289-1) compliant, Tagged PDF with semantic structure,
# document language, accessible table headers, and metadata for screen readers.
# Supports 6 Nordic-Baltic Languages: EN, ET, FI, SV, LV, LT
# ==============================================================================
import sys
import os
import argparse
import subprocess
import time
import socket

def find_free_port():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(('', 0))
        return s.getsockname()[1]

def export_accessible_pdf(in_file, out_pdf, locale="et", title=None):
    locale = locale.lower()[:2]
    loc_map = {
        "et": ("et", "EE", "Arve (PDF/UA)"),
        "en": ("en", "US", "Invoice (PDF/UA)"),
        "fi": ("fi", "FI", "Lasku (PDF/UA)"),
        "sv": ("sv", "SE", "Faktura (PDF/UA)"),
        "lv": ("lv", "LV", "Rēķins (PDF/UA)"),
        "lt": ("lt", "LT", "Sąskaita faktūra (PDF/UA)"),
    }
    lang_code, country_code, default_title = loc_map.get(locale, ("et", "EE", "Arve (PDF/UA)"))
    doc_title = title if title else default_title

    tmp_dir = subprocess.check_output(["mktemp", "-d"]).decode().strip()
    try:
        # 1. Convert input document (RTF, HTML, DOCX) to ODT if not already ODT
        ext = os.path.splitext(in_file)[1].lower()
        if ext == ".odt":
            work_odt = in_file
        else:
            conv_cmd = [
                "libreoffice",
                f"-env:UserInstallation=file://{tmp_dir}/prof_conv",
                "--headless",
                "--convert-to", "odt",
                in_file,
                "--outdir", tmp_dir
            ]
            subprocess.run(conv_cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            base_name = os.path.splitext(os.path.basename(in_file))[0]
            work_odt = os.path.join(tmp_dir, f"{base_name}.odt")

        if not os.path.isfile(work_odt):
            raise FileNotFoundError(f"Failed to produce intermediate ODT: {work_odt}")

        # 2. Launch headless soffice with isolated user profile & unique port
        port = find_free_port()
        prof_dir = os.path.join(tmp_dir, "prof_uno")
        soffice_cmd = [
            "libreoffice",
            "--headless",
            "--invisible",
            "--nocrashreport",
            "--nodefault",
            "--nologo",
            "--nofirststartwizard",
            "--norestore",
            f"-env:UserInstallation=file://{prof_dir}",
            f"--accept=socket,host=127.0.0.1,port={port};urp;"
        ]
        proc = subprocess.Popen(soffice_cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        try:
            import uno
            from com.sun.star.beans import PropertyValue
            from com.sun.star.lang import Locale

            # Connect to UNO bridge with retry
            desktop = None
            for _ in range(25):
                try:
                    local_ctx = uno.getComponentContext()
                    smgr = local_ctx.ServiceManager
                    resolver = smgr.createInstanceWithContext("com.sun.star.bridge.UnoUrlResolver", local_ctx)
                    ctx = resolver.resolve(f"uno:socket,host=127.0.0.1,port={port};urp;StarOffice.ComponentContext")
                    desktop = ctx.ServiceManager.createInstanceWithContext("com.sun.star.frame.Desktop", ctx)
                    if desktop:
                        break
                except Exception:
                    time.sleep(0.15)

            if not desktop:
                raise RuntimeError(f"Could not connect to LibreOffice UNO bridge on port {port}")

            in_url = uno.systemPathToFileUrl(os.path.abspath(work_odt))
            out_url = uno.systemPathToFileUrl(os.path.abspath(out_pdf))

            # Load ODT document
            load_props = (PropertyValue(Name="Hidden", Value=True),)
            doc = desktop.loadComponentFromURL(in_url, "_blank", 0, load_props)
            if not doc:
                raise RuntimeError(f"Failed to load component from URL: {in_url}")

            # 3. Configure Document Properties for Screen Readers (Title, Subject, Language)
            try:
                props = doc.getDocumentProperties()
                props.Title = doc_title
                props.Subject = f"Oracle Analytics Publisher Pixel-Perfect Template ({locale.upper()})"
                props.Author = "Oracle DevOps Platform"

                doc_loc = Locale()
                doc_loc.Language = lang_code
                doc_loc.Country = country_code
                props.Language = doc_loc
            except Exception as pe:
                print(f"⚠️ Warning: Could not set document properties: {pe}", file=sys.stderr)

            # 4. Export with PDF/UA-1 and Tagged PDF compliance
            filter_data = [
                PropertyValue(Name="UseTaggedPDF", Value=True),
                PropertyValue(Name="PDFUACompliance", Value=True),
                PropertyValue(Name="ExportFormFields", Value=True),
                PropertyValue(Name="SelectPdfVersion", Value=0),
            ]
            store_props = (
                PropertyValue(Name="FilterName", Value="writer_pdf_Export"),
                PropertyValue(Name="FilterData", Value=uno.Any("[]com.sun.star.beans.PropertyValue", tuple(filter_data)))
            )

            os.makedirs(os.path.dirname(os.path.abspath(out_pdf)), exist_ok=True)
            doc.storeToURL(out_url, store_props)
            doc.close(True)

            print(f"✅ Accessible Tagged PDF (PDF/UA) generated: {out_pdf} [Lang: {lang_code}-{country_code}]")
            return 0
        finally:
            proc.terminate()
            proc.wait()
    except Exception as e:
        print(f"❌ Error during accessible PDF export: {e}", file=sys.stderr)
        # Fallback to standard headless export if UNO failed
        print("⚡ Falling back to standard headless export...", file=sys.stderr)
        cmd = ["libreoffice", "--headless", "--convert-to", "pdf", in_file, "--outdir", os.path.dirname(out_pdf)]
        subprocess.run(cmd, check=True)
        return 1
    finally:
        subprocess.run(["rm", "-rf", tmp_dir], check=False)

def main():
    parser = argparse.ArgumentParser(description="Export document to Accessible Tagged PDF (PDF/UA)")
    parser.add_argument("input", help="Path to input document (.rtf, .odt, etc.)")
    parser.add_argument("output", help="Path to output .pdf")
    parser.add_argument("--locale", "-l", default="et", help="Document locale (et, en, fi, sv, lv, lt)")
    parser.add_argument("--title", "-t", default=None, help="Document title for screen readers")
    args = parser.parse_args()

    sys.exit(export_accessible_pdf(args.input, args.output, args.locale, args.title))

if __name__ == "__main__":
    main()
