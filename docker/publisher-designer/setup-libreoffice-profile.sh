#!/usr/bin/env bash
# ==============================================================================
# Configure LibreOffice Writer with Oracle BI Publisher Menu, Toolbar & Macros
# Supports 6 Nordic-Baltic Languages: EN, ET, FI, SV, LV, LT
# ==============================================================================
set -euo pipefail

LANG_CODE="${1:-${APP_LANG:-et}}"
# Normalize 2-letter code
LANG_CODE="$(echo "$LANG_CODE" | tr '[:upper:]' '[:lower:]' | cut -c1-2)"

USER_HOME="/u01/oracle"
if [ ! -d "$USER_HOME" ]; then
  USER_HOME="$HOME"
fi

LO_DIR="$USER_HOME/.config/libreoffice/4/user"
BASIC_DIR="$LO_DIR/basic/Standard"
MENUBAR_DIR="$LO_DIR/config/soffice.cfg/modules/swriter/menubar"
TOOLBAR_DIR="$LO_DIR/config/soffice.cfg/modules/swriter/toolbar"

mkdir -p "$BASIC_DIR" "$MENUBAR_DIR" "$TOOLBAR_DIR"

echo "⚙️ Setting up LibreOffice Oracle Publisher profile in $LO_DIR (Language: $LANG_CODE)..."

