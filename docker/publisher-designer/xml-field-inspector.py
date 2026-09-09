#!/usr/bin/env python3
"""
Oracle Analytics / BI Publisher XML Field Inspector & Tag Builder
Interactive GUI & CLI tool to browse XML data, generate authentic Oracle XDO tags,
and inject them directly into active LibreOffice Writer sessions via xdotool / clipboard.
Supports 6 Nordic-Baltic Languages: 🇬🇧 EN, 🇪🇪 ET, 🇫🇮 FI, 🇸🇪 SV, 🇱🇻 LV, 🇱🇹 LT.
"""

import sys
import os
import json
import argparse
import subprocess
import xml.etree.ElementTree as ET

try:
    import tkinter as tk
    from tkinter import ttk, messagebox
    HAS_TK = True
except ImportError:
    HAS_TK = False

# 6-Language UI Translations
I18N = {
    'en': {
        'win_title': "Oracle BI Publisher - XML Field Inspector",
        'header_title': "🏷️ Oracle BI Publisher Field Inspector",
        'file_info': "Data file: {filename} ({count} fields)",
        'search_lbl': "Filter fields:",
        'col_path': "Oracle XML Field (XPath)",
        'col_sample': "Sample Value",
        'frame_actions': "Tag Insertion into LibreOffice Writer",
        'btn_insert': "👉 Insert at Cursor",
        'btn_copy': "📋 Copy Tag",
        'btn_foreach': "🔁 Wrap for-each",
        'btn_if': "❓ Add IF Condition",
        'btn_num': "🔢 Format Number",
        'btn_date': "📅 Format Date",
        'btn_render': "⚡ Fast-Render PDF",
        'status_ready': "Select a field from the list and click an action.",
        'status_inserted': "✅ Inserted: {tag}...",
        'status_copied': "📋 Copied to clipboard: {tag}",
        'status_rendering': "⚡ Launching PDF renderer (Locale: {lang})...",
        'status_success': "🎉 PDF Successfully generated: {filename}",
        'status_error': "❌ Error rendering PDF!",
        'warn_no_field': "Please select a field from the list first!",
        'rep_indicator': "(Repeating Group / List)",
        'row_label': "[Table row: {path}]",
        'display_content': "[Displayed content]",
        'frame_a11y': "♿ Accessibility & Compliance (PDF/UA-1)",
        'btn_check_a11y': "🔍 Audit Accessibility",
        'btn_speech_sim': "♿ Screen Reader View",
        'a11y_status_clean': "🟢 Accessibility: Clean / Compliant",
        'a11y_status_warn': "🟡 Accessibility: Warnings detected",
        'a11y_status_error': "🔴 Accessibility: Non-compliant",
        'a11y_status_unknown': "⚪ Accessibility: Not audited yet",
        'dialog_a11y_title': "Accessibility Audit & Fix Recipes",
        'dialog_speech_title': "Simulated Screen Reader Transcript",
        'btn_copy_transcript': "📋 Copy Transcript",
        'btn_close': "Close"
    },
    'et': {
        'win_title': "Oracle BI Publisher - XML Väljade Inspektor",
        'header_title': "🏷️ Oracle BI Publisher Väljade Inspektor",
        'file_info': "Andmefail: {filename} ({count} välja)",
        'search_lbl': "Otsi välja:",
        'col_path': "Oracle XML Väli (XPath)",
        'col_sample': "Näidisväärtus",
        'frame_actions': "Tagide Lisamine LibreOffice'isse",
        'btn_insert': "👉 Sisesta Kursorisse",
        'btn_copy': "📋 Kopeeri Tag",
        'btn_foreach': "🔁 Wrap for-each",
        'btn_if': "❓ Lisa IF Tingimus",
        'btn_num': "🔢 Vorminda Summa",
        'btn_date': "📅 Vorminda Kuupäev",
        'btn_render': "⚡ Kiir-Renderda PDF",
        'status_ready': "Vali väli nimekirjast ja klõpsa nupule.",
        'status_inserted': "✅ Sisestatud: {tag}...",
        'status_copied': "📋 Kopeeritud lõikelauale: {tag}",
        'status_rendering': "⚡ Käivitan PDF renderdajat (Keel: {lang})...",
        'status_success': "🎉 PDF Edukalt genereeritud: {filename}",
        'status_error': "❌ Viga PDF renderdamisel!",
        'warn_no_field': "Palun vali nimekirjast esmalt väli!",
        'rep_indicator': "(Kordusplokk / Grupp)",
        'row_label': "[Tabeli rida: {path}]",
        'display_content': "[Näidatav sisu]",
        'frame_a11y': "♿ Ligipääsetavus ja Vastavus (PDF/UA-1)",
        'btn_check_a11y': "🔍 Kontrolli Ligipääsetavust",
        'btn_speech_sim': "♿ Ekraanilugeja Vaade",
        'a11y_status_clean': "🟢 Ligipääsetavus: Nõuetele vastav",
        'a11y_status_warn': "🟡 Ligipääsetavus: Hoiatused",
        'a11y_status_error': "🔴 Ligipääsetavus: Mittenõuetekohane",
        'a11y_status_unknown': "⚪ Ligipääsetavus: Kontrollimata",
        'dialog_a11y_title': "Ligipääsetavuse Audit ja Parandusjuhised",
        'dialog_speech_title': "Simuleeritud Ekraanilugeja Transkriptsioon",
        'btn_copy_transcript': "📋 Kopeeri Transkriptsioon",
        'btn_close': "Sulge"
    },
    'fi': {
        'win_title': "Oracle BI Publisher - XML-kenttien Tarkastaja",
        'header_title': "🏷️ Oracle BI Publisher Kenttätarkastaja",
        'file_info': "Datatiedosto: {filename} ({count} kenttää)",
        'search_lbl': "Suodata kenttiä:",
        'col_path': "Oracle XML -kenttä (XPath)",
        'col_sample': "Esimerkkisarvo",
        'frame_actions': "Tunnisteiden lisäys LibreOfficeen",
        'btn_insert': "👉 Lisää kursoriin",
        'btn_copy': "📋 Kopioi tunniste",
        'btn_foreach': "🔁 Wrap for-each",
        'btn_if': "❓ Lisää IF-ehto",
        'btn_num': "🔢 Muotoile luku",
        'btn_date': "📅 Muotoile päivämäärä",
        'btn_render': "⚡ Pika-Renderöi PDF",
        'status_ready': "Valitse kenttä luettelosta ja napsauta toimintoa.",
        'status_inserted': "✅ Lisätty: {tag}...",
        'status_copied': "📋 Kopioitu leikepöydälle: {tag}",
        'status_rendering': "⚡ Käynnistetään PDF-renderöinti (Kieli: {lang})...",
        'status_success': "🎉 PDF Luotu onnistuneesti: {filename}",
        'status_error': "❌ Virhe PDF-renderöinnissä!",
        'warn_no_field': "Valitse ensin kenttä luettelosta!",
        'rep_indicator': "(Toistolohko / Ryhmä)",
        'row_label': "[Taulukkorivi: {path}]",
        'display_content': "[Näytettävä sisältö]",
        'frame_a11y': "♿ Saavutettavuus ja Vaatimustenmukaisuus (PDF/UA-1)",
        'btn_check_a11y': "🔍 Tarkista saavutettavuus",
        'btn_speech_sim': "♿ Ruudunluku-näkymä",
        'a11y_status_clean': "🟢 Saavutettavuus: Vaatimustenmukainen",
        'a11y_status_warn': "🟡 Saavutettavuus: Varoituksia havaittu",
        'a11y_status_error': "🔴 Saavutettavuus: Ei vaatimustenmukainen",
        'a11y_status_unknown': "⚪ Saavutettavuus: Ei vielä tarkistettu",
        'dialog_a11y_title': "Saavutettavuusauditointi ja Korjausohjeet",
        'dialog_speech_title': "Simuloitu Ruudunlukijan Transkriptio",
        'btn_copy_transcript': "📋 Kopioi Transkriptio",
        'btn_close': "Sulje"
    },
    'sv': {
        'win_title': "Oracle BI Publisher - XML Fältgranskare",
        'header_title': "🏷️ Oracle BI Publisher Fältgranskare",
        'file_info': "Datafil: {filename} ({count} fält)",
        'search_lbl': "Filtrera fält:",
        'col_path': "Oracle XML-fält (XPath)",
        'col_sample': "Exempelvärde",
        'frame_actions': "Infoga taggar i LibreOffice Writer",
        'btn_insert': "👉 Infoga vid markör",
        'btn_copy': "📋 Kopiera tagg",
        'btn_foreach': "🔁 Wrap for-each",
        'btn_if': "❓ Lägg till IF-villkor",
        'btn_num': "🔢 Formatera tal",
        'btn_date': "📅 Formatera datum",
        'btn_render': "⚡ Snabb-rendera PDF",
        'status_ready': "Välj ett fält i listan och klicka på en åtgärd.",
        'status_inserted': "✅ Infogad: {tag}...",
        'status_copied': "📋 Kopierad till urklipp: {tag}",
        'status_rendering': "⚡ Startar PDF-rendering (Språk: {lang})...",
        'status_success': "🎉 PDF Genererad framgångsrikt: {filename}",
        'status_error': "❌ Fel vid PDF-rendering!",
        'warn_no_field': "Välj ett fält i listan först!",
        'rep_indicator': "(Upprepningsgrupp / Lista)",
        'row_label': "[Tabellrad: {path}]",
        'display_content': "[Innehåll som visas]",
        'frame_a11y': "♿ Tillgänglighet & Efterlevnad (PDF/UA-1)",
        'btn_check_a11y': "🔍 Kontrollera tillgänglighet",
        'btn_speech_sim': "♿ Skärmläsarvy",
        'a11y_status_clean': "🟢 Tillgänglighet: Förenlig",
        'a11y_status_warn': "🟡 Tillgänglighet: Varningar identifierade",
        'a11y_status_error': "🔴 Tillgänglighet: Ej förenlig",
        'a11y_status_unknown': "⚪ Tillgänglighet: Inte kontrollerad än",
        'dialog_a11y_title': "Tillgänglighetsrevision & Åtgärdsförslag",
        'dialog_speech_title': "Simulerad Skärmläsartranskription",
        'btn_copy_transcript': "📋 Kopiera Transkription",
        'btn_close': "Stäng"
    },
    'lv': {
        'win_title': "Oracle BI Publisher - XML Lauku Inspektors",
        'header_title': "🏷️ Oracle BI Publisher Lauku Inspektors",
        'file_info': "Datu fails: {filename} ({count} lauki)",
        'search_lbl': "Filtrēt laukus:",
        'col_path': "Oracle XML lauks (XPath)",
        'col_sample': "Parauga vērtība",
        'frame_actions': "Tagu ievietošana LibreOffice Writer",
        'btn_insert': "👉 Ievietot pie kursora",
        'btn_copy': "📋 Kopēt tagu",
        'btn_foreach': "🔁 Wrap for-each",
        'btn_if': "❓ Pievienot IF nosacījumu",
        'btn_num': "🔢 Formatēt skaitli",
        'btn_date': "📅 Formatēt datumu",
        'btn_render': "⚡ Ātrā PDF renderēšana",
        'status_ready': "Izvēlieties lauku no saraksta un noklikšķiniet uz darbības.",
        'status_inserted': "✅ Ievietots: {tag}...",
        'status_copied': "📋 Kopēts starpliktuvē: {tag}",
        'status_rendering': "⚡ Palaiž PDF renderēšanu (Valoda: {lang})...",
        'status_success': "🎉 PDF Veiksmīgi ģenerēts: {filename}",
        'status_error': "❌ Kļūda PDF renderēšanā!",
        'warn_no_field': "Lūdzu, vispirms izvēlieties lauku no saraksta!",
        'rep_indicator': "(Atkārtošanās grupa / Saraksts)",
        'row_label': "[Tabulas rinda: {path}]",
        'display_content': "[Parādāmais saturs]",
        'frame_a11y': "♿ Piekļūstamība un Atbilstība (PDF/UA-1)",
        'btn_check_a11y': "🔍 Pārbaudīt piekļūstamību",
        'btn_speech_sim': "♿ Ekrānlasītāja skats",
        'a11y_status_clean': "🟢 Piekļūstamība: Atbilstoša",
        'a11y_status_warn': "🟡 Piekļūstamība: Konstatēti brīdinājumi",
        'a11y_status_error': "🔴 Piekļūstamība: Neatbilstoša",
        'a11y_status_unknown': "⚪ Piekļūstamība: Vēl nav pārbaudīta",
        'dialog_a11y_title': "Piekļūstamības audits un Labojumu receptes",
        'dialog_speech_title': "Imitēta Ekrānlasītāja Transkripcija",
        'btn_copy_transcript': "📋 Kopēt Transkripciju",
        'btn_close': "Aizvērt"
    },
    'lt': {
        'win_title': "Oracle BI Publisher - XML Laukų Inspektorius",
        'header_title': "🏷️ Oracle BI Publisher Laukų Inspektorius",
        'file_info': "Duomenų failas: {filename} ({count} laukai)",
        'search_lbl': "Filtruoti laukus:",
        'col_path': "Oracle XML laukas (XPath)",
        'col_sample': "Pavyzdinė reikšmė",
        'frame_actions': "Žymų įterpimas į LibreOffice Writer",
        'btn_insert': "👉 Įterpti ties žymekliu",
        'btn_copy': "📋 Kopijuoti žymą",
        'btn_foreach': "🔁 Wrap for-each",
        'btn_if': "❓ Pridėti IF sąlygą",
        'btn_num': "🔢 Formatuoti skaičių",
        'btn_date': "📅 Formatuoti datą",
        'btn_render': "⚡ Greitas PDF generavimas",
        'status_ready': "Pasirinkite lauką iš sąrašo ir spustelėkite veiksmą.",
        'status_inserted': "✅ Įterpta: {tag}...",
        'status_copied': "📋 Nukopijuota į iškarpinę: {tag}",
        'status_rendering': "⚡ Paleidžiamas PDF generavimas (Kalba: {lang})...",
        'status_success': "🎉 PDF Sėkmingai sugeneruotas: {filename}",
        'status_error': "❌ Klaida generuojant PDF!",
        'warn_no_field': "Pirmiausia pasirinkite lauką iš sąrašo!",
        'rep_indicator': "(Pasikartojanti grupė / Sąrašas)",
        'row_label': "[Lentelės eilutė: {path}]",
        'display_content': "[Rodomas turinys]",
        'frame_a11y': "♿ Prieinamumas ir Atitiktis (PDF/UA-1)",
        'btn_check_a11y': "🔍 Tikrinti prieinamumą",
        'btn_speech_sim': "♿ Ekrano skaitytuvo rodinys",
        'a11y_status_clean': "🟢 Prieinamumas: Atitinka reikalavimus",
        'a11y_status_warn': "🟡 Prieinamumas: Rasta įspėjimų",
        'a11y_status_error': "🔴 Prieinamumas: Neatitinka",
        'a11y_status_unknown': "⚪ Prieinamumas: Dar netikrinta",
        'dialog_a11y_title': "Prieinamumo auditas ir Taisymo instrukcijos",
        'dialog_speech_title': "Imituota Ekrano Skaitytuvo Transkripcija",
        'btn_copy_transcript': "📋 Kopijuoti Transkripciją",
        'btn_close': "Uždaryti"
    }
}


