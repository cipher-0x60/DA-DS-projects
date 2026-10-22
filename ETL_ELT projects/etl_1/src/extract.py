
import kagglehub
from kagglehub import KaggleDatasetAdapter

# Download the dataset files to the local cache
dataset_path = kagglehub.dataset_download(
    "srisyra02/air-quality-dataset"
)

print("Dataset directory:", dataset_path)

from pathlib import Path

for file in Path(dataset_path).rglob("*"):
    if file.is_file():
        print(file)


file_path = "air_quality_dataset.csv"

df = kagglehub.load_dataset(
    KaggleDatasetAdapter.PANDAS,
    "srisyra02/air-quality-dataset",
    file_path,
)

print("Shape:", df.shape)
print("\nColumns:", df.columns.tolist())
print("\nData types:\n", df.dtypes)
print("\nFirst five records:\n", df.head())
print("\nMissing values:\n", df.isna().sum())
