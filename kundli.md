# Kundli Feature — Complete Reference

## ARCHITECTURE

- State management: GetX (GetBuilder pattern)
- HTTP: http package (POST requests with JSON body + auth headers)
- Responsive sizing: responsive_sizer (use .w, .h, .sp units)
- Localization: easy_localization (.tr() on Text widgets)
- PDF viewer: syncfusion_flutter_pdfviewer
- SVG rendering: flutter_svg + dart:ui for SVG-to-Image conversion

---

## SCREEN FLOW

1. KundliListScreen
   → KundliDetailScreen (8 tabs)
     → Tab 1: BasicDetailsWidget
     → Tab 2: KundliChartScreen (dynamic sub-tabs)
     → Tab 3: KpScreen (KP chart with zoom)
     → Tab 4: AshtakvargaTable
     → Tab 5: ReportScreen
     → Tab 6: PlanetReportScreen (9 planet sub-tabs)
     → Tab 7: DashaScreen (Vimshottari + Yogini)
     → Tab 8: DoshaScreen (5 doshas)

---

## SCREEN 1 — KundliListScreen

- AppBar title: "Kundli"
- Search bar at top: real-time filter by name (calls controller.searchKundli(value))
- ListView of kundli cards showing:
  - Avatar: colored circle with first letter of name (random color from Colors.primaries)
  - Title: kundli name
  - Subtitle line 1: "dd MMM yyyy, HH:mm" (birth date + time)
  - Subtitle line 2: birthPlace
  - Trailing: edit icon (CircleAvatar, radius 12) + delete icon (CircleAvatar, red)
- On card tap: show loader → call getBasicDetailApi(id) → navigate to KundliDetailScreen
- On edit tap: call getKundliListById(index) → navigate to EditKundliScreen
- On delete tap: show confirmation AlertDialog (NO / YES buttons) → deleteKundli(id) → refresh list
- BottomSheet: full-width "Create New Kundli" ElevatedButton
  - On press: call pdfPrice() API → if success navigate to CreateKundliScreen

---

## SCREEN 2 — KundliDetailScreen

- AppBar title: "Kundli Details"
- TabBar (scrollable, 8 tabs, pill-style indicator with primary color):
  [Basic Details] [Charts] [KP] [Ashtakvarga] [Report] [Planet Report] [Dasha] [Dosha]
- TabBarView with 8 screens below (described individually)
- Use AutomaticKeepAliveClientMixin on all tab widgets (wantKeepAlive = true)
- Pass `userid` (int?) and `basicDeatilmodel` to all tabs

---

## TAB 1 — Basic Details (BasicDetailsWidget)

Data comes from the basicDeatilmodel already loaded before navigation.

Show three sections, each with alternating row colors (white / pink[50]):

Section A — Birth Details:
  Name, Gender, Birth Date (dd MMM yyyy), Birth Time, Birth Place, Timezone

Section B — Panchang:
  Ayanamsa Name, Day of Birth, Day Lord, Karana, Sunset, Sunrise, Yoga, Tithi

Section C — Avakhada Details:
  Rasi, Day, Nakshatra, Tatva, Lord, Same/Opposite sex lagna

Each row is a 2-column layout: label (left, bold, 40% width) | value (right, 60% width).
Separate sections with a colored header bar (primary color background, white text).

---

## TAB 2 — Charts (KundliChartScreen)

On initState: call getChartDetails(userid, 'D1', selectedDirection) — show loader until done.

Layout:
- Direction selector row: [North] [South] toggle buttons (left-aligned)
  - selectedDirection = 'north' | 'south'
  - On change: re-fetch chart
- Horizontal scrollable sub-tab bar (pills) for chart types:
  D1=Rasi, D9=Navamsa, D2=Hora, D3=Drekkana, D4=Chaturthamsa, D5=Panchamamsa,
  D6=Shastamsa, D7=Saptamsa, D8=Astamsa, D10=Dasamsa, D11=Rudramsa,
  D12=Dwadasamsa, D16=Shodasamsa, D20=Vimsamsa, D24=Siddhamsa,
  D27=Nakshatramsa, D30=Trimsamsa, D40=Khavedamsa, D45=Akshavedamsa,
  D60=Shastyamsa, chalit=Chalit, sun=Sun, moon=Moon
- Center: SVG chart image rendered via CustomPainter (scale-to-fit in square container)
  - SVG string from API → parse to ui.Image → draw with canvas.drawImageRect
