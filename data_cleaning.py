import pandas as pd 

INPUT_FILE = "E-Commerce Customer Churn & Cohort Analysis\online_retail.csv"
OUTPUT_FILE = "online_retail_clean.csv"

def clean_data():
    print("Loading the dataset.. (This might take a moment, it's 500k+ rows)")
    # ENCODING IS REQUIRED BECAUSE REAL FILES HAVE WEIRD CHARACTERS
    try:
        df = pd.read_csv(INPUT_FILE, encoding = 'ISO-8859-1')
    except UnicodeDecodeError:
        df = pd.read_csv(INPUT_FILE, encoding = 'utf-8')
    
    print(f"Initial Row Count: {len(df)}")

    # CLEANING 
    df = df.dropna(subset = ["Customer ID"])
    df = df[df["Quantity"] > 0]
    df = df[df["Price"] > 0]
    df["Total Sales"] = df["Price"] * df["Quantity"]
    df["InvoiceDate"] = pd.to_datetime(df["InvoiceDate"])
    print(f"Final Row Count: {len(df)}")

    #SAVING
    df.to_csv(OUTPUT_FILE, index = False)
    print(f"Successfully Saved!!! Saved to : {OUTPUT_FILE} ")

if __name__ == '__main__':
    clean_data()