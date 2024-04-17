# Install proper version of python for BERT LLM ---------------------------
reticulate::install_miniconda()

reticulate::conda_create("topic_modeling", python_version = "3.11.6")
reticulate::conda_install("topic_modeling", "bertopic==0.15.0")
reticulate::conda_install("topic_modeling", "transformers==4.35.2")