- Below chart: Sign/Nakshatra toggle
  - Sign table columns: Planet | Sign | Lord | Degree | House
  - Nakshatra table columns: Planet | Nakshatra | Naksh Lord | House
  - Data comes from basicDeatilmodel.planetDetails

On sub-tab change: call getChartDetails(userid, tabKey, selectedDirection).
Show CircularProgressIndicator while loading.

---

## TAB 3 — KP (KpScreen)

Same layout as Charts tab but:
- Fixed chart key: 'kp_chalit' (no sub-tabs)
- Wrap SVG image in InteractiveViewer (pan + zoom)
- Double-tap gesture to zoom in/out (TransformationController)
- Zoom button (floating) to trigger zoom programmatically
- Planet table below (same Sign/Nakshatra toggle as Charts tab)
- Fetch on initState: getChartDetails(userid, 'kp_chalit', direction)

---

## TAB 4 — Ashtakvarga (AshtakvargaTable)

On initState: call getAstaVarga(userid).

Show two tables (use InteractiveViewer for both):

Table 1 — Ashtakvarga:
- Row labels: ashtakvargaList (planet names)
- Column data: ashtakvargaPoints (2D list)
- Last column: ashtakvargaTotal

Table 2 — Binna Ashtakvarga:
- Columns: Ascendant, Sun, Moon, Mars, Mercury, Jupiter, Saturn, Venus
- Each column has 12 house values
- Data from binnashtakvargaData map

Zoom button and double-tap zoom same as KP tab.

---

## TAB 5 — Report (ReportScreen)

On initState: call getReportApi(userid).

Display as label-value alternating rows (white / pink[50]):
- Ascendant
- Ascendant Lord
- Ascendant Lord Location
- Ascendant Lord House Location
- Symbol
- Zodiac Characteristics
- Lucky Gem
- Day of Fasting
- Good Quality
- Bad Quality
- Spiritual Advice (long text — display in column layout, justified)
- General Prediction (long text — column layout, justified)
- Personalized Prediction (long text — column layout, justified)

Short fields: label | value in a Row.
Long fields (Spiritual Advice, Predictions): label on top row, value below in full width.

---

## TAB 6 — Planet Report (PlanetReportScreen)

On initState: call getPlanetReportApi(userid, 'Sun') for first tab.

9 planet sub-tabs (horizontal scrollable pills):
Sun, Moon, Mercury, Venus, Mars, Saturn, Jupiter, Rahu, Ketu

On tab change: call getPlanetReportApi(userid, planetName).

Each planet report shows alternating rows:
- Planet Considered
- Planet Location
- Planet Zodiac
- Zodiac Lord Strength
- Planet Definition
- Verbal Location
- Affliction
- Personalised Prediction
- Planet Zodiac Prediction

---

## TAB 7 — Dasha (DashaScreen)

On initState: call getDashaApi(userid). Add 'mahadasha >' to breadcrumb list.

Layout:

Toggle buttons row (left-aligned):
  [vimshottari] [Yogini]  ← pill buttons, primary color when selected, grey otherwise

### Vimshottari mode

Breadcrumb bar (horizontal scrollable): arrow-shaped chips
  'mahadasha >' → 'AntarDasha >' → 'pratyantarDasha >'
  Tap any crumb to go back to that level (truncate list, reset tableindex)

Table area (45% screen height, scrollable):
  tableindex == 0: Mahadasha table (columns: Planet | End-Date)
    - Rows from mahaDasha.response.mahadasha[] with mahadashaOrder[]
    - Row tap: increment tableindex → 1, add 'AntarDasha >' to breadcrumb
  tableindex == 1: Antardasha table (columns: Antardasha | End-Date)
    - Rows from antarDasha.response.antardashas[mahadashaSelectedIndex][]
    - Row tap: increment tableindex → 2, add 'pratyantarDasha >'
  tableindex == 2: Pratyantardasha table (columns: Pratyantar | End-Date)
    - Rows from paryantarDasha.response.paryantardasha[mahaIndex][antarIndex][]

Below table: "Understanding Your dasha" heading + "Sun Mahadasha" subheading

Mahadasha prediction cards (one per dasha):
  - Header: "DashaName (startYear - endYear)"
  - Card 1: "Prediction: <text>" (bordered container)
  - Card 2: "Planet in Zodiac: <text>" (bordered container)

