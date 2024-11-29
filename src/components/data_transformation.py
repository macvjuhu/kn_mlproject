

from dataclasses import dataclass
import sys
import numpy as np
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.discriminant_analysis import StandardScaler
from sklearn.impute import SimpleImputer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder
from common.exception import CustomException
from common.logger import logging as logger
from common.utils import save_object

numerical_columns = ["writing_score", "reading_score"]
categorical_columns = [     
    "gender",
    "race_ethnicity",
    "parental_level_of_education",
    "lunch",
    "test_preparation_course",
]
target_column_name="math_score"

@dataclass
class DataTransformationConfig:
    transformed_data_path = "artifacts/transformed_data.csv"
    preprocessor_obj_file_path = "artifacts/preprocessor.pkl"

class DataTransformation:
        def __init__(self):
            self.data_transformation_config = DataTransformationConfig()

        def get_data_transformer_object(self):
            try:

                logger.info(f"Numerical columns {numerical_columns}")
                logger.info(f"Categorical columns {categorical_columns}")

                num_pipeline = Pipeline(
                    steps = [
                            ("imputer",SimpleImputer(strategy="median")),
                            ("scaler",StandardScaler())
                        ]
                    )

                cat_pipeline = Pipeline(
                    steps = [
                        ("imputer",SimpleImputer(strategy="most_frequent")),
                        ("one_hot_encoder",OneHotEncoder()),
                        ("scaler",StandardScaler(with_mean=False))
                    ]
                )

                
                preprocessor = ColumnTransformer(
                    [
                    ("num_pipeline",num_pipeline,numerical_columns),
                    ("cat_pipelines",cat_pipeline,categorical_columns)

                    ]
                )
                logger.info("Pipelines and preprocessor defined")
                return preprocessor
            except Exception as e:
                 raise CustomException(e, sys)
            
    
        def initiate_data_transformation(self, train_data, test_data):
            try:
                logger.info("Initiating data transformation ...")

                preprocessing_obj  =self.get_data_transformer_object()

                input_feature_train_df = train_data.drop(columns=[target_column_name],axis=1)
                target_feature_train_df = train_data[target_column_name]

                input_feature_test_df = test_data.drop(columns=[target_column_name],axis=1)
                target_feature_test_df = test_data[target_column_name]

                logger.info(f"Applying preprocessing object on training dataframe and testing dataframe.")
                input_feature_train_arr = preprocessing_obj.fit_transform(input_feature_train_df)
                input_feature_test_arr = preprocessing_obj.transform(input_feature_test_df)

                train_arr = np.c_[ input_feature_train_arr, np.array(target_feature_train_df)]
                test_arr = np.c_[input_feature_test_arr, np.array(target_feature_test_df)]

                logger.info(f"Saved preprocessing object.")

                save_object(
                    file_path=self.data_transformation_config.preprocessor_obj_file_path,
                    obj=preprocessing_obj
                )

                return (
                    train_arr,
                    test_arr,
                    self.data_transformation_config.preprocessor_obj_file_path,
                )
            except Exception as e:
                raise CustomException(e, sys)