# Resolve Locale strings and translations based on LANG_CODE
case "$LANG_CODE" in
  en)
    OO_LOCALE="en-US"
    MENU_FILE="~File"
    MENU_EDIT="~Edit"
    MENU_VIEW="~View"
    MENU_INSERT="~Insert"
    MENU_FORMAT="F~ormat"
    MENU_TABLE="~Table"
    MENU_TOOLS="~Tools"
    MENU_HELP="~Help"
    MENU_PUB="⚡ Oracle Publisher"
    ITEM_INSPECTOR="🏷️ Open XML Field Inspector..."
    ITEM_INSERT_FIELD="🏷️ Insert XML Field (Field)..."
    ITEM_INSERT_LOOP="🔁 Insert Repeating Block (for-each)..."
    ITEM_INSERT_IF="❓ Insert Condition Block (if condition)..."
    ITEM_FAST_RENDER="⚡ Fast-Render PDF Preview"
    ITEM_SWITCH_LANG="🌐 Switch Language / Keel..."
    TB_INSPECTOR="🏷️ XML Inspector"
    TB_INSERT_FIELD="🏷️ Insert Field"
    TB_LOOP="🔁 for-each"
    TB_IF="❓ IF"
    TB_RENDER="⚡ Fast PDF"
    TB_LANG="🌐 Language"
    PROMPT_FIELD="Enter Oracle XML field path (e.g. BUYER/COMPANY_NAME or SELLER/IBAN):"
    TITLE_FIELD="Oracle BI Publisher - Insert Field"
    PROMPT_LOOP="Enter repeating block XPath (e.g. LINES/LINE):"
    TITLE_LOOP="Oracle BI Publisher - Insert for-each Loop"
    PROMPT_IF="Enter condition expression (e.g. DISCOUNT_PCT > 0 or VAT_AMOUNT > 0):"
    TITLE_IF="Oracle BI Publisher - Insert Condition"
    MSG_RENDER="PDF render command dispatched!\nOutput: /u01/templates/samples/valmis_arve_en.pdf"
    SAMPLE_ROW="[Table row: <?DESCRIPTION?> | <?format-number(LINE_TOTAL, '#,##0.00')?>]"
    SAMPLE_IF="[Displayed content]"
    ;;
  fi)
    OO_LOCALE="fi-FI"
    MENU_FILE="~Tiedosto"
    MENU_EDIT="~Muokkaa"
    MENU_VIEW="~Näytä"
    MENU_INSERT="~Lisää"
    MENU_FORMAT="M~uotoilu"
    MENU_TABLE="T~aulukko"
    MENU_TOOLS="T~yökalut"
    MENU_HELP="~Ohje"
    MENU_PUB="⚡ Oracle Publisher"
    ITEM_INSPECTOR="🏷️ Avaa XML-kenttien tarkastaja..."
    ITEM_INSERT_FIELD="🏷️ Lisää XML-kenttä (Field)..."
    ITEM_INSERT_LOOP="🔁 Lisää toistolohko (for-each)..."
    ITEM_INSERT_IF="❓ Lisää ehtolohko (if-ehto)..."
    ITEM_FAST_RENDER="⚡ Pika-Renderöi PDF-esikatselu"
    ITEM_SWITCH_LANG="🌐 Vaihda Kieli / Language..."
    TB_INSPECTOR="🏷️ XML-tarkastaja"
    TB_INSERT_FIELD="🏷️ Lisää Kenttä"
    TB_LOOP="🔁 for-each"
    TB_IF="❓ IF"
    TB_RENDER="⚡ Pika-PDF"
    TB_LANG="🌐 Kieli"
    PROMPT_FIELD="Syötä Oracle XML -kentän polku (esim. BUYER/COMPANY_NAME tai SELLER/IBAN):"
    TITLE_FIELD="Oracle BI Publisher - Lisää Kenttä"
    PROMPT_LOOP="Syötä toistolohkon XPath (esim. LINES/LINE):"
    TITLE_LOOP="Oracle BI Publisher - Lisää for-each-silmukka"
    PROMPT_IF="Syötä ehtolauseke (esim. DISCOUNT_PCT > 0 tai VAT_AMOUNT > 0):"
    TITLE_IF="Oracle BI Publisher - Lisää Ehto"
    MSG_RENDER="PDF-renderöintipyyntö lähetetty!\nTuloste: /u01/templates/samples/valmis_arve_fi.pdf"
    SAMPLE_ROW="[Taulukon rivi: <?DESCRIPTION?> | <?format-number(LINE_TOTAL, '#,##0.00')?>]"
    SAMPLE_IF="[Näytettävä sisältö]"
    ;;
  sv)
    OO_LOCALE="sv-SE"
    MENU_FILE="~Arkiv"
    MENU_EDIT="~Redigera"
    MENU_VIEW="~Visa"
    MENU_INSERT="~Infoga"
    MENU_FORMAT="F~ormat"
    MENU_TABLE="~Tabell"
    MENU_TOOLS="~Verktyg"
    MENU_HELP="~Hjälp"
    MENU_PUB="⚡ Oracle Publisher"
    ITEM_INSPECTOR="🏷️ Öppna XML-fältgranskare..."
    ITEM_INSERT_FIELD="🏷️ Infoga XML-fält (Field)..."
    ITEM_INSERT_LOOP="🔁 Infoga upprepningsblock (for-each)..."
    ITEM_INSERT_IF="❓ Infoga villkorsblock (if-villkor)..."
    ITEM_FAST_RENDER="⚡ Snabb-rendera PDF-förhandsvisning"
    ITEM_SWITCH_LANG="🌐 Byt Språk / Language..."
    TB_INSPECTOR="🏷️ XML-granskare"
    TB_INSERT_FIELD="🏷️ Infoga Fält"
    TB_LOOP="🔁 for-each"
    TB_IF="❓ IF"
    TB_RENDER="⚡ Snabb-PDF"
    TB_LANG="🌐 Språk"
    PROMPT_FIELD="Ange Oracle XML-fältets sökväg (t.ex. BUYER/COMPANY_NAME eller SELLER/IBAN):"
    TITLE_FIELD="Oracle BI Publisher - Infoga Fält"
    PROMPT_LOOP="Ange XPath för upprepningsblock (t.ex. LINES/LINE):"
    TITLE_LOOP="Oracle BI Publisher - Infoga for-each-loop"
    PROMPT_IF="Ange villkorsuttryck (t.ex. DISCOUNT_PCT > 0 eller VAT_AMOUNT > 0):"
    TITLE_IF="Oracle BI Publisher - Infoga Villkor"
    MSG_RENDER="PDF-renderingskommando skickat!\nUtdata: /u01/templates/samples/valmis_arve_sv.pdf"
    SAMPLE_ROW="[Tabellrad: <?DESCRIPTION?> | <?format-number(LINE_TOTAL, '#,##0.00')?>]"
    SAMPLE_IF="[Innehåll som visas]"
    ;;
  lv)
    OO_LOCALE="lv-LV"
    MENU_FILE="~Fails"
    MENU_EDIT="~Labot"
    MENU_VIEW="~Skats"
    MENU_INSERT="~Ievietot"
    MENU_FORMAT="F~ormatēt"
    MENU_TABLE="~Tabula"
    MENU_TOOLS="~Rīki"
    MENU_HELP="~Palīdzība"
    MENU_PUB="⚡ Oracle Publisher"
    ITEM_INSPECTOR="🏷️ Atvērt XML lauku inspektoru..."
    ITEM_INSERT_FIELD="🏷️ Ievietot XML lauku (Field)..."
    ITEM_INSERT_LOOP="🔁 Ievietot atkārtošanās bloku (for-each)..."
    ITEM_INSERT_IF="❓ Ievietot nosacījuma bloku (if nosacījums)..."
    ITEM_FAST_RENDER="⚡ Ātrā renderēšana PDF priekšskatījumam"
    ITEM_SWITCH_LANG="🌐 Mainīt Valodu / Language..."
    TB_INSPECTOR="🏷️ XML inspektors"
    TB_INSERT_FIELD="🏷️ Ievietot Lauku"
    TB_LOOP="🔁 for-each"
    TB_IF="❓ IF"
    TB_RENDER="⚡ Ātrais PDF"
    TB_LANG="🌐 Valoda"
    PROMPT_FIELD="Ievadiet Oracle XML lauka ceļu (piem., BUYER/COMPANY_NAME vai SELLER/IBAN):"
    TITLE_FIELD="Oracle BI Publisher - Ievietot Lauku"
    PROMPT_LOOP="Ievadiet atkārtošanās bloka XPath (piem., LINES/LINE):"
    TITLE_LOOP="Oracle BI Publisher - Ievietot for-each cilpu"
    PROMPT_IF="Ievadiet nosacījuma izteiksmi (piem., DISCOUNT_PCT > 0 vai VAT_AMOUNT > 0):"
    TITLE_IF="Oracle BI Publisher - Ievietot Nosacījumu"
    MSG_RENDER="PDF renderēšanas komanda nosūtīta!\nIzvade: /u01/templates/samples/valmis_arve_lv.pdf"
    SAMPLE_ROW="[Tabulas rinda: <?DESCRIPTION?> | <?format-number(LINE_TOTAL, '#,##0.00')?>]"
    SAMPLE_IF="[Parādāmais saturs]"
    ;;
  lt)
    OO_LOCALE="lt-LT"
    MENU_FILE="~Failas"
    MENU_EDIT="~Redaguoti"
    MENU_VIEW="~Rodymas"
    MENU_INSERT="~Įterpimas"
    MENU_FORMAT="F~ormatas"
    MENU_TABLE="~Lentelė"
    MENU_TOOLS="~Priemonės"
    MENU_HELP="~Žinynas"
    MENU_PUB="⚡ Oracle Publisher"
    ITEM_INSPECTOR="🏷️ Atidaryti XML laukų inspektorių..."
    ITEM_INSERT_FIELD="🏷️ Įterpti XML lauką (Field)..."
    ITEM_INSERT_LOOP="🔁 Įterpti pasikartojantį bloką (for-each)..."
    ITEM_INSERT_IF="❓ Įterpti sąlygos bloką (if sąlyga)..."
    ITEM_FAST_RENDER="⚡ Greitas PDF peržiūros generavimas"
    ITEM_SWITCH_LANG="🌐 Keisti Kalbą / Language..."
    TB_INSPECTOR="🏷️ XML inspektorius"
    TB_INSERT_FIELD="🏷️ Įterpti Lauką"
    TB_LOOP="🔁 for-each"
    TB_IF="❓ IF"
    TB_RENDER="⚡ Greitas PDF"
    TB_LANG="🌐 Kalba"
    PROMPT_FIELD="Įveskite Oracle XML lauko kelią (pvz., BUYER/COMPANY_NAME arba SELLER/IBAN):"
    TITLE_FIELD="Oracle BI Publisher - Įterpti Lauką"
    PROMPT_LOOP="Įveskite pasikartojančio bloko XPath (pvz., LINES/LINE):"
    TITLE_LOOP="Oracle BI Publisher - Įterpti for-each ciklą"
    PROMPT_IF="Įveskite sąlygos išraišką (pvz., DISCOUNT_PCT > 0 arba VAT_AMOUNT > 0):"
    TITLE_IF="Oracle BI Publisher - Įterpti Sąlygą"
    MSG_RENDER="PDF generavimo komanda išsiųsta!\nRezultatas: /u01/templates/samples/valmis_arve_lt.pdf"
    SAMPLE_ROW="[Lentelės eilutė: <?DESCRIPTION?> | <?format-number(LINE_TOTAL, '#,##0.00')?>]"
    SAMPLE_IF="[Rodomas turinys]"
    ;;
  et|*)
    LANG_CODE="et"
    OO_LOCALE="et-EE"
    MENU_FILE="~Fail"
    MENU_EDIT="~Redigeeri"
    MENU_VIEW="~Vaade"
    MENU_INSERT="~Lisa"
    MENU_FORMAT="~Vormindus"
    MENU_TABLE="~Tabel"
    MENU_TOOLS="~Tööriistad"
    MENU_HELP="~Abi"
    MENU_PUB="⚡ Oracle Publisher"
    ITEM_INSPECTOR="🏷️ Ava XML Väljade Inspektor..."
    ITEM_INSERT_FIELD="🏷️ Lisa XML Väli (Field)..."
    ITEM_INSERT_LOOP="🔁 Lisa Kordusplokk (for-each)..."
    ITEM_INSERT_IF="❓ Lisa Tingimusplokk (if condition)..."
    ITEM_FAST_RENDER="⚡ Kiir-Renderda PDF Eelvaade"
    ITEM_SWITCH_LANG="🌐 Vaheta Keelt / Language..."
    TB_INSPECTOR="🏷️ XML Inspektor"
    TB_INSERT_FIELD="🏷️ Lisa Väli"
    TB_LOOP="🔁 for-each"
    TB_IF="❓ IF"
    TB_RENDER="⚡ Kiir-PDF"
    TB_LANG="🌐 Keel"
    PROMPT_FIELD="Sisesta Oracle XML välja nimi (nt BUYER/COMPANY_NAME või SELLER/IBAN):"
    TITLE_FIELD="Oracle BI Publisher - Lisa Väli"
    PROMPT_LOOP="Sisesta kordusploki XPath (nt LINES/LINE):"
    TITLE_LOOP="Oracle BI Publisher - Lisa for-each kordus"
    PROMPT_IF="Sisesta tingimus (nt DISCOUNT_PCT > 0 või VAT_AMOUNT > 0):"
    TITLE_IF="Oracle BI Publisher - Lisa Tingimus"
    MSG_RENDER="PDF renderdamise käsk edastatud!\nVäljund: /u01/templates/samples/valmis_arve_et.pdf"
    SAMPLE_ROW="[Tabeli rida: <?DESCRIPTION?> | <?format-number(LINE_TOTAL, '#,##0.00')?>]"
    SAMPLE_IF="[Näidatav sisu]"
    ;;
