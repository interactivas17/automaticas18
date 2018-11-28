import neurokit as nk
import pandas as pd
import numpy as np
import seaborn as sns

# Download data
df = pd.read_csv("https://raw.githubusercontent.com/neuropsychology/NeuroKit.py/master/examples/Bio/bio_100Hz.csv")
# Plot it
df.plot()