def extract_xml_fields(xml_file_path, lang='et'):
    """Parses XML and extracts unique element paths with sample values."""
    if not os.path.exists(xml_file_path):
        return []

    try:
        tree = ET.parse(xml_file_path)
        root = tree.getroot()
    except Exception as e:
        print(f"Error parsing XML file {xml_file_path}: {e}", file=sys.stderr)
        return []

    fields = []
    seen_paths = set()
    parent_counts = {}

    for parent in root.iter():
        children = list(parent)
        tag_counts = {}
        for child in children:
            tag_counts[child.tag] = tag_counts.get(child.tag, 0) + 1
        for tag, count in tag_counts.items():
            if count > 1:
                parent_counts[(parent.tag, tag)] = count

    t = I18N.get(lang, I18N['et'])

    def recurse(elem, path_parts):
        curr_path = "/".join(path_parts)
        is_container = len(list(elem)) > 0
        text_val = (elem.text or "").strip() if not is_container else ""

        is_rep = False
        if len(path_parts) >= 2:
            p_tag = path_parts[-2]
            c_tag = path_parts[-1]
            if (p_tag, c_tag) in parent_counts:
                is_rep = True

        if curr_path and curr_path not in seen_paths:
            seen_paths.add(curr_path)
            fields.append({
                'path': curr_path,
                'tag': elem.tag,
                'sample': text_val if text_val else (t['rep_indicator'] if is_container else ""),
                'is_container': is_container,
                'is_repeating': is_rep
            })

        for child in elem:
            recurse(child, path_parts + [child.tag])

    for child in root:
        recurse(child, [child.tag])

    return fields