esac

# 1. Update LibreOffice L10N configuration in registrymodifications.xcu
REG_FILE="$LO_DIR/registrymodifications.xcu"
if [ ! -f "$REG_FILE" ]; then
  cat << 'EOF' > "$REG_FILE"
<?xml version="1.0" encoding="UTF-8"?>
<oor:items xmlns:oor="http://openoffice.org/2001/registry" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
</oor:items>
EOF
fi

# Set LibreOffice UI Locale in registrymodifications.xcu
python3 -c "
import xml.etree.ElementTree as ET
import os

reg_file = '$REG_FILE'
locale = '$OO_LOCALE'

if os.path.exists(reg_file):
    try:
        tree = ET.parse(reg_file)
        root = tree.getroot()
        # Remove existing L10N items if present
        for item in list(root):
            path = item.attrib.get('{http://openoffice.org/2001/registry}path', item.attrib.get('path', ''))
            if 'org.openoffice.Setup/L10N' in path:
                root.remove(item)

        # Add new items
        for prop_name in ['ooLocale', 'ooSetupSystemLocale']:
            item = ET.SubElement(root, 'item', {
                '{http://openoffice.org/2001/registry}path': '/org.openoffice.Setup/L10N'
            })
            prop = ET.SubElement(item, 'prop', {
                '{http://openoffice.org/2001/registry}name': prop_name,
                '{http://openoffice.org/2001/registry}op': 'fuse'
            })
            val = ET.SubElement(prop, 'value')
            val.text = locale

        tree.write(reg_file, encoding='utf-8', xml_declaration=True)
    except Exception as e:
        pass
