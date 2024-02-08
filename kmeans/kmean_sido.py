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

# Apply k-means clustering
kmeans = KMeans(n_clusters=3)
data['Cluster'] = kmeans.fit_predict(data[['Feature1', 'Feature2']])

# Display the DataFrame with cluster assignments
print(data)

# Visualize the clusters
plt.scatter(data['Feature1'], data['Feature2'], c=data['Cluster'], cmap='viridis', edgecolors='k', s=50)
plt.scatter(kmeans.cluster_centers_[:, 0], kmeans.cluster_centers_[:, 1], c='red', marker='X', s=200, label='Centroids')
plt.title('K-Means Clustering on DataFrame')
plt.xlabel('Feature 1')
plt.ylabel('Feature 2')
plt.legend()
plt.show()