def inject_into_active_window(tag_text):
    """Pastes tag text into active LibreOffice session or copies to clipboard."""
    try:
        p = subprocess.Popen(['xclip', '-selection', 'clipboard'], stdin=subprocess.PIPE)
        p.communicate(tag_text.encode('utf-8'))
    except Exception:
        pass

    try:
        cmd = ['xdotool', 'search', '--name', 'LibreOffice']
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        wids = res.stdout.strip().split()
        if wids:
            wid = wids[0]
            subprocess.run(['xdotool', 'windowactivate', '--sync', wid], check=False)
            subprocess.run(['xdotool', 'key', '--clearmodifiers', 'ctrl+v'], check=False)
            return True
    except Exception as e:
        print(f"Notice: xdotool injection failed ({e}), copied to clipboard.", file=sys.stderr)

    return False


def build_xdo_tag(field_path, tag_type="field"):
    if tag_type == "field":
        return f"<?{field_path}?>"
    elif tag_type == "for-each":
        return f"<?for-each:{field_path}?>\n[Tabeli rida]\n<?end for-each?>"
    elif tag_type == "if":
        return f"<?if:{field_path} != ''?>\n<?{field_path}?>\n<?end if?>"
    elif tag_type == "format-number":
        return f"<?format-number({field_path}, '#,##0.00')?>"
    elif tag_type == "format-date":
        return f"<?format-date({field_path}, 'YYYY-MM-DD')?>"
    return f"<?{field_path}?>"