" 2>/dev/null || true

# 2. Generate Module1.xba and PublisherModule.xba
cat << EOF > "$BASIC_DIR/Module1.xba"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE script:module PUBLIC "-//OpenOffice.org//DTD OfficeDocument 1.0//EN" "module.dtd">
<script:module xmlns:script="http://openoffice.org/2000/script" script:name="Module1" script:language="StarBasic">REM  *****  BASIC  *****

Sub OpenXmlInspector
    On Error Resume Next
    Shell("/bin/bash", 1, "-c '/u01/oracle/bin/xml-field-inspector.py --lang $LANG_CODE &'")
End Sub

Sub InsertPublisherField
    Dim sTag As String
    sTag = InputBox("$PROMPT_FIELD", "$TITLE_FIELD", "SELLER/IBAN")
    If sTag <> "" Then
        Dim oDoc As Object, oViewCursor As Object
        oDoc = ThisComponent
        oViewCursor = oDoc.CurrentController.getViewCursor()
        oViewCursor.String = "<?" & sTag & "?>"
    End If
End Sub

Sub InsertForEach
    Dim sNode As String
    sNode = InputBox("$PROMPT_LOOP", "$TITLE_LOOP", "LINES/LINE")
    If sNode <> "" Then
        Dim oDoc As Object, oViewCursor As Object
        oDoc = ThisComponent
        oViewCursor = oDoc.CurrentController.getViewCursor()
        oViewCursor.String = "<?for-each:" & sNode & "?>" & Chr(10) & "$SAMPLE_ROW" & Chr(10) & "<?end for-each?>"
    End If
