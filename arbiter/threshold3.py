# Step 3: Validation of Empirically-Derived Thresholds
# Run this to validate your new thresholds against the dataset

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import classification_report, confusion_matrix
import warnings
warnings.filterwarnings('ignore')

def apply_empirical_thresholds(df):
    """
    Apply the empirically-derived thresholds to classify contracts
    """
    print("=" * 70)
    print("STEP 3A: APPLYING EMPIRICAL THRESHOLDS")
    print("=" * 70)
    
    # Define empirically-derived thresholds
    thresholds = {
        'contract_count': {'proxy': 4, 'diamond': 8},
        'function_count': {'proxy': 32, 'diamond': 57}, 
        'state_var_count': {'proxy': 8, 'diamond': 18},
        'lines_of_code': {'proxy': 400, 'diamond': 566},
        'regular_gas': {'proxy': 3276537, 'diamond': 3426784}
    }
    
    # Create new classification columns
    df['empirical_suggestion'] = 'Regular'  # Default
    
    # Apply thresholds (Diamond takes precedence over Proxy)
    for metric, threshold in thresholds.items():
        if metric in df.columns:
            # Diamond conditions
            diamond_condition = df[metric] > threshold['diamond']
            df.loc[diamond_condition, 'empirical_suggestion'] = 'Diamond'
            
            # Proxy conditions (only if not already Diamond)
            proxy_condition = (df[metric] > threshold['proxy']) & (df['empirical_suggestion'] != 'Diamond')
            df.loc[proxy_condition, 'empirical_suggestion'] = 'Proxy'
    
    # Special handling for gas (use Regular Gas Used column)
    gas_col = 'Regular Gas Used'
    if gas_col in df.columns:
        gas_data = df[gas_col].dropna()
        diamond_gas_condition = df[gas_col] > thresholds['regular_gas']['diamond']
        df.loc[diamond_gas_condition, 'empirical_suggestion'] = 'Diamond'
        
        proxy_gas_condition = (df[gas_col] > thresholds['regular_gas']['proxy']) & (df['empirical_suggestion'] != 'Diamond')
        df.loc[proxy_gas_condition, 'empirical_suggestion'] = 'Proxy'
    
    # Count results
    empirical_counts = df['empirical_suggestion'].value_counts()
    print("EMPIRICAL THRESHOLD RESULTS:")
    for pattern, count in empirical_counts.items():
        percentage = count / len(df) * 100
        print(f"{pattern}: {count:,} contracts ({percentage:.1f}%)")
    
    return df

def compare_with_original_thresholds(df):
    """
    Compare empirical thresholds with original fixed thresholds
    """
    print("\n" + "=" * 70)
    print("STEP 3B: COMPARING WITH ORIGINAL THRESHOLDS")
    print("=" * 70)
    
    # Apply original thresholds
    original_thresholds = {
        'function_count': {'proxy': 25, 'diamond': 45},
        'state_var_count': {'proxy': 7, 'diamond': None},  # Diamond threshold not specified originally
        'lines_of_code': {'proxy': 350, 'diamond': 500},
        'regular_gas': {'proxy': 3200000, 'diamond': 4500000}
    }
    
    df['original_suggestion'] = 'Regular'  # Default
    
    # Apply original thresholds
    for metric, threshold in original_thresholds.items():
        if metric in df.columns:
            # Diamond conditions
            if threshold['diamond'] is not None:
                diamond_condition = df[metric] > threshold['diamond']
                df.loc[diamond_condition, 'original_suggestion'] = 'Diamond'
            
            # Proxy conditions (only if not already Diamond)
            proxy_condition = (df[metric] > threshold['proxy']) & (df['original_suggestion'] != 'Diamond')
            df.loc[proxy_condition, 'original_suggestion'] = 'Proxy'
    
    # Gas handling for original
    gas_col = 'Regular Gas Used'
    if gas_col in df.columns:
        diamond_gas_condition = df[gas_col] > original_thresholds['regular_gas']['diamond']
        df.loc[diamond_gas_condition, 'original_suggestion'] = 'Diamond'
        
        proxy_gas_condition = (df[gas_col] > original_thresholds['regular_gas']['proxy']) & (df['original_suggestion'] != 'Diamond')
        df.loc[proxy_gas_condition, 'original_suggestion'] = 'Proxy'
    
    # Compare results
    original_counts = df['original_suggestion'].value_counts()
    empirical_counts = df['empirical_suggestion'].value_counts()
    
    print("COMPARISON: Original vs Empirical Thresholds")
    print("-" * 50)
    patterns = ['Regular', 'Proxy', 'Diamond']
    
    for pattern in patterns:
        original_count = original_counts.get(pattern, 0)
        empirical_count = empirical_counts.get(pattern, 0)
        original_pct = original_count / len(df) * 100
        empirical_pct = empirical_count / len(df) * 100
        difference = empirical_count - original_count
        
        print(f"{pattern}:")
        print(f"  Original: {original_count:,} ({original_pct:.1f}%)")
        print(f"  Empirical: {empirical_count:,} ({empirical_pct:.1f}%)")
        print(f"  Difference: {difference:+,} contracts")
        print()
    
    return df

