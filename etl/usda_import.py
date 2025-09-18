import os
import sqlite3
import zipfile
import json
from io import BytesIO
from urllib.request import urlopen


DB_FILE = "foods.db"
USDA_BASE = "https://fdc.nal.usda.gov/fdc-datasets/"

# Nutrients we care about
WANTED_NUTRIENTS = {
    "Energy": "calories_kcal",
    "Protein": "protein_g",
    "Total lipid (fat)": "fat_g",
    "Carbohydrate, by difference": "carbs_g",
}

def init_db(conn):
    cur = conn.cursor()

    # Main foods table
    cur.execute("""
        CREATE TABLE IF NOT EXISTS foods (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            source TEXT,
            external_id TEXT,
            description TEXT,
            calories_kcal REAL,
            protein_g REAL,
            fat_g REAL,
            carbs_g REAL,
            is_active INTEGER DEFAULT 1,
            UNIQUE (source, external_id)
        );
    """)

    # Portions table
    cur.execute("""
        CREATE TABLE IF NOT EXISTS food_portions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            food_id INTEGER NOT NULL,
            amount REAL,
            unit TEXT,
            gram_weight REAL NOT NULL,
            FOREIGN KEY (food_id) REFERENCES foods(id)
        );
    """)

    conn.commit()


def download_and_extract(url):
    print(f"🔽 Downloading: {url}")
    with urlopen(url) as resp:
        data = resp.read()

    zf = zipfile.ZipFile(BytesIO(data))
    for name in zf.namelist():
        if name.endswith(".json"):
            print(f"📂 Extracting: {name}")
            raw = zf.read(name).decode("utf-8").strip()

            # Sanity preview
            print("First 200 chars of JSON file:")
            print(raw[:200])
            print("---")

            try:
                parsed = json.loads(raw)
                if isinstance(parsed, dict):
                    if "FoundationFoods" in parsed:
                        return parsed["FoundationFoods"]
                    if "SRLegacyFoods" in parsed:
                        return parsed["SRLegacyFoods"]
                    if "SurveyFoods" in parsed:
                        return parsed["SurveyFoods"]
                    if "FoodNutrients" in parsed:
                        return parsed["FoodNutrients"]
                    if "foods" in parsed:
                        return parsed["foods"]
                    if "Foods" in parsed:
                        return parsed["Foods"]
                elif isinstance(parsed, list):
                    return parsed  # Top-level array case
            except json.JSONDecodeError:
                # possibly NDJSON fallback (Branded)
                foods = []
                for line in raw.splitlines():
                    line = line.strip()
                    if line:
                        try:
                            foods.append(json.loads(line))
                        except json.JSONDecodeError:
                            continue
                return foods
    return []

def parse_foods(data, source):
    foods = []

    for food in data:
        fdc_id = str(food.get("fdcId", ""))
        description = food.get("description", "").title()

        # --- Step 1: Extract nutrients ---
        nutrients = {
            "calories_kcal": None,
            "protein_g": None,
            "fat_g": None,
            "carbs_g": None,
        }

        for n in food.get("foodNutrients", []):
            name = n.get("nutrient", {}).get("name")
            amount = n.get("amount")
            unit = n.get("nutrient", {}).get("unitName")

            if name in WANTED_NUTRIENTS and amount is not None:
                key = WANTED_NUTRIENTS[name]
                val = float(amount)

                if name == "Energy" and unit == "kJ":
                    # convert to kcal
                    val = val / 4.184

                nutrients[key] = val

        # --- Step 2: Require complete macros ---
        if any(v is None for v in nutrients.values()):
            continue  # skip this food if missing any macro/calories

        # --- Step 3: Collect valid portions ---
        portions = []
        for p in food.get("foodPortions", []):
            gw = p.get("gramWeight")
            if gw is None or gw <= 0:
                continue

            unit = (
                p.get("portionDescription")
                or p.get("modifier")
                or (p.get("measureUnit", {}).get("name"))
                or "serving"
            )

            amount = p.get("amount", 1)

            portions.append(
                {
                    "amount": float(amount),
                    "unit": unit,
                    "gram_weight": float(gw),
                }
            )

        # --- Step 4: Require at least baseline + 1 valid portion ---
        # Baseline 100g always implied, but skip foods that don't
        # provide ANY usable portion mapping to grams.
        if not portions:
            continue

        foods.append(
            {
                "source": source,
                "external_id": fdc_id,
                "description": description,
                **nutrients,
                "portions": portions,
            }
        )

    return foods

def upsert_foods(conn, foods):
    cur = conn.cursor()

    for f in foods:
        # Insert or update food
        cur.execute(
            """
            INSERT INTO foods
            (source, external_id, description, calories_kcal, protein_g, fat_g, carbs_g)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(source, external_id) DO UPDATE SET
               description=excluded.description,
               calories_kcal=excluded.calories_kcal,
               protein_g=excluded.protein_g,
               fat_g=excluded.fat_g,
               carbs_g=excluded.carbs_g
            """,
            (
                f["source"],
                f["external_id"],
                f["description"],
                f["calories_kcal"],
                f["protein_g"],
                f["fat_g"],
                f["carbs_g"],
            ),
        )

        food_id = cur.lastrowid
        if food_id == 0:
            # If it already existed, grab its id
            cur.execute(
                "SELECT id FROM foods WHERE source=? AND external_id=?",
                (f["source"], f["external_id"]),
            )
            food_id = cur.fetchone()[0]

        # Clear old portions for this food
        cur.execute("DELETE FROM food_portions WHERE food_id=?", (food_id,))

        # Insert portions
        for p in f["portions"]:
            cur.execute(
                """
                INSERT INTO food_portions (food_id, amount, unit, gram_weight)
                VALUES (?, ?, ?, ?)
                """,
                (food_id, p["amount"], p["unit"], p["gram_weight"]),
            )

    conn.commit()

def main():
    print("➡️  Check the USDA FoodData Central download page:")
    print("   https://fdc.nal.usda.gov/download-datasets.html")
    print("⚠️  IMPORTANT: Copy the link to the **JSON** dataset (.zip with '_json_' in the name),")
    print("    NOT the CSV version.")

    foundation_url = input("\nEnter the FOUNDATION dataset URL: ").strip()
    sr_url = input("Enter the SR LEGACY dataset URL: ").strip()

    datasets = {
        "FOUNDATION": foundation_url,
        "SR_LEGACY": sr_url,
    }

    conn = sqlite3.connect(DB_FILE)
    init_db(conn)

    for source, url in datasets.items():
        # If the user pastes just a filename instead of a URL,
        # still handle it gracefully.
        if not url.startswith("http"):
            url = USDA_BASE + url

        data = download_and_extract(url)
        foods = parse_foods(data, source)
        print(f"✅ Parsed {len(foods)} foods from {source}")
        upsert_foods(conn, foods)

    conn.close()
    print("\n🎉 Done. Normalized foods stored in", DB_FILE)

if __name__ == "__main__":
    main()