End Sub

Sub InsertIfCondition
    Dim sCond As String
    sCond = InputBox("$PROMPT_IF", "$TITLE_IF", "DISCOUNT_PCT > 0")
    If sCond <> "" Then
        Dim oDoc As Object, oViewCursor As Object
        oDoc = ThisComponent
        oViewCursor = oDoc.CurrentController.getViewCursor()
        oViewCursor.String = "<?if:" & sCond & "?>" & Chr(10) & "$SAMPLE_IF" & Chr(10) & "<?end if?>"
    End If
End Sub

Sub FastRenderPDF
    On Error Resume Next
    Shell("/bin/bash", 1, "-c '/u01/oracle/bin/render-template.sh /u01/templates/samples/arve_test_standard.rtf /u01/templates/samples/arve_test_andmed.xml /u01/templates/samples/valmis_arve.pdf --locale $LANG_CODE && cp -f /u01/templates/samples/valmis_arve.pdf /u01/templates/samples/valmis_arve_$LANG_CODE.pdf'")
    MsgBox "$MSG_RENDER", 64, "Oracle BI Publisher"
End Sub

Sub SwitchLanguage
    Dim sChoice As String
    sChoice = InputBox("Choose Language / Vali keel:" & Chr(10) & "1 = English (EN)" & Chr(10) & "2 = Eesti (ET)" & Chr(10) & "3 = Suomi (FI)" & Chr(10) & "4 = Svenska (SV)" & Chr(10) & "5 = Latviešu (LV)" & Chr(10) & "6 = Lietuvių (LT)", "Oracle BI Publisher - Language / Keel", "2")
    Dim sLang As String
    Select Case sChoice
        Case "1": sLang = "en"
        Case "2": sLang = "et"
        Case "3": sLang = "fi"
        Case "4": sLang = "sv"
        Case "5": sLang = "lv"
        Case "6": sLang = "lt"
        Case Else: Exit Sub
    End Select
    Shell("/bin/bash", 1, "-c '/u01/oracle/bin/setup-libreoffice-profile.sh " & sLang & "'")
    MsgBox "Language switched to " & UCase(sLang) & "! Please restart LibreOffice Writer to apply changes.", 64, "Oracle BI Publisher"
