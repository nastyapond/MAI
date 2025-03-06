import numpy as np
from scipy.stats import expon

def generate_trajectory(n, scale):
    trajectory = np.zeros((n+1, 3))  # Начальная точка (0,0,0)
    for k in range(n):
        noise = expon.rvs(scale=scale, size=3)
        trajectory[k+1] = trajectory[k] + noise
    return trajectory

def trajectory_length(trajectory):
    return np.sum(np.linalg.norm(np.diff(trajectory, axis=0), axis=1))

def trajectory_end_distance(trajectory):
    return np.linalg.norm(trajectory[-1])

def count_self_intersections(trajectory):
    points = trajectory[:-1] 
    num_intersections = 0
    for i, point in enumerate(points):
        for j in range(i+2, len(points) - (1 if i == 0 else 0)):
            if np.allclose(point, points[j]):
                num_intersections += 1
    return num_intersections

def main(m, n, scale):
    trajectories = [generate_trajectory(n, scale) for _ in range(m)]
    end_distances = [trajectory_end_distance(traj) for traj in trajectories]
    max_distance_index = np.argmax(end_distances)
    lengths = [trajectory_length(traj) for traj in trajectories]
    max_li = np.argmax(lengths)
    min_li = np.argmin(lengths)
    intersections = [count_self_intersections(traj) for traj in trajectories]
    max_intersections_index = np.argmax(intersections)

    print(f"Траектория с максимальным расстоянием от начала: {max_distance_index}")
    print(f"Траектория с максимальной длиной: {max_li}")
    print(f"Траектория с минимальной длиной: {min_li}")
    print(f"Траектория с наибольшим числом самопересечений: {max_intersections_index}")

if __name__ == "__main__":
    m = int(input("количество траекторий: "))
    n = int(input("количество точек в каждой траектории: "))
    scale = float(input("параметр масштаба распределения: "))
    main(m, n, scale)
