import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

df = (pd.read_csv("https://api.coronavirus.data.gov.uk/v2/data?areaType=region&metric=cumVaccinationFirstDoseUptakeByVaccinationDatePercentage&format=csv"))

df2 = df.loc[(df["date"] == "2021-12-23")]

df2.sort(columns = "cumVaccinationFirstDoseUptakeByVaccinationDatePercentage", inplace=True)

plt.xticks(range(len(df2.cumVaccinationFirstDoseUptakeByVaccinationDatePercentage)), df2.areaName, rotation=90)
plt.xlabel('Region')
plt.ylabel('Percentage uptake')
plt.ylim(0,100)
plt.title('First dose uptake across English regions')
plt.bar(range(len(df2.cumVaccinationFirstDoseUptakeByVaccinationDatePercentage)), df2.cumVaccinationFirstDoseUptakeByVaccinationDatePercentage) 
plt.show()

