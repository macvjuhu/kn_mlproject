import os
import sys

import numpy as np 
import pandas as pd
import pickle
from sklearn.metrics import r2_score
from sklearn.model_selection import GridSearchCV


from common.logger import logging as logger
from common.exception import CustomException
from joblib import Parallel, delayed
from concurrent.futures import ThreadPoolExecutor

def save_object(file_path, obj):
    try:
        dir_path = os.path.dirname(file_path)

        os.makedirs(dir_path, exist_ok=True)

        with open(file_path, "wb") as file_obj:
            pickle.dump(obj, file_obj)

    except Exception as e:
        raise CustomException(e, sys)
    
def evaluate_models(X_train, y_train, X_test, y_test, models, param):
    try:
        report = {}

        def evaluate_model(model_name, model, para):
            logger.info(f"Evaluating model {model_name} ...")
            if 'cuml' in sys.modules:
                from cuml.model_selection import GridSearchCV as cuml_GridSearchCV
                logger.info("Using cuML for GridSearchCV")
                gs = cuml_GridSearchCV(model, para, cv=3, n_jobs=2, pre_dispatch='2*n_jobs')
            else:
                gs = GridSearchCV(model, para, cv=3, n_jobs=2, pre_dispatch='2*n_jobs')
            gs.fit(X_train, y_train)

            model.set_params(**gs.best_params_)
            model.fit(X_train, y_train)

            logger.info(f"Model {model_name} trained successfully")

            #y_train_pred = model.predict(X_train)
            y_test_pred = model.predict(X_test)
            test_model_score = r2_score(y_test, y_test_pred)

            logger.info(f"Model {model_name} evaluated with r2 score of {test_model_score}")
            return model_name, test_model_score

        with ThreadPoolExecutor() as executor:
            results = list(executor.map(lambda item: evaluate_model(item[0], item[1], param[item[0]]), models.items()))

        report = dict(results)
        return report

    except Exception as e:
        raise CustomException(e, sys)
    
def load_object(file_path):
    try:
        with open(file_path, "rb") as file_obj:
            return pickle.load(file_obj)

    except Exception as e:
        raise CustomException(e, sys)