def validate_against_existing_patterns(df):
    """
    Validate thresholds against existing proxy/diamond contracts
    """
    print("=" * 70)
    print("STEP 3C: VALIDATION AGAINST EXISTING PATTERNS")
    print("=" * 70)
    
    # Get actual patterns from dataset
    actual_proxy = df[df['is_proxy'] == True]
    actual_diamond = df[df['is_diamond'] == True]
    actual_regular = df[(df['is_proxy'] == False) & (df['is_diamond'] == False)]
    
    print(f"Actual patterns in dataset:")
    print(f"Regular: {len(actual_regular):,} contracts")
    print(f"Proxy: {len(actual_proxy):,} contracts")
    print(f"Diamond: {len(actual_diamond):,} contracts")
    
    # Check how well our empirical thresholds predict existing patterns
    if len(actual_proxy) > 0:
        print(f"\nPROXY VALIDATION:")
        empirical_proxy_predictions = df[df['empirical_suggestion'] == 'Proxy']
        
        # How many actual proxies are captured by empirical thresholds?
        correctly_identified_proxies = len(df[(df['is_proxy'] == True) & (df['empirical_suggestion'] == 'Proxy')])
        proxy_recall = correctly_identified_proxies / len(actual_proxy) * 100
        
        # How many empirical proxy suggestions are actual proxies?
        if len(empirical_proxy_predictions) > 0:
            proxy_precision = correctly_identified_proxies / len(empirical_proxy_predictions) * 100
        else:
            proxy_precision = 0
            
        print(f"Empirical thresholds identify {correctly_identified_proxies}/{len(actual_proxy)} actual proxies ({proxy_recall:.1f}% recall)")
        print(f"Of {len(empirical_proxy_predictions)} proxy suggestions, {correctly_identified_proxies} are actual proxies ({proxy_precision:.1f}% precision)")
    
    if len(actual_diamond) > 0:
        print(f"\nDIAMOND VALIDATION:")
        empirical_diamond_predictions = df[df['empirical_suggestion'] == 'Diamond']
        
        correctly_identified_diamonds = len(df[(df['is_diamond'] == True) & (df['empirical_suggestion'] == 'Diamond')])
        diamond_recall = correctly_identified_diamonds / len(actual_diamond) * 100
        
        if len(empirical_diamond_predictions) > 0:
            diamond_precision = correctly_identified_diamonds / len(empirical_diamond_predictions) * 100
        else:
            diamond_precision = 0
            
        print(f"Empirical thresholds identify {correctly_identified_diamonds}/{len(actual_diamond)} actual diamonds ({diamond_recall:.1f}% recall)")
        print(f"Of {len(empirical_diamond_predictions)} diamond suggestions, {correctly_identified_diamonds} are actual diamonds ({diamond_precision:.1f}% precision)")