End Sub
</script:module>
EOF

cp "$BASIC_DIR/Module1.xba" "$BASIC_DIR/PublisherModule.xba"
sed -i.bak 's/script:name="Module1"/script:name="PublisherModule"/' "$BASIC_DIR/PublisherModule.xba" && rm -f "$BASIC_DIR/PublisherModule.xba.bak"

# 3. Register in script.xlb
cat << 'EOF' > "$BASIC_DIR/script.xlb"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE library:library PUBLIC "-//OpenOffice.org//DTD OfficeDocument 1.0//EN" "library.dtd">
<library:library xmlns:library="http://openoffice.org/2000/library" library:name="Standard" library:readonly="false" library:passwordprotected="false">
 <library:element library:name="Module1"/>
 <library:element library:name="PublisherModule"/>
</library:library>
EOF

cat << 'EOF' > "$LO_DIR/basic/script.xlb"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE library:libraries PUBLIC "-//OpenOffice.org//DTD OfficeDocument 1.0//EN" "libraries.dtd">
<library:libraries xmlns:library="http://openoffice.org/2000/library" xmlns:xlink="http://www.w3.org/1999/xlink">
 <library:library library:name="Standard" library:link="false"/>
</library:libraries>
EOF

cat << 'EOF' > "$LO_DIR/basic/script.xlc"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE library:libraries PUBLIC "-//OpenOffice.org//DTD OfficeDocument 1.0//EN" "libraries.dtd">
<library:libraries xmlns:library="http://openoffice.org/2000/library" xmlns:xlink="http://www.w3.org/1999/xlink">
 <library:library library:name="Standard" library:link="false"/>
</library:libraries>
EOF

# 4. Generate Custom Toolbar custom_toolbar_publisher.xml
cat << EOF > "$TOOLBAR_DIR/custom_toolbar_publisher.xml"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE toolbar:toolbar PUBLIC "-//OpenOffice.org//DTD OfficeDocument 1.0//EN" "toolbar.dtd">
<toolbar:toolbar xmlns:toolbar="http://openoffice.org/2001/toolbar" xmlns:xlink="http://www.w3.org/1999/xlink" toolbar:uiname="Oracle BI Publisher">
 <toolbar:toolbaritem xlink:href="vnd.sun.star.script:Standard.Module1.OpenXmlInspector?language=Basic&amp;location=application" toolbar:text="$TB_INSPECTOR"/>
 <toolbar:toolbaritem xlink:href="vnd.sun.star.script:Standard.Module1.InsertPublisherField?language=Basic&amp;location=application" toolbar:text="$TB_INSERT_FIELD"/>
 <toolbar:toolbaritem xlink:href="vnd.sun.star.script:Standard.Module1.InsertForEach?language=Basic&amp;location=application" toolbar:text="$TB_LOOP"/>
 <toolbar:toolbaritem xlink:href="vnd.sun.star.script:Standard.Module1.InsertIfCondition?language=Basic&amp;location=application" toolbar:text="$TB_IF"/>
 <toolbar:toolbarseparator/>
 <toolbar:toolbaritem xlink:href="vnd.sun.star.script:Standard.Module1.FastRenderPDF?language=Basic&amp;location=application" toolbar:text="$TB_RENDER"/>
 <toolbar:toolbaritem xlink:href="vnd.sun.star.script:Standard.Module1.SwitchLanguage?language=Basic&amp;location=application" toolbar:text="$TB_LANG"/>
