import matplotlib.pyplot as plt
import pandas as pd
import requests
from bs4 import BeautifulSoup
import textwrap


url = "https://api.ons.gov.uk/timeseries/JP9Z/dataset/UNEM/data"

# Get the data from the ONS API:
json_data = requests.get(url).json()

# Prep the data for a quick plot
title = json_data["description"]["title"]
df = (
    pd.DataFrame(pd.json_normalize(json_data["months"]))
    .assign(
        date=lambda x: pd.to_datetime(x["date"]),
        value=lambda x: pd.to_numeric(x["value"]),
    )
    .set_index("date")
)

df["value"].plot(title=title, ylim=(0, df["value"].max() * 1.2), lw=3.0);