class PublisherFieldInspectorApp:
    def __init__(self, root, xml_path, rtf_path=None, lang="et"):
        self.root = root
        self.xml_path = xml_path
        self.rtf_path = rtf_path
        self.lang = lang.lower()[:2]
        if self.lang not in I18N:
            self.lang = 'et'

        self.a11y_state = 'unknown'
        self.root.geometry("540x750")
        self.root.minsize(440, 520)

        self.fields = extract_xml_fields(self.xml_path, self.lang)
        self.setup_ui()
        self.apply_language()

    def setup_ui(self):
        # 1. Top Language Selector Bar (6 Flags)
        lang_bar = ttk.Frame(self.root, padding=(6, 4, 6, 2))
        lang_bar.pack(fill=tk.X)

        ttk.Label(lang_bar, text="🌐", font=("Helvetica", 11)).pack(side=tk.LEFT, padx=(2, 6))
        
        langs = [
            ("🇬🇧 EN", "en"),
            ("🇪🇪 ET", "et"),
            ("🇫🇮 FI", "fi"),
            ("🇸🇪 SV", "sv"),
            ("🇱🇻 LV", "lv"),
            ("🇱🇹 LT", "lt")
        ]
        self.lang_buttons = {}
        for label, code in langs:
            btn = ttk.Button(lang_bar, text=label, width=6, command=lambda c=code: self.switch_language(c))
            btn.pack(side=tk.LEFT, padx=1)
            self.lang_buttons[code] = btn

        # 2. Header Frame
        self.hdr_frame = ttk.Frame(self.root, padding=(8, 4, 8, 4))
        self.hdr_frame.pack(fill=tk.X)

        self.title_lbl = ttk.Label(self.hdr_frame, font=("Helvetica", 12, "bold"))
        self.title_lbl.pack(anchor=tk.W)

        self.xml_lbl = ttk.Label(self.hdr_frame, font=("Helvetica", 9), foreground="#555")
        self.xml_lbl.pack(anchor=tk.W)

        # 3. Search Bar
        self.search_frame = ttk.Frame(self.root, padding=(8, 2, 8, 4))
        self.search_frame.pack(fill=tk.X)

        self.search_lbl = ttk.Label(self.search_frame)
        self.search_lbl.pack(side=tk.LEFT)

        self.search_var = tk.StringVar()
        self.search_var.trace("w", self.filter_fields)
        self.search_entry = ttk.Entry(self.search_frame, textvariable=self.search_var)
        self.search_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=4)

        # 4. Treeview for fields
        tree_frame = ttk.Frame(self.root, padding=8)
        tree_frame.pack(fill=tk.BOTH, expand=True)

        cols = ("path", "sample")
        self.tree = ttk.Treeview(tree_frame, columns=cols, show="headings", selectmode="browse")
        self.tree.column("path", width=270)
        self.tree.column("sample", width=210)

        scrollbar = ttk.Scrollbar(tree_frame, orient=tk.VERTICAL, command=self.tree.yview)
        self.tree.configure(yscroll=scrollbar.set)
        self.tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

        self.populate_tree(self.fields)

        # 5. Action Buttons Frame
        self.act_frame = ttk.LabelFrame(self.root, padding=8)
        self.act_frame.pack(fill=tk.X, padx=8, pady=4)

        btn_row1 = ttk.Frame(self.act_frame)
        btn_row1.pack(fill=tk.X, pady=2)
        self.btn_insert = ttk.Button(btn_row1, command=lambda: self.apply_tag("field"))
        self.btn_insert.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=2)
        self.btn_copy = ttk.Button(btn_row1, command=lambda: self.copy_tag("field"))
        self.btn_copy.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=2)

        btn_row2 = ttk.Frame(self.act_frame)
        btn_row2.pack(fill=tk.X, pady=2)
        self.btn_foreach = ttk.Button(btn_row2, command=lambda: self.apply_tag("for-each"))
        self.btn_foreach.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=2)
        self.btn_if = ttk.Button(btn_row2, command=lambda: self.apply_tag("if"))
        self.btn_if.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=2)

        btn_row3 = ttk.Frame(self.act_frame)
        btn_row3.pack(fill=tk.X, pady=2)
        self.btn_num = ttk.Button(btn_row3, command=lambda: self.apply_tag("format-number"))
        self.btn_num.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=2)
        self.btn_date = ttk.Button(btn_row3, command=lambda: self.apply_tag("format-date"))
        self.btn_date.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=2)

        # 6. Accessibility & Compliance Frame
        self.a11y_frame = ttk.LabelFrame(self.root, padding=8)
        self.a11y_frame.pack(fill=tk.X, padx=8, pady=4)

        self.a11y_status_lbl = ttk.Label(self.a11y_frame, font=("Helvetica", 9, "bold"))
        self.a11y_status_lbl.pack(anchor=tk.W, pady=(0, 4))

        a11y_btn_row = ttk.Frame(self.a11y_frame)
        a11y_btn_row.pack(fill=tk.X)

        self.btn_check_a11y = ttk.Button(a11y_btn_row, command=self.check_accessibility)
        self.btn_check_a11y.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=2)

        self.btn_speech_sim = ttk.Button(a11y_btn_row, command=self.show_screen_reader_view)
        self.btn_speech_sim.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=2)

        # 7. Status / Render bar
        bot_frame = ttk.Frame(self.root, padding=8)
        bot_frame.pack(fill=tk.X)

        self.status_lbl = ttk.Label(bot_frame, foreground="#333")
        self.status_lbl.pack(side=tk.LEFT, fill=tk.X, expand=True)

        self.render_btn = ttk.Button(bot_frame, command=self.render_pdf)
        self.render_btn.pack(side=tk.RIGHT)

    def apply_language(self):
        t = I18N.get(self.lang, I18N['et'])
        self.root.title(t['win_title'])
        self.title_lbl.config(text=t['header_title'])
        self.xml_lbl.config(text=t['file_info'].format(filename=os.path.basename(self.xml_path), count=len(self.fields)))
        self.search_lbl.config(text=t['search_lbl'])
        self.tree.heading("path", text=t['col_path'])
        self.tree.heading("sample", text=t['col_sample'])
        self.act_frame.config(text=t['frame_actions'])
        self.btn_insert.config(text=t['btn_insert'])
        self.btn_copy.config(text=t['btn_copy'])
        self.btn_foreach.config(text=t['btn_foreach'])
        self.btn_if.config(text=t['btn_if'])
        self.btn_num.config(text=t['btn_num'])
        self.btn_date.config(text=t['btn_date'])
        self.a11y_frame.config(text=t['frame_a11y'])
        self.btn_check_a11y.config(text=t['btn_check_a11y'])
        self.btn_speech_sim.config(text=t['btn_speech_sim'])
        if not hasattr(self, 'a11y_state') or self.a11y_state == 'unknown':
            self.a11y_status_lbl.config(text=t['a11y_status_unknown'], foreground="#555")
        elif self.a11y_state == 'clean':
            self.a11y_status_lbl.config(text=t['a11y_status_clean'], foreground="#1E7E34")
        elif self.a11y_state == 'warn':
            self.a11y_status_lbl.config(text=t['a11y_status_warn'], foreground="#B78103")
        elif self.a11y_state == 'error':
            self.a11y_status_lbl.config(text=t['a11y_status_error'], foreground="#B00020")
        self.render_btn.config(text=t['btn_render'])
        self.status_lbl.config(text=t['status_ready'])

    def switch_language(self, new_lang):
        self.lang = new_lang
        self.fields = extract_xml_fields(self.xml_path, self.lang)
        self.populate_tree(self.fields)
        self.apply_language()

        # Re-run setup-libreoffice-profile in background to align LibreOffice Writer
        script = "/u01/oracle/bin/setup-libreoffice-profile.sh"
        if os.path.exists(script):
            subprocess.Popen(["/bin/bash", script, self.lang])

    def populate_tree(self, fields_list):
        self.tree.delete(*self.tree.get_children())
        for f in fields_list:
            display_path = f['path']
            if f.get('is_repeating'):
                display_path = "🔁 " + display_path
            self.tree.insert("", tk.END, values=(display_path, f['sample']), tags=(f['path'],))

    def filter_fields(self, *args):
        query = self.search_var.get().strip().lower()
        if not query:
            self.populate_tree(self.fields)
            return
        filtered = [f for f in self.fields if query in f['path'].lower() or query in f['sample'].lower()]
        self.populate_tree(filtered)

    def get_selected_path(self):
        sel = self.tree.selection()
        if not sel:
            t = I18N.get(self.lang, I18N['et'])
            messagebox.showwarning("Warning", t['warn_no_field'])
            return None
        item = self.tree.item(sel[0])
        val = item['values'][0]
        if val.startswith("🔁 "):
            val = val[3:]
        return val

    def apply_tag(self, tag_type):
        path = self.get_selected_path()
        if not path:
            return
        tag = build_xdo_tag(path, tag_type)
        t = I18N.get(self.lang, I18N['et'])
        ok = inject_into_active_window(tag)
        if ok:
            self.status_lbl.config(text=t['status_inserted'].format(tag=tag[:40]))
        else:
            self.root.clipboard_clear()
            self.root.clipboard_append(tag)
            self.status_lbl.config(text=t['status_copied'].format(tag=tag[:40]))

    def copy_tag(self, tag_type):
        path = self.get_selected_path()
        if not path:
            return
        tag = build_xdo_tag(path, tag_type)
        t = I18N.get(self.lang, I18N['et'])
        self.root.clipboard_clear()
        self.root.clipboard_append(tag)
        self.status_lbl.config(text=t['status_copied'].format(tag=tag))

    def render_pdf(self):
        t = I18N.get(self.lang, I18N['et'])
        self.status_lbl.config(text=t['status_rendering'].format(lang=self.lang.upper()))
        self.root.update_idletasks()
        render_cmd = "/u01/oracle/bin/render-template.sh"
        if not os.path.exists(render_cmd):
            render_cmd = os.path.expanduser("~/Oracle/oracle-free-db-in-prod/scripts/publisher/test-render.sh")
        
        tpl = self.rtf_path or "/u01/templates/samples/arve_test_standard.rtf"
        data = self.xml_path
        out = os.path.splitext(tpl)[0] + f"_{self.lang}.pdf"

        try:
            res = subprocess.run([render_cmd, tpl, data, out, "--locale", self.lang],
                                 stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=False)
            if res.returncode == 0:
                self.status_lbl.config(text=t['status_success'].format(filename=os.path.basename(out)))
            else:
                self.status_lbl.config(text=t['status_error'])
        except Exception as e:
            self.status_lbl.config(text=f"❌ {e}")

    def check_accessibility(self):
        t = I18N.get(self.lang, I18N['et'])
        rtf_file = self.rtf_path or "/u01/templates/samples/arve_test_standard.rtf"
        if not os.path.exists(rtf_file):
            alt = os.path.abspath("templates/publisher/samples/accessible_starter_template.rtf")
            if os.path.exists(alt):
                rtf_file = alt

        linter_script = "/u01/oracle/bin/rtf-a11y-linter.py"
        if not os.path.exists(linter_script):
            linter_script = os.path.abspath("docker/publisher-designer/rtf-a11y-linter.py")

        cmd = [sys.executable, linter_script, rtf_file]
        try:
            res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=False)
            output = res.stdout
            if res.stderr:
                output += "\n" + res.stderr

            if res.returncode != 0:
                self.a11y_state = 'error'
                self.a11y_status_lbl.config(text=t['a11y_status_error'], foreground="#B00020")
            elif "Ebapiisav tekstikontrast" in output or "🟡" in output:
                self.a11y_state = 'warn'
                self.a11y_status_lbl.config(text=t['a11y_status_warn'], foreground="#B78103")
            else:
                self.a11y_state = 'clean'
                self.a11y_status_lbl.config(text=t['a11y_status_clean'], foreground="#1E7E34")

            dialog = tk.Toplevel(self.root)
            dialog.title(t['dialog_a11y_title'])
            dialog.geometry("620x460")
            dialog.minsize(500, 350)

            hdr = ttk.Label(dialog, text=f"📋 {os.path.basename(rtf_file)}", font=("Helvetica", 11, "bold"))
            hdr.pack(anchor=tk.W, padx=10, pady=(8, 4))

            txt_frame = ttk.Frame(dialog, padding=8)
            txt_frame.pack(fill=tk.BOTH, expand=True)

            txt = tk.Text(txt_frame, wrap=tk.WORD, font=("Courier", 10), bg="#F8F9FA")
            sb = ttk.Scrollbar(txt_frame, orient=tk.VERTICAL, command=txt.yview)
            txt.configure(yscrollcommand=sb.set)
            txt.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
            sb.pack(side=tk.RIGHT, fill=tk.Y)

            txt.insert(tk.END, output)
            txt.config(state=tk.DISABLED)

            btn_frame = ttk.Frame(dialog, padding=8)
            btn_frame.pack(fill=tk.X)

            def copy_report():
                self.root.clipboard_clear()
                self.root.clipboard_append(output)
                self.status_lbl.config(text=t['status_copied'].format(tag="Accessibility Report"))

            copy_btn = ttk.Button(btn_frame, text=t['btn_copy_transcript'], command=copy_report)
            copy_btn.pack(side=tk.LEFT, padx=4)

            close_btn = ttk.Button(btn_frame, text=t['btn_close'], command=dialog.destroy)
            close_btn.pack(side=tk.RIGHT, padx=4)

        except Exception as e:
            messagebox.showerror("Error", f"Failed to run accessibility audit: {e}")

    def show_screen_reader_view(self):
        t = I18N.get(self.lang, I18N['et'])
        rtf_file = self.rtf_path or "/u01/templates/samples/arve_test_standard.rtf"
        pdf_file = os.path.splitext(rtf_file)[0] + f"_{self.lang}.pdf"
        if not os.path.exists(pdf_file):
            alt_pdf = os.path.splitext(rtf_file)[0] + ".pdf"
            if os.path.exists(alt_pdf):
                pdf_file = alt_pdf

        if not os.path.exists(pdf_file):
            self.render_pdf()

        validator_script = "/u01/oracle/bin/pdf-a11y-validator.py"
        if not os.path.exists(validator_script):
            validator_script = os.path.abspath("docker/publisher-designer/pdf-a11y-validator.py")

        cmd = [sys.executable, validator_script, "--json", pdf_file]
        try:
            res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=False)
            data = None
            if res.stdout:
                try:
                    data = json.loads(res.stdout)
                except Exception:
                    data = None

            dialog = tk.Toplevel(self.root)
            dialog.title(t['dialog_speech_title'])
            dialog.geometry("660x520")
            dialog.minsize(520, 380)

            score = data.get("compliance_score_pct", 0) if data else 0
            title_text = data.get("title", "") if data else ""
            lang_code = data.get("language", "") if data else ""

            hdr_text = f"♿ {os.path.basename(pdf_file)} | PDF/UA-1: {score}% | Lang: {lang_code or self.lang.upper()}"
            hdr = ttk.Label(dialog, text=hdr_text, font=("Helvetica", 11, "bold"))
            hdr.pack(anchor=tk.W, padx=10, pady=(8, 4))

            txt_frame = ttk.Frame(dialog, padding=8)
            txt_frame.pack(fill=tk.BOTH, expand=True)

            txt = tk.Text(txt_frame, wrap=tk.WORD, font=("Courier", 10), bg="#1E1E1E", fg="#D4D4D4")
            sb = ttk.Scrollbar(txt_frame, orient=tk.VERTICAL, command=txt.yview)
            txt.configure(yscrollcommand=sb.set)
            txt.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
            sb.pack(side=tk.RIGHT, fill=tk.Y)

            txt.tag_config("heading", foreground="#4EC9B0", font=("Courier", 10, "bold"))
            txt.tag_config("table", foreground="#CE9178", font=("Courier", 10, "bold"))
            txt.tag_config("row", foreground="#9CDCFE")
            txt.tag_config("summary", foreground="#DCDCAA", font=("Courier", 10, "bold"))
            txt.tag_config("doc", foreground="#C586C0", font=("Courier", 10, "bold"))

            transcript_lines = data.get("screen_reader_transcript", []) if data else []
            if not transcript_lines and res.stdout:
                transcript_lines = res.stdout.splitlines()

            full_transcript_text = "\n".join(transcript_lines)
            for line in transcript_lines:
                tag = "row"
                if "[DOKUMENT]" in line:
                    tag = "doc"
                elif "[PEALKIRI" in line:
                    tag = "heading"
                elif "[TABELI" in line or "[PÄIS]" in line:
                    tag = "table"
                elif "[SUMMADE" in line:
                    tag = "summary"
                txt.insert(tk.END, line + "\n", tag)

            txt.config(state=tk.DISABLED)

            btn_frame = ttk.Frame(dialog, padding=8)
            btn_frame.pack(fill=tk.X)

            def copy_transcript():
                self.root.clipboard_clear()
                self.root.clipboard_append(full_transcript_text)
                self.status_lbl.config(text=t['status_copied'].format(tag="Screen Reader Transcript"))

            copy_btn = ttk.Button(btn_frame, text=t['btn_copy_transcript'], command=copy_transcript)
            copy_btn.pack(side=tk.LEFT, padx=4)

            close_btn = ttk.Button(btn_frame, text=t['btn_close'], command=dialog.destroy)
            close_btn.pack(side=tk.RIGHT, padx=4)

        except Exception as e:
            messagebox.showerror("Error", f"Failed to run speech simulation: {e}")