def create_threshold_comparison_plots(df):
    """
    Create visualizations comparing original vs empirical thresholds
    """
    print("\n" + "=" * 70)
    print("STEP 3D: CREATING COMPARISON VISUALIZATIONS")
    print("=" * 70)
    
    # Create comparison plots
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))
    
    metrics = [
        ('function_count', 'Function Count'),
        ('state_var_count', 'State Variables'), 
        ('lines_of_code', 'Lines of Code'),
        ('Regular Gas Used', 'Regular Gas Usage')
    ]
    
    original_thresholds = {
        'function_count': {'proxy': 25, 'diamond': 45},
        'state_var_count': {'proxy': 7, 'diamond': None},
        'lines_of_code': {'proxy': 350, 'diamond': 500},
        'Regular Gas Used': {'proxy': 3200000, 'diamond': 4500000}
    }
    
    empirical_thresholds = {
        'function_count': {'proxy': 32, 'diamond': 57},
        'state_var_count': {'proxy': 8, 'diamond': 18},
        'lines_of_code': {'proxy': 400, 'diamond': 566},
        'Regular Gas Used': {'proxy': 3276537, 'diamond': 3426784}
    }
    
    for i, (col_name, display_name) in enumerate(metrics):
        if i < 4 and col_name in df.columns:
            ax = axes[i//2, i%2]
            data = df[col_name].dropna()
            
            # Create histogram
            ax.hist(data, bins=50, alpha=0.6, density=True, color='lightblue', edgecolor='black')
            
            # Add threshold lines
            if col_name in original_thresholds:
                # Original thresholds
                if original_thresholds[col_name]['proxy']:
                    ax.axvline(original_thresholds[col_name]['proxy'], color='red', linestyle=':', linewidth=2, 
                              label=f'Original Proxy ({original_thresholds[col_name]["proxy"]})')
                if original_thresholds[col_name]['diamond']:
                    ax.axvline(original_thresholds[col_name]['diamond'], color='darkred', linestyle=':', linewidth=2,
                              label=f'Original Diamond ({original_thresholds[col_name]["diamond"]})')
                
                # Empirical thresholds
                ax.axvline(empirical_thresholds[col_name]['proxy'], color='orange', linestyle='-', linewidth=2,
                          label=f'Empirical Proxy ({empirical_thresholds[col_name]["proxy"]})')
                ax.axvline(empirical_thresholds[col_name]['diamond'], color='darkorange', linestyle='-', linewidth=2,
                          label=f'Empirical Diamond ({empirical_thresholds[col_name]["diamond"]})')
            
            ax.set_title(f'{display_name} Threshold Comparison', fontsize=12, fontweight='bold')
            ax.set_xlabel(display_name)
            ax.set_ylabel('Density')
            ax.legend(fontsize=8)
            ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('threshold_comparison_analysis.png', dpi=300, bbox_inches='tight')
    plt.show()
    
    print("Comparison plots saved as 'threshold_comparison_analysis.png'")

def run_validation_analysis(csv_file_path):
    """
    Run complete validation analysis
    """
    print("RUNNING THRESHOLD VALIDATION ANALYSIS")
    print("=" * 70)
    
    df = pd.read_csv(csv_file_path)
    
    # Step 3A: Apply empirical thresholds
    df = apply_empirical_thresholds(df)
    
    # Step 3B: Compare with original thresholds  
    df = compare_with_original_thresholds(df)
    
    # Step 3C: Validate against existing patterns
    validate_against_existing_patterns(df)
    
    # Step 3D: Create comparison visualizations
    create_threshold_comparison_plots(df)
    
    print("\n" + "=" * 70)
    print("VALIDATION ANALYSIS COMPLETE!")
    print("=" * 70)
    print("Results show how empirical thresholds compare to original fixed values")
    print("and validate against existing upgrade patterns in your dataset.")
    
    return df

# =============================================================================
# MAIN EXECUTION - RUN THIS FOR STEP 3!
# =============================================================================

if __name__ == "__main__":
    csv_file_path = r"C:\Users\aishw\Desktop\arbiter\arbiter_full_enhanced.csv"
    
    try:
        validated_df = run_validation_analysis(csv_file_path)
        print("\n SUCCESS! Validation analysis completed!")
        
    except Exception as e:
        print(f"❌ ERROR: {str(e)}")