import pandas as pd
import numpy as np
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt

# Create a DataFrame with random data
np.random.seed(42)
data = pd.DataFrame({
    'Feature1': np.random.rand(100),
    'Feature2': np.random.rand(100),
})

# Read Lore data
training_set_csv = "LORE-Optimal.csv"
optimal_data_df = pd.read_csv(training_set_csv)
# Apply k-means clustering
kmeans = KMeans(n_clusters=3)
#data['Cluster'] = kmeans.fit_predict(data[['Feature1', 'Feature2']])
#data['Cluster'] = kmeans.fit_predict(optimal_data_df[['Rate[L1]_GB/s', 'Rate[L2]_GB/s', 
#                  'Rate[L3]_GB/s', 'Rate[RAM]_GB/s', 'Rate[Fp]_GFLOP/s']])
optimal_data_df['Cluster'] = kmeans.fit_predict(optimal_data_df[['Stall[LM]_%', 'Stall[SB]_%']])

# Display the DataFrame with cluster assignments
print(data)

# Visualize the clusters
plt.scatter(optimal_data_df['Stall[LM]_%'], optimal_data_df['Stall[SB]_%'], c=optimal_data_df['Cluster'], cmap='viridis', edgecolors='k', s=50)
plt.scatter(kmeans.cluster_centers_[:, 0], kmeans.cluster_centers_[:, 1], c='red', marker='X', s=200, label='Centroids')
plt.title('K-Means Clustering on DataFrame')
plt.xlabel('Load Matrix')
plt.ylabel('Store Buffer')
plt.legend()
plt.show()