</toolbar:toolbar>
EOF

# 5. Generate Custom Menubar with Oracle Publisher Menu
cat << EOF > "$MENUBAR_DIR/menubar.xml"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE menu:menubar PUBLIC "-//OpenOffice.org//DTD OfficeDocument 1.0//EN" "menubar.dtd">
<menu:menubar xmlns:menu="http://openoffice.org/2001/menu" xmlns:xlink="http://www.w3.org/1999/xlink">
 <menu:menu menu:id=".uno:PickList" menu:label="$MENU_FILE">
  <menu:menupopup>
   <menu:menuitem menu:id=".uno:Open"/>
   <menu:menuitem menu:id=".uno:Save"/>
   <menu:menuitem menu:id=".uno:SaveAs"/>
   <menu:menuseparator/>
   <menu:menuitem menu:id=".uno:ExportToPDF"/>
   <menu:menuitem menu:id=".uno:CloseDoc"/>
  </menu:menupopup>
 </menu:menu>
 <menu:menu menu:id=".uno:EditMenu" menu:label="$MENU_EDIT"/>
 <menu:menu menu:id=".uno:ViewMenu" menu:label="$MENU_VIEW"/>
 <menu:menu menu:id=".uno:InsertMenu" menu:label="$MENU_INSERT"/>
 <menu:menu menu:id=".uno:FormatMenu" menu:label="$MENU_FORMAT"/>
 <menu:menu menu:id=".uno:TableMenu" menu:label="$MENU_TABLE"/>
 <menu:menu menu:id=".uno:ToolsMenu" menu:label="$MENU_TOOLS"/>
 <menu:menu menu:id="vnd.oracle.publisher.menu" menu:label="$MENU_PUB">
  <menu:menupopup>
   <menu:menuitem menu:id="vnd.sun.star.script:Standard.Module1.OpenXmlInspector?language=Basic&amp;location=application" menu:label="$ITEM_INSPECTOR"/>
   <menu:menuseparator/>
   <menu:menuitem menu:id="vnd.sun.star.script:Standard.Module1.InsertPublisherField?language=Basic&amp;location=application" menu:label="$ITEM_INSERT_FIELD"/>
   <menu:menuitem menu:id="vnd.sun.star.script:Standard.Module1.InsertForEach?language=Basic&amp;location=application" menu:label="$ITEM_INSERT_LOOP"/>
   <menu:menuitem menu:id="vnd.sun.star.script:Standard.Module1.InsertIfCondition?language=Basic&amp;location=application" menu:label="$ITEM_INSERT_IF"/>
   <menu:menuseparator/>
   <menu:menuitem menu:id="vnd.sun.star.script:Standard.Module1.FastRenderPDF?language=Basic&amp;location=application" menu:label="$ITEM_FAST_RENDER"/>
   <menu:menuseparator/>
   <menu:menuitem menu:id="vnd.sun.star.script:Standard.Module1.SwitchLanguage?language=Basic&amp;location=application" menu:label="$ITEM_SWITCH_LANG"/>
  </menu:menupopup>
 </menu:menu>
 <menu:menu menu:id=".uno:HelpMenu" menu:label="$MENU_HELP"/>
</menu:menubar>
EOF

echo "✅ LibreOffice Oracle Publisher configuration completed for language: $LANG_CODE ($OO_LOCALE)!"
