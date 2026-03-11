import argparse
import pandas as pd
import numpy as np
from scipy.sparse import csr_matrix
from implicit.als import AlternatingLeastSquares


def build_mappings(values):
    uniq = sorted(values.unique())
    mapping = {v: i for i, v in enumerate(uniq)}
    return uniq, mapping


def make_ratings(df):
    base = 0.2
    r = base \
        + 2.0 * df["like"].astype(float) \
        + 1.5 * df["share"].astype(float) \
        + 1.2 * df["bookmark"].astype(float)
    r += 0.8 * (df["timespent"].clip(0, 90) / 90)

    r = r.astype(np.float32)
    return r


def build_matrix(df, user2id, item2id):
    rows = df["user_id"].map(user2id).to_numpy()
    cols = df["item_id"].map(item2id).to_numpy()
    data = df["rating"].astype(np.float32).to_numpy()
    return csr_matrix((data, (rows, cols)), shape=(len(user2id), len(item2id)))


def main(inter_path, users_path, items_path, emb_path, output_path):

    # ===== LOAD =====
    df = pd.read_parquet(inter_path)

    # ===== MAPPINGS =====
    id2user, user2id = build_mappings(df["user_id"])
    id2item, item2id = build_mappings(df["item_id"])

    # ===== RATINGS =====
    df["rating"] = make_ratings(df)

    # ===== MATRIX =====
    mat = build_matrix(df, user2id, item2id)

    # ===== TRAIN ALS =====
    als = AlternatingLeastSquares(
        factors=64,
        iterations=12,
        regularization=0.1,
        alpha=20,
        num_threads=4,
    )
    als.fit(mat.T)

    # ===== POPULARITY =====
    pop = (
        df.groupby("item_id")["rating"]
        .sum()
        .sort_values(ascending=False)
        .index.tolist()
    )
    pop = [item2id[i] for i in pop]

    # ===== RECOMMEND =====
    recs_user = []
    recs_item = []

    for uid_internal, uid_real in enumerate(id2user):

        try:
            items, scores = als.recommend(
                userid=uid_internal,
                user_items=mat,
                N=20,
                filter_already_liked_items=True,
            )
            items = list(items)
        except Exception:
            items = []

        if len(items) < 10:
            for p in pop:
                if p not in items:
                    items.append(p)
                if len(items) >= 10:
                    break

        for it in items[:10]:
            recs_user.append(uid_real)
            recs_item.append(id2item[it])

    out = pd.DataFrame({"user_id": recs_user, "recs": recs_item})
    out.to_csv(output_path, index=False)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--input_path_interactions", required=True)
    parser.add_argument("--input_path_users", required=True)
    parser.add_argument("--input_path_items", required=True)
    parser.add_argument("--input_path_embeddings", required=True)
    parser.add_argument("--output_path", required=True)
    args = parser.parse_args()

    main(
        args.input_path_interactions,
        args.input_path_users,
        args.input_path_items,
        args.input_path_embeddings,
        args.output_path,
    )
