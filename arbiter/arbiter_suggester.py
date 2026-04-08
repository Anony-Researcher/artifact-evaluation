import pandas as pd

# Load dataset
df = pd.read_csv('V5contract_analysis_static.csv')

# === Heuristic Model ===
def arbiter_suggestion(row):
    func_count = row['function_count']
    state_vars = row['state_var_count']
    loc = row['lines_of_code']
    gas = row['Regular Gas Used']

    if func_count > 45 or loc > 500 or gas > 4500000:
        return 'Diamond'
    elif func_count > 25 or state_vars > 7 or loc > 350 or gas > 3200000:
        return 'Proxy'
    else:
        return 'Regular'

df['Arbiter Suggestion'] = df.apply(arbiter_suggestion, axis=1)

# === Label Map for Numeric Labels ===
label_map = {'Regular': 0, 'Proxy': 1, 'Diamond': 2}
df['Arbiter_Label'] = df['Arbiter Suggestion'].map(label_map)

# === Enhanced Reasoning Logic ===
def get_upgrade_reason(row):
    reasons = []
    if row['function_count'] > 45:
        reasons.append("High Function Count (Diamond)")
    elif row['function_count'] > 25:
        reasons.append("Moderate Function Count (Proxy)")

    if row['lines_of_code'] > 500:
        reasons.append("Large Codebase (Diamond)")
    elif row['lines_of_code'] > 350:
        reasons.append("Moderate Codebase (Proxy)")

    if row['state_var_count'] > 7:
        reasons.append("Many State Variables")

    if row['Regular Gas Used'] > 4500000:
        reasons.append("High Gas Usage (Diamond)")
    elif row['Regular Gas Used'] > 3200000:
        reasons.append("High Gas Usage (Proxy)")

    return ", ".join(reasons) if reasons else "N/A"

def exceeds_24kb(row):
    if row['lines_of_code'] > 500 or row['Regular Gas Used'] > 4500000:
        return "Yes"
    return "No"

df['Upgrade Reason'] = df.apply(get_upgrade_reason, axis=1)
df['Exceeds 24KB?'] = df.apply(exceeds_24kb, axis=1)

# === Save Full Detailed CSV ===
df.to_csv('contracts_with_arbiter_suggestions.csv', index=False)
print("✅ Arbiter suggestions saved to 'contracts_with_arbiter_suggestions.csv'")

# === Suggestion Summary ===
print("=== Arbiter Suggestions Summary ===")
print(df['Arbiter Suggestion'].value_counts())

# === Aggregated Summary Table ===
summary = df.groupby('Arbiter Suggestion').agg({
    'Regular Gas Used': 'mean',
    'Proxy Gas Used': 'mean',
    'Diamond GasUsed': 'mean'
}).round(2)

summary['Count'] = df['Arbiter Suggestion'].value_counts()
summary = summary[['Count', 'Regular Gas Used', 'Proxy Gas Used', 'Diamond GasUsed']]

# === Cost Efficiency Evaluation ===
def is_cost_efficient(row):
    if row['Arbiter Suggestion'] == 'Proxy':
        return row['Proxy Gas Used'] < row['Regular Gas Used']
    elif row['Arbiter Suggestion'] == 'Diamond':
        return row['Diamond GasUsed'] < row['Regular Gas Used']
    return None

df['Cost Efficient'] = df.apply(is_cost_efficient, axis=1)

efficiency_summary = (
    df[df['Cost Efficient'].notnull()]
    .groupby('Arbiter Suggestion')['Cost Efficient']
    .mean()
    .astype(float)
    .mul(100)
    .round(2)
)
# Clean column names to ensure consistency
df.columns = df.columns.str.strip()
# Filter rows with complete gas data
filtered_df = df.dropna(subset=[
    'Regular Gas Used', 
    'Proxy Gas Used', 
    'Diamond GasUsed'
])

# Sample 3 from each suggestion type
sample_df = (
    filtered_df.groupby('Arbiter Suggestion')
    .apply(lambda x: x.sample(3, random_state=42))
    .reset_index(drop=True)
)

# # Add Overhead Saved? column
# def compute_overhead_saved(row):
#     try:
#         if row['Arbiter Suggestion'] == 'Proxy':
#             return 'Yes' if row['Proxy Gas Used'] < row['Regular Gas Used'] else 'No'
#         elif row['Arbiter Suggestion'] == 'Diamond':
#             return 'Yes' if row['Diamond GasUsed'] < row['Regular Gas Used'] else 'No'
#         else:
#             return 'No'
#     except:
#         return 'Unknown'

# sample_df['Overhead Saved?'] = sample_df.apply(compute_overhead_saved, axis=1)

# # Save
# sample_df.to_csv("arbiter_representative_stratified.csv", index=False)
# print("✅ Sample saved with 'Overhead Saved?' column")


# Fix FutureWarning by only applying fillna to float column
summary = summary.merge(
    efficiency_summary.rename('% Cost Efficient'),
    on='Arbiter Suggestion',
    how='left'
)
summary['% Cost Efficient'] = summary['% Cost Efficient'].fillna('N/A')

# === Export Summary Table ===
summary.to_csv("arbiter_summary_table.csv", index=False)
print("✅ Summary table saved to 'arbiter_summary_table.csv'")

# === Export Full Enhanced CSV (Optional) ===
df.to_csv("arbiter_full_enhanced.csv", index=False)
print("✅ Full dataset with explanations saved to 'arbiter_full_enhanced.csv'")