### Yogini mode

Same breadcrumb pattern but separate state (yaginiaddedItemsTable, yagnitableindex)

yagnitableindex == 0: Yogini main table (columns: Planet | End-Date | Dasha Lord)
  - Data: yoginiDashaMain.response.dashaList[], dashaEndDates[], dashaLordList[]
  - Row tap: set yagnitableindex = 1
yagnitableindex == 1: Yogini sub table (columns: Planet | End-Date)
  - Data: yoginiDashaSub.response[yagnidashaindextable].subDashaList[]

---

## TAB 8 — Dosha (DoshaScreen)

On initState: call getDoshaApi(userid).

Sections (vertically stacked, each with bold title):

1. Mangal Dosh:
   - Mars: <factors.mars text>
   - Venus: <factors.venus text>
   - Dosha Present: Yes/No
   - Anshik: Yes/No
   - Score response: <botResponse>

2. Kaal Sharp Dosh:
   - Dosha Present: Yes/No
   - Response: <botResponse>
   - Numbered list of remedies (bordered cards)

3. Manglik Dosh:
   - Manglik by Mars: Yes/No
   - Manglik by Rahu Ketu: Yes/No
   - Response: <botResponse>
   - Numbered list of factors

4. Pitra Dosh:
   - <pitraDosh.response.botResponse> (plain text paragraph)

5. Papasamaya Dosh:
   - Table header: Planet | Papa Score
   - 4 rows: Rahu | rahuPapa, Sun | sunPapa, Saturn | saturnPapa, Mars | marsPapa

---

## API ENDPOINTS (all POST unless noted)

Base URL: configurable constant

| Method | Endpoint                  | Body                                 | Purpose               |
|--------|---------------------------|--------------------------------------|-----------------------|
| POST   | /getkundali               | {token}                              | List all kundlis      |
| POST   | /kundali/basic            | {id, language}                       | Basic detail + planet |
| POST   | /kundali/chart            | {id, div, style, language}           | Chart SVG             |
| POST   | /kundali/astakvarga       | {id, language}                       | Ashtakvarga tables    |
| POST   | /kundali/ascendant-report | {id, language}                       | Ascendant report      |
| POST   | /kundali/planet-report    | {id, planet, language}               | Planet report         |
| POST   | /kundali/dasha            | {id, language}                       | Dasha data            |
| POST   | /kundali/dosha            | {id, language}                       | Dosha data            |
| POST   | /kundali/add              | {kundali: [...], amount, is_match}   | Create kundli         |
| POST   | /kundali/update/:id       | kundli model JSON                    | Update kundli         |
| POST   | /kundali/delete           | {id}                                 | Delete kundli         |
| POST   | /pdf/price                | {token}                              | Check PDF price       |
| GET    | /kundali/get/:id          | —                                    | Get PDF kundli link   |

All requests require auth headers (Bearer token in Authorization header).
Language fallback: use device locale code, default 'en'.
For dasha API: normalize locale codes mr→en, kn→en, bn→en, es→en before sending.

---

## KUNDLI MODEL (for create/update)

```json
{
  "name": "String",
  "gender": "Male | Female | Other",
  "birthDate": "yyyy-MM-dd",
  "birthTime": "HH:mm",
  "birthPlace": "String",
  "latitude": "double?",
  "longitude": "double?",
  "timezone": 5.3,
  "pdf_type": "String?",
  "forMatch": 0,
  "lang": "en | hi | ta | te | ka | ml | sp | fr"
}
```

---

## CREATE KUNDLI FLOW (5-step wizard)

Step 0: Name (text field)
Step 1: Gender (3 cards — Male / Female / Other, each with icon, highlight on select)
Step 2: Birth Date (date picker)
Step 3: Birth Time (time picker, optional — checkbox "Time of birth not known")
Step 4: Birth Place (location autocomplete → fetch lat/long/timezone via geocoding)

Progress indicator: row of 5 circles at top, filled/outlined based on current step.
"Next" button disabled until current step has valid input.
"Back" button navigates to previous step.

After step 4: call addKundli() then navigate back to list.

---

## EDIT KUNDLI SCREEN

Pre-filled form fields:
- Name (text)
- Gender (dropdown: Male / Female / Other)
- Birth Date (date picker)
- Birth Time (time picker)
- Birth Place (location search with lat/long update)

