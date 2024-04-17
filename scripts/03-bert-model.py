#%%
# Packages ----------------------------------------------------------
from bertopic import BERTopic
from bertopic.vectorizers import ClassTfidfTransformer
from sentence_transformers import SentenceTransformer
from sklearn.feature_extraction.text import CountVectorizer
from pandas import read_csv
from pandas import DataFrame
from umap import UMAP
# %%

#%%
# Import dataset and extract abstracts ------------------------------
articles = read_csv("/Users/ales/R/csr-scarping/data-processed/articles.csv")
annotations = articles["annotation"]
# %%

#%%
# Compute tranformer embeddings and encode abstracts ----------------
embedding_model = SentenceTransformer("all-distilroberta-v1", device="mps")
embedding_model.max_seq_length = 512
embeddings = embedding_model.encode(annotations, show_progress_bar=True)
# %%

#%%
# Compute BERT model ------------------------------------------------
## Get rid of stop words, define minimum word appearance and n-grams 
stopwords = ([
    "i", "me", "my", "myself", "we", "our", "ours", "ourselves", "you", "your", "yours", 
    "yourself", "yourselves", "he", "him", "his", "himself", "she", "her", "hers", 
    "herself", "it", "its", "itself", "they", "them", "their", "theirs", "themselves", 
    "what", "which", "who", "whom", "this", "that", "these", "those", "am", "is", "are", 
    "was", "were", "be", "been", "being", "have", "has", "had", "having", "do", "does", 
    "did", "doing", "a", "an", "the", "and", "but", "if", "or", "because", "as", "until", 
    "while", "of", "at", "by", "for", "with", "about", "against", "between", "into", 
    "through", "during", "before", "after", "above", "below", "to", "from", "up", "down", 
    "in", "out", "on", "off", "over", "under", "again", "further", "then", "once", "here", 
    "there", "when", "where", "why", "how", "all", "any", "both", "each", "few", "more", 
    "most", "other", "some", "such", "no", "nor", "not", "only", "own", "same", "so", 
    "than", "too", "very", "s", "t", "can", "will", "just", "don", "should", "now",
    "sociological", "sociologist", "journal", "article", "sociology", "sociologick", "sociologists",
    "academic", "publish", "published", "czech", "czechs", "interwar", "bourdieus",
    "number", "numbers", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "zero",
    "hypothesis", "hypotheses", "data", "dataset", "interview", "interviews", "concept", "analysis"
])

vectorizer_model = CountVectorizer(stop_words= stopwords, min_df=5, ngram_range=(1, 2))
ctfidf_model = ClassTfidfTransformer(reduce_frequent_words=True)

## UMAP for the dimension reduction. Embeddings collapsed into 3 dimensions (n_components),
## smallest topic size is 10 documents 
umap_model = UMAP(n_neighbors=5, n_components=5, min_dist=0.0, metric='cosine', random_state = 42)

## The model itself
topic_model = BERTopic(ctfidf_model=ctfidf_model,
                       vectorizer_model=vectorizer_model,
                       min_topic_size = 10,
                       umap_model = umap_model,
                       calculate_probabilities=True)

topics, probs = topic_model.fit_transform(annotations, embeddings=embeddings)

#%%
# Extracting results ------------------------------------------------
topics = topic_model.get_document_info(annotations) # Full results
probs = DataFrame(probs, columns= ["topic_" + str(i) for i in range(1, 14)]) # topic probabilities
reduced_embeddings = UMAP(n_neighbors=10, n_components=2, min_dist=0.0, metric='cosine').fit_transform(embeddings)
reduced_topics = DataFrame(reduced_embeddings) # collapsed results for map visualization
# %%

# %%
## Exporting results ------------------------------------------------
probs.to_csv("probs.csv")
topics.to_csv("topics.csv")
reduced_topics.to_csv("reduced_topics.csv")
