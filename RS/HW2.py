import pandas as pd
import numpy as np
import lightgbm as lgb
import argparse
import gc
from sklearn.preprocessing import LabelEncoder
from sklearn.decomposition import PCA
from scipy import sparse
from implicit.als import AlternatingLeastSquares
from rectools import Columns
from rectools.dataset import Dataset
from rectools.models import ImplicitALSWrapperModel
import warnings
warnings.filterwarnings('ignore')

def prep_feats(inter_df, usr_meta, itm_meta, itm_emb):
    usr_feats = usr_meta.copy()
    itm_feats = itm_meta.merge(itm_emb, on=["item_id"], how="left")
    usr_stats = inter_df.groupby('user_id').agg({
        'timespent': ['mean', 'sum', 'count'],
        'like': 'sum',
        'dislike': 'sum',
        'share': 'sum',
        'bookmark': 'sum',
        'click_on_author': 'sum',
        'open_comments': 'sum',
        'place': 'nunique',
        'platform': 'nunique',
        'agent': 'nunique'
    }).reset_index()
    usr_stats.columns = ['user_id'] + [f'u_{c[0]}_{c[1]}' for c in usr_stats.columns[1:]]
    itm_stats = inter_df.groupby('item_id').agg({
        'timespent': ['mean', 'sum', 'count'],
        'like': 'sum',
        'dislike': 'sum',
        'share': 'sum',
        'bookmark': 'sum',
        'click_on_author': 'sum',
        'open_comments': 'sum',
        'user_id': 'nunique'
    }).reset_index()
    itm_stats.columns = ['item_id'] + [f'i_{c[0]}_{c[1]}' for c in itm_stats.columns[1:]]
    usr_feats = usr_feats.merge(usr_stats, on='user_id', how='left')
    itm_feats = itm_feats.merge(itm_stats, on='item_id', how='left')
    usr_feats = usr_feats.fillna(0)
    itm_feats = itm_feats.fillna(0)
    return usr_feats, itm_feats

def build_hybrid(inter_df, usr_feats, itm_feats, top_n=10):
    als_res = als_recs(inter_df, usr_feats, itm_feats, top_n)
    pop_res = pop_recs(inter_df, top_n)
    cont_res = cont_recs(itm_feats, top_n)
    all_u = inter_df['user_id'].unique()
    final = []
    for u in all_u:
        buff = []
        if u in als_res:
            buff.extend(als_res[u])
        buff.extend(cont_res)
        if len(buff) < top_n:
            buff.extend(pop_res)
        seen = set()
        uniq = []
        for it in buff:
            if it not in seen and len(uniq) < top_n:
                seen.add(it)
                uniq.append(it)
        for it in uniq[:top_n]:
            final.append({'user_id': u, 'recs': it})
    return pd.DataFrame(final)

def als_recs(inter_df, usr_feats, itm_feats, top_n):
    u_ids = inter_df['user_id'].unique()
    i_ids = inter_df['item_id'].unique()
    u2i = {u: idx for idx, u in enumerate(u_ids)}
    i2i = {i: idx for idx, i in enumerate(i_ids)}
    r = [u2i[u] for u in inter_df['user_id']]
    c = [i2i[i] for i in inter_df['item_id']]
    w = (
        inter_df['timespent'].values / 255.0 +
        inter_df['like'].values * 2 +
        inter_df['share'].values * 3 +
        inter_df['bookmark'].values * 2 +
        inter_df['click_on_author'].values * 1.5
    )
    mat = sparse.csr_matrix((w, (r, c)), shape=(len(u_ids), len(i_ids)))
    mdl = AlternatingLeastSquares(factors=64, regularization=0.01, iterations=15)
    mdl.fit(mat)
    out = {}
    for u in u_ids:
        if u in u2i:
            ux = u2i[u]
            scores = mdl.recommend(ux, mat[ux], N=top_n * 2)
            items = [i_ids[it] for it, sc in zip(scores[0], scores[1])]
            out[u] = items
    return out

def pop_recs(inter_df, top_n):
    df = inter_df.copy()
    df['w'] = (
        df['timespent'] / 255.0 +
        df['like'] * 2 +
        df['share'] * 3 +
        df['bookmark'] * 2
    )
    pop = (df.groupby('item_id')['w']
             .sum()
             .sort_values(ascending=False)
             .head(top_n * 3)
             .index.tolist())
    return pop

def cont_recs(itm_feats, top_n):
    if 'embedding' not in itm_feats.columns:
        return []
    emb = np.stack(itm_feats['embedding'].values)
    p = PCA(n_components=16)
    red = p.fit_transform(emb)
    from sklearn.cluster import KMeans
    km = KMeans(n_clusters=top_n, random_state=42)
    cl = km.fit_predict(red)
    out = []
    for cid in range(top_n):
        grp = itm_feats[cl == cid]['item_id'].values
        if len(grp) > 0:
            out.append(grp[0])
    return out[:top_n]

def main(p_inter, p_usr, p_itm, p_emb, p_out):
    inter_df = pd.read_parquet(p_inter)
    usr_meta = pd.read_parquet(p_usr)
    itm_meta = pd.read_parquet(p_itm)
    itm_emb = pd.read_parquet(p_emb)
    usr_feats, itm_feats = prep_feats(inter_df, usr_meta, itm_meta, itm_emb)
    recs = build_hybrid(inter_df, usr_feats, itm_feats, top_n=10)
    recs.to_csv(p_out, index=False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Refactored Hybrid Recommender")
    parser.add_argument("--input_path_interactions", type=str, required=True)
    parser.add_argument("--input_path_users", type=str, required=True)
    parser.add_argument("--input_path_items", type=str, required=True)
    parser.add_argument("--input_path_embeddings", type=str, required=True)
    parser.add_argument("--output_path", type=str, required=True)
    args = parser.parse_args()
    main(args.input_path_interactions, args.input_path_users, args.input_path_items, args.input_path_embeddings, args.output_path)