Save button: call updateKundli(id, model) → show toast → pop → refresh list.

---

## CHART SVG RENDERING

1. API returns SVG as a string in response
2. Convert string to Uint8List (utf8.encode)
3. Use flutter_svg PictureInfo: vg.loadPicture(SvgStringLoader(svgString), null)
4. Record picture to ui.Image at target resolution
5. Draw with CustomPainter: scale to fill canvas maintaining aspect ratio, center it
6. Cache the ui.Image in controller (separate fields for regular chart vs KP chart)

---

## COMMON UI PATTERNS

Table rows:
- Each row: Row with Expanded children separated by VerticalDivider(color: black, thickness: 0.5)
- Alternating colors: index.isEven → white, index.isOdd → Colors.pink[50] (or grey.shade200)
- Header row: bold text, primary color or pink text

Arrow breadcrumb chips (for Dasha):
- Custom ClipPath with arrow shape (rectangle + right-pointing triangle, 20px)
- Grey background, black text, tap to navigate back

Zoom pattern (Charts, KP, Ashtakvarga):
- Wrap content in InteractiveViewer(constrained: false, boundaryMargin: EdgeInsets.all(200))
- TransformationController for programmatic zoom
- Double-tap GestureDetector: if zoomed → reset to identity, else → scale 2.5x at tap point
- Floating zoom button triggers same logic

Loading state:
- Show CircularProgressIndicator centered in a full-height container
- Controller has isDataLoaded bool; set to true after first successful API response

---

## CONTROLLER STATE (KundliController)

Extends GetxController with GetSingleTickerProviderStateMixin

Key fields:
- kundliList / searchKundliList: List<KundliModel>
- basicDeatilmodel: BasicDetailModel?
- chartDeatilmodel: ChartDetailModel?
- astavargaDetailModel: AstavargaDetailModel?
- reportDeatilmodel: ReportDetailModel?
- planetreport: PlanetReportModel?
- dashaDeatilmodel: DashDetailsModel?
- doshaDeatilmodel: DoshaDetailsModel?
- selectedDirection: String ('north' default)
- selecteddashaoption: String ('vimshottari' default)
- tableindex: int (0=mahadasha, 1=antardasha, 2=pratyantardasha)
- addedItemsTable: List<String> (vimshottari breadcrumbs)
- yaginiaddedItemsTable: List<String> (yogini breadcrumbs)
- mahadashaSelectedIndex: int
- antardahsaSelectedIndex: int
- tabIndex: int (planet report current tab)
- isDataLoaded: bool
- ashtakvargaList: List<String> (planet names for rows)
- ashtakvargaTotal: List<int>
- ashtakvargaPoints: List<List<dynamic>>
- binnashtakvargaData: Map<String, List<int>>

onInit: TabController(vsync: this, length: 6) + load kundli list via getKundliList()

---

## SOURCE FILES (this project)

- lib/views/kudali/kundliScreen.dart — list screen
- lib/views/kudali/GetKundliDetailScreen.dart — 8-tab detail screen
- lib/views/kudali/createNewKundli.dart — 5-step create wizard
- lib/views/kudali/editKundliScreen.dart — edit screen
- lib/views/kudali/basicdetailwidget.dart — basic details widget
- lib/views/kudali/kundliDetailsScreen.dart — PDF viewer screen
- lib/views/kudali/FullSizeSvgPainter.dart — SVG custom painter
- lib/views/kudali/GetKundliscreens/kundlichartscreen.dart — charts tab
- lib/views/kudali/GetKundliscreens/KpScreen.dart — KP tab
- lib/views/kudali/GetKundliscreens/astavargaTablescreen.dart — ashtakvarga tab
- lib/views/kudali/GetKundliscreens/reportScreen.dart — report tab
- lib/views/kudali/GetKundliscreens/planetReportscreen.dart — planet report tab
- lib/views/kudali/GetKundliscreens/DashaScreen.dart — dasha tab
- lib/views/kudali/GetKundliscreens/DoshaScreen.dart — dosha tab
- lib/views/kudali/GetKundliscreens/arrowbox.dart — breadcrumb arrow widget
- lib/views/kudali/GetKundliscreens/arrowclipper.dart — arrow clip path
- lib/controllers/kundliController.dart — all state and API calls
- lib/utils/services/api_helper.dart — raw HTTP calls
