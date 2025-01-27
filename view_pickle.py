import pickle
import json

with open("artifacts/model.pkl", "rb") as f:
    data = pickle.load(f)

# Save as JSON for inspection
with open("output.json", "w") as json_file:
    json.dump(data, json_file, indent=4)
