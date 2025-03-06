import matplotlib.pyplot as plt
import networkx as nx

# Создаем пустой граф
G = nx.Graph()

# Таблицы (узлы)
tables = [
    "pokemon", "types", "contest_types", "abilities", 
    "moves", "items", "trainers", "pokedex", "trades"
]
G.add_nodes_from(tables)

# Связи между таблицами (рёбра)
edges = [
    ("pokemon", "types"),
    ("pokemon", "contest_types"),
    ("pokemon", "abilities"),
    ("pokemon", "moves"),
    ("pokemon", "items"),
    ("pokemon", "trainers"),
    ("pokemon", "pokedex"),
    ("trades", "trainers"),
    ("trades", "pokemon"),
    ("pokedex", "types"),
    ("pokedex", "abilities")
]
G.add_edges_from(edges)

# Задаём расположение узлов (все узлы размещаются вдоль оси Y, а связи перпендикулярны)
pos = {
    "pokemon": (0, 0),
    "types": (1, 0),
    "contest_types": (2, 0),
    "abilities": (3, 0),
    "moves": (4, 0),
    "items": (5, 0),
    "trainers": (6, 0),
    "pokedex": (7, 0),
    "trades": (0, 1)
}

# Создаем рисунок
plt.figure(figsize=(10, 8))

# Настройка прямоугольных узлов
node_shapes = nx.get_node_attributes(G, 'shape')
for node in G.nodes:
    node_shapes[node] = "rectangle"  # Прямоугольники для всех узлов

# Рисуем граф
nx.draw(
    G,
    pos,
    with_labels=True,
    node_size=3000,
    node_color="lightblue",
    font_size=10,
    font_weight="bold",
    edge_color="gray",
    node_shape="s"  # Оставляем узлы прямоугольными
)

# Показываем граф
plt.title("Conceptual Data Model with Rectangular Nodes and Perpendicular Edges")
plt.show()