def main():
    parser = argparse.ArgumentParser(description="Oracle BI Publisher XML Field Inspector & Tag Builder")
    parser.add_argument("--xml", default="/u01/templates/samples/arve_test_andmed.xml", help="Path to XML data file")
    parser.add_argument("--rtf", default="/u01/templates/samples/arve_test_standard.rtf", help="Path to RTF template")
    parser.add_argument("--lang", default=os.getenv("APP_LANG", "et"), help="Default language (en, et, fi, sv, lv, lt)")
    parser.add_argument("--list-fields", action="store_true", help="Print extracted XML fields to stdout")
    parser.add_argument("--inject-field", help="Field path to inject programmatically into active window")
    parser.add_argument("--tag-type", default="field", choices=["field", "for-each", "if", "format-number", "format-date"])

    args = parser.parse_args()

    if not os.path.exists(args.xml):
        alt = os.path.abspath("templates/publisher/samples/arve_test_andmed.xml")
        if os.path.exists(alt):
            args.xml = alt
    if not os.path.exists(args.rtf):
        alt_rtf = os.path.abspath("templates/publisher/samples/arve_test_standard.rtf")
        if os.path.exists(alt_rtf):
            args.rtf = alt_rtf

    if args.list_fields:
        fields = extract_xml_fields(args.xml, args.lang)
        for f in fields:
            print(f"{f['path']}\t{f['sample']}")
        return

    if args.inject_field:
        tag = build_xdo_tag(args.inject_field, args.tag_type)
        print(f"Injecting tag: {tag}")
        ok = inject_into_active_window(tag)
        print(f"Injection status: {'SUCCESS' if ok else 'FALLBACK_CLIPBOARD'}")
        return

    if not HAS_TK:
        print("Tkinter is not available. Use --list-fields or --inject-field in CLI mode.")
        sys.exit(1)

    root = tk.Tk()
    app = PublisherFieldInspectorApp(root, args.xml, args.rtf, args.lang)
    root.mainloop()


if __name__ == "__main__":
    main()
