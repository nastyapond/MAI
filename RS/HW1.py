import pandas as pd
from scipy.sparse import csr_matrix
import implicit
import argparse


def build_sparse_matrix(records, uid_mapping, iid_mapping):
    values = []
    row_indices = []
    col_indices = []
    
    for record in records.itertuples():
        if record.rating:
            values.append(record.rating)
            row_indices.append(uid_mapping[record.user_id])
            col_indices.append(iid_mapping[record.item_id])
    
    sparse_interaction_matrix = csr_matrix((values, (row_indices, col_indices)))
    return sparse_interaction_matrix


def compute_interaction_scores(dataset, features, time_metric='timespent'):
    dataset.loc[dataset['like'] == True, 'rating'] = 1
    dataset.loc[(dataset['dislike'] == True) & (dataset['rating'] != 1), 'rating'] = 0
    
    score_matrix = {
        (False, False, False, False): 0.1,
        (True, False, False, False): 0.4,
        (False, True, False, False): 0.35,
        (False, False, True, False): 0.3,
        (False, False, False, True): 0.25,
        (True, True, False, False): 0.65,
        (True, False, True, False): 0.6,
        (True, False, False, True): 0.55,
        (False, True, True, False): 0.5,
        (False, True, False, True): 0.45,
        (False, False, True, True): 0.4,
        (True, True, True, False): 0.8,
        (True, True, False, True): 0.75,
        (True, False, True, True): 0.7,
        (False, True, True, True): 0.65,
        (True, True, True, True): 0.9
    }
    
    for feature_combo, score_value in score_matrix.items():
        dataset.loc[
            (dataset['like'] == False) &
            (dataset['dislike'] == False) &
            (dataset[features[0]] == feature_combo[0]) &
            (dataset[features[1]] == feature_combo[1]) &
            (dataset[features[2]] == feature_combo[2]) &
            (dataset[features[3]] == feature_combo[3])
        , 'rating'] = score_value
    
    not_liked_mask = dataset['like'] == False
    not_liked_data = dataset[not_liked_mask]
    dataset.loc[not_liked_mask, 'rating'] *= 1 - (not_liked_data[time_metric] / not_liked_data.groupby('item_id')[time_metric].transform('max') - 1) ** 2
    
    return dataset


def main(input_path: str, output_path: str):
    dataset = pd.read_parquet(input_path)

    user_indices = [elem.item() for elem in sorted(dataset['user_id'].unique())]
    item_indices = [elem.item() for elem in sorted(dataset['item_id'].unique())]
    user_to_idx = {elem: position for position, elem in enumerate(user_indices)}
    item_to_idx = {elem: position for position, elem in enumerate(item_indices)}

    feature_columns = ['share', 'bookmark', 'click_on_author', 'open_comments']
    dataset = compute_interaction_scores(dataset, feature_columns)

    sparse_matrix = build_sparse_matrix(dataset, user_to_idx, item_to_idx)

    als_model = implicit.als.AlternatingLeastSquares(
        factors=37,
        regularization=199.555119133235,
        alpha=1.145077586631629
    )
    als_model.fit(sparse_matrix)

    recommended_items, _ = als_model.recommend(
        userid=list(user_to_idx.values()),
        user_items=sparse_matrix,
        N=10,
        filter_already_liked_items=True
    )
    recommended_items = [[item_indices[idx] for idx in row] for row in recommended_items]

    recommendations = pd.DataFrame({
        'recs': recommended_items
    }, index=sorted(dataset['user_id'].unique()))
    recommendations.index.name = 'user_id'
    recommendations = recommendations['recs'].explode().reset_index()
    recommendations.to_csv(output_path, index=False)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Recommender arguments.")
    parser.add_argument("--input_path", type=str, required=True, help="Input path to train parquet file")
    parser.add_argument("--output_path", type=str, required=True, help="Output path to csv with recommendations")

    args = parser.parse_args()
    main(args.input_path, args.output_path)