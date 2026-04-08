import pandas as pd

# Load your dataset (if not already loaded)
df = pd.read_csv("contracts_with_arbiter_suggestions.csv")

# Step 1: Group by Arbiter Suggestion and compute average gas usage
summary = df.groupby('Arbiter Suggestion').agg({
    'Regular Gas Used': 'mean',
    'Proxy Gas Used': 'mean',
    'Diamond GasUsed': 'mean'
}).round(0)

# Step 2: Add count per suggestion type
summary['Count'] = df['Arbiter Suggestion'].value_counts()

# Reorder columns
summary = summary[['Count', 'Regular Gas Used', 'Proxy Gas Used', 'Diamond GasUsed']]
summary.reset_index(inplace=True)

# Step 3: Calculate cost-efficiency (Optional % savings if Arbiter suggestion was followed)
def is_cost_efficient(row):
    if row['Arbiter Suggestion'] == 'Proxy':
        return row['Proxy Gas Used'] < row['Regular Gas Used']
    elif row['Arbiter Suggestion'] == 'Diamond':
        return row['Diamond GasUsed'] < row['Regular Gas Used']
    return None  # Regular suggestion → no change

df['Cost Efficient'] = df.apply(is_cost_efficient, axis=1)

# Step 4: Calculate % cost efficient by suggestion type
efficiency = (
    df[df['Cost Efficient'].notnull()]
    .groupby('Arbiter Suggestion')['Cost Efficient']
    .mean()
)
efficiency = pd.Series(efficiency).astype(float).round(3) * 100
efficiency = efficiency.rename('% Cost Efficient')
# Step 5: Merge with summary
summary = summary.merge(efficiency, on='Arbiter Suggestion', how='left')
summary.fillna('N/A', inplace=True)

# # View or export
# print(summary)
# summary.to_csv("arbiter_summary_table.csv", index=False)
# sample_df = df[['contract_name', 'Arbiter Suggestion', 'Regular Gas Used', 'Proxy Gas Used', 'Diamond GasUsed']].sample(10, random_state=42)
# sample_df['Overhead Saved?'] = sample_df.apply(
#     lambda row: 'Yes' if (
#         (row['Arbiter Suggestion'] == 'Proxy' and row['Proxy Gas Used'] < row['Regular Gas Used']) or
#         (row['Arbiter Suggestion'] == 'Diamond' and row['Diamond GasUsed'] < row['Regular Gas Used'])
#     ) else 'No',
#     axis=1
# )
# sample_df.to_csv("arbiter_representative_sample.csv", index=False)


filtered_df = df.dropna(subset=[
    'Regular Gas Used', 
    'Proxy Gas Used', 
    'Diamond GasUsed'
])

sample_df = (
    filtered_df.groupby('Arbiter Suggestion')
    .apply(lambda x: x.sample(3, random_state=42))
    .reset_index(drop=True)
)

sample_df['Overhead Saved?'] = sample_df.apply(
    lambda row: 'Yes' if (
        (row['Arbiter Suggestion'] == 'Proxy' and row['Proxy Gas Used'] < row['Regular Gas Used']) or
        (row['Arbiter Suggestion'] == 'Diamond' and row['Diamond GasUsed'] < row['Regular Gas Used'])
    ) else 'No',
    axis=1
)

sample_df.to_csv("arbiter_representative_stratified.csv